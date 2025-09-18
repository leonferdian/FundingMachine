import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import prisma from '../config/database';
import { TransactionType, TransactionStatus } from '@prisma/client';

export const getTransactions = async (req: Request, res: Response) => {
  const userId = req.user?.id;
  const { 
    type, 
    status, 
    startDate, 
    endDate, 
    page = 1, 
    limit = 10 
  } = req.query;

  try {
    const whereClause: any = { userId };
    
    // Add filters if provided
    if (type) whereClause.type = type;
    if (status) whereClause.status = status;
    
    // Add date range filter if provided
    if (startDate || endDate) {
      whereClause.createdAt = {};
      if (startDate) whereClause.createdAt.gte = new Date(startDate as string);
      if (endDate) {
        const end = new Date(endDate as string);
        end.setHours(23, 59, 59, 999);
        whereClause.createdAt.lte = end;
      }
    }

    // Calculate pagination
    const skip = (Number(page) - 1) * Number(limit);
    const total = await prisma.transaction.count({ where: whereClause });

    const transactions = await prisma.transaction.findMany({
      where: whereClause,
      include: {
        funding: {
          select: {
            id: true,
            platform: {
              select: {
                id: true,
                name: true,
                type: true,
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip,
      take: Number(limit),
    });

    res.json({
      success: true,
      count: transactions.length,
      total,
      page: Number(page),
      pages: Math.ceil(total / Number(limit)),
      data: transactions,
    });
  } catch (error) {
    console.error('Get transactions error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching transactions',
    });
  }
};

export const getTransactionById = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    const transaction = await prisma.transaction.findFirst({
      where: { id, userId },
      include: {
        funding: {
          select: {
            id: true,
            platform: {
              select: {
                id: true,
                name: true,
                type: true,
              },
            },
          },
        },
      },
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found',
      });
    }

    res.json({
      success: true,
      data: transaction,
    });
  } catch (error) {
    console.error('Get transaction by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching transaction',
    });
  }
};

export const requestWithdrawal = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { amount, bankAccountId, description } = req.body;
  const userId = req.user?.id;

  try {
    // Check if bank account exists and belongs to user
    const bankAccount = await prisma.bankAccount.findFirst({
      where: { id: bankAccountId, userId },
    });

    if (!bankAccount) {
      return res.status(404).json({
        success: false,
        message: 'Bank account not found',
      });
    }

    // Calculate available balance (sum of all completed PROFIT transactions)
    const profitResult = await prisma.transaction.aggregate({
      where: {
        userId,
        type: 'PROFIT',
        status: 'COMPLETED',
      },
      _sum: {
        amount: true,
      },
    });

    const totalProfit = profitResult._sum.amount || 0;

    // Calculate total withdrawn amount
    const withdrawalResult = await prisma.transaction.aggregate({
      where: {
        userId,
        type: 'WITHDRAWAL',
        status: { in: ['COMPLETED', 'PENDING'] },
      },
      _sum: {
        amount: true,
      },
    });

    const totalWithdrawn = withdrawalResult._sum.amount || 0;
    const availableBalance = totalProfit - totalWithdrawn;

    // Check if user has sufficient balance
    if (availableBalance < parseFloat(amount)) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient balance',
        availableBalance,
      });
    }

    // Create withdrawal request
    const transaction = await prisma.transaction.create({
      data: {
        userId,
        type: 'WITHDRAWAL',
        amount: parseFloat(amount),
        status: 'PENDING',
        description: description || 'Withdrawal request',
        metadata: {
          bankAccountId,
          bankCode: bankAccount.bankCode,
          accountNumber: bankAccount.accountNumber,
          accountName: bankAccount.accountName,
        },
      },
    });

    // In a real application, you would integrate with a payment gateway here
    // For now, we'll just simulate a successful withdrawal after a delay
    setTimeout(async () => {
      await prisma.transaction.update({
        where: { id: transaction.id },
        data: { status: 'COMPLETED' },
      });
    }, 5000);

    res.status(201).json({
      success: true,
      data: transaction,
    });
  } catch (error) {
    console.error('Request withdrawal error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while processing withdrawal request',
    });
  }
};

export const getTransactionSummary = async (req: Request, res: Response) => {
  const userId = req.user?.id;

  try {
    // Get total profit
    const profitResult = await prisma.transaction.aggregate({
      where: {
        userId,
        type: 'PROFIT',
        status: 'COMPLETED',
      },
      _sum: {
        amount: true,
      },
    });

    // Get total withdrawn
    const withdrawalResult = await prisma.transaction.aggregate({
      where: {
        userId,
        type: 'WITHDRAWAL',
        status: { in: ['COMPLETED', 'PENDING'] },
      },
      _sum: {
        amount: true,
      },
    });

    // Get total deposited
    const depositResult = await prisma.transaction.aggregate({
      where: {
        userId,
        type: 'DEPOSIT',
        status: 'COMPLETED',
      },
      _sum: {
        amount: true,
      },
    });

    // Get recent transactions
    const recentTransactions = await prisma.transaction.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 5,
      include: {
        funding: {
          select: {
            platform: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
    });

    const totalProfit = profitResult._sum.amount || 0;
    const totalWithdrawn = withdrawalResult._sum.amount || 0;
    const totalDeposited = depositResult._sum.amount || 0;
    const availableBalance = totalProfit - totalWithdrawn;

    res.json({
      success: true,
      data: {
        totalProfit,
        totalWithdrawn,
        totalDeposited,
        availableBalance,
        recentTransactions,
      },
    });
  } catch (error) {
    console.error('Get transaction summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching transaction summary',
    });
  }
};
