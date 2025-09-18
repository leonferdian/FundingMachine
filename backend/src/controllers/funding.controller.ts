import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import prisma from '../config/database';
import { FundingStatus } from '@prisma/client';

export const createFunding = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { platformId, amount, profitShare } = req.body;
  const userId = req.user?.id;

  try {
    // Check if platform exists and is active
    const platform = await prisma.fundingPlatform.findUnique({
      where: { id: platformId, isActive: true },
    });

    if (!platform) {
      return res.status(404).json({
        success: false,
        message: 'Funding platform not found or inactive',
      });
    }

    // Check if user already has an active funding for this platform
    const existingFunding = await prisma.funding.findFirst({
      where: {
        userId,
        platformId,
        status: 'ACTIVE',
      },
    });

    if (existingFunding) {
      return res.status(400).json({
        success: false,
        message: 'You already have an active funding for this platform',
      });
    }

    // Create new funding
    const funding = await prisma.funding.create({
      data: {
        userId,
        platformId,
        amount: parseFloat(amount),
        profitShare: parseFloat(profitShare) || 0,
        status: 'ACTIVE',
      },
      include: {
        platform: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },
      },
    });

    // Create initial transaction
    await prisma.transaction.create({
      data: {
        userId,
        fundingId: funding.id,
        type: 'DEPOSIT',
        amount: parseFloat(amount),
        status: 'COMPLETED',
        description: `Initial deposit for ${platform.name}`,
      },
    });

    res.status(201).json({
      success: true,
      data: funding,
    });
  } catch (error) {
    console.error('Create funding error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating funding',
    });
  }
};

export const getUserFundings = async (req: Request, res: Response) => {
  const userId = req.user?.id;
  const { status } = req.query;

  try {
    const whereClause: any = { userId };
    
    if (status) {
      whereClause.status = status as FundingStatus;
    }

    const fundings = await prisma.funding.findMany({
      where: whereClause,
      include: {
        platform: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      success: true,
      count: fundings.length,
      data: fundings,
    });
  } catch (error) {
    console.error('Get fundings error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching fundings',
    });
  }
};

export const getFundingById = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    const funding = await prisma.funding.findFirst({
      where: { id, userId },
      include: {
        platform: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },
        transactions: {
          orderBy: { createdAt: 'desc' },
          take: 10, // Get the 10 most recent transactions
        },
      },
    });

    if (!funding) {
      return res.status(404).json({
        success: false,
        message: 'Funding not found',
      });
    }

    res.json({
      success: true,
      data: funding,
    });
  } catch (error) {
    console.error('Get funding by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching funding',
    });
  }
};

export const updateFundingStatus = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const { status } = req.body;
  const userId = req.user?.id;

  try {
    // Check if funding exists and belongs to user
    const funding = await prisma.funding.findFirst({
      where: { id, userId },
    });

    if (!funding) {
      return res.status(404).json({
        success: false,
        message: 'Funding not found',
      });
    }

    // Validate status transition
    if (funding.status === 'COMPLETED' || funding.status === 'CANCELLED') {
      return res.status(400).json({
        success: false,
        message: `Cannot update funding with status ${funding.status}`,
      });
    }

    // Update funding status
    const updatedFunding = await prisma.funding.update({
      where: { id },
      data: { status },
      include: {
        platform: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },
      },
    });

    // Create status update transaction
    await prisma.transaction.create({
      data: {
        userId,
        fundingId: funding.id,
        type: 'WITHDRAWAL',
        amount: 0, // No amount for status change
        status: 'COMPLETED',
        description: `Funding status updated to ${status}`,
        metadata: {
          previousStatus: funding.status,
          newStatus: status,
        },
      },
    });

    res.json({
      success: true,
      data: updatedFunding,
    });
  } catch (error) {
    console.error('Update funding status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating funding status',
    });
  }
};

export const recordProfit = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const { amount, description } = req.body;
  const userId = req.user?.id;

  try {
    // Check if funding exists and belongs to user
    const funding = await prisma.funding.findFirst({
      where: { id, userId, status: 'ACTIVE' },
    });

    if (!funding) {
      return res.status(404).json({
        success: false,
        message: 'Active funding not found',
      });
    }

    // Calculate profit based on profit share
    const profitAmount = parseFloat(amount) * (funding.profitShare / 100);

    // Create profit transaction
    const transaction = await prisma.transaction.create({
      data: {
        userId,
        fundingId: funding.id,
        type: 'PROFIT',
        amount: profitAmount,
        status: 'COMPLETED',
        description: description || 'Profit from funding',
        metadata: {
          originalAmount: parseFloat(amount),
          profitShare: funding.profitShare,
        },
      },
    });

    res.status(201).json({
      success: true,
      data: transaction,
    });
  } catch (error) {
    console.error('Record profit error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while recording profit',
    });
  }
};
