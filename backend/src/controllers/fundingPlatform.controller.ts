import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import prisma from '../config/database';
import { Prisma, PrismaClient } from '@prisma/client';

// Define PlatformType enum locally to avoid import issues
const PlatformType = {
  ADS: 'ADS',
  SURVEY: 'SURVEY',
  INVESTMENT: 'INVESTMENT',
  AFFILIATE: 'AFFILIATE',
  OTHER: 'OTHER',
} as const;

type PlatformType = typeof PlatformType[keyof typeof PlatformType];

export const getFundingPlatforms = async (req: Request, res: Response) => {
  try {
    const platforms = await prisma.fundingPlatform.findMany({
      where: { isActive: true },
      select: {
        id: true,
        name: true,
        type: true,
        description: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    res.json({
      success: true,
      count: platforms.length,
      data: platforms,
    });
  } catch (error) {
    console.error('Get funding platforms error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching funding platforms',
    });
  }
};

export const getFundingPlatformById = async (req: Request, res: Response) => {
  try {
    const platform = await prisma.fundingPlatform.findUnique({
      where: { id: req.params.id },
      select: {
        id: true,
        name: true,
        type: true,
        description: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!platform) {
      return res.status(404).json({
        success: false,
        message: 'Funding platform not found',
      });
    }

    res.json({
      success: true,
      data: platform,
    });
  } catch (error) {
    console.error('Get funding platform by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching funding platform',
    });
  }
};

export const createFundingPlatform = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { name, type, description, apiUrl } = req.body;

  try {
    // Check if platform with same name already exists
    const existingPlatform = await prisma.fundingPlatform.findFirst({
      where: { name },
    });

    if (existingPlatform) {
      return res.status(400).json({
        success: false,
        message: 'Platform with this name already exists',
      });
    }

    // Validate platform type
    if (!Object.values(PlatformType).includes(type)) {
      return res.status(400).json({
        success: false,
        message: `Invalid platform type. Must be one of: ${Object.values(PlatformType).join(', ')}`,
      });
    }

    const platform = await prisma.fundingPlatform.create({
      data: {
        name,
        type,
        description,
        apiUrl,
        isActive: true,
      },
    });

    // Remove sensitive data from response
    const { ...platformData } = platform;

    res.status(201).json({
      success: true,
      data: platformData,
    });
  } catch (error) {
    console.error('Create funding platform error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating funding platform',
    });
  }
};

export const updateFundingPlatform = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const { name, type, description, apiUrl, isActive } = req.body;

  try {
    // Check if platform exists
    const existingPlatform = await prisma.fundingPlatform.findUnique({
      where: { id },
    });

    if (!existingPlatform) {
      return res.status(404).json({
        success: false,
        message: 'Funding platform not found',
      });
    }

    // Check if name is being changed and if it's already taken
    if (name && name !== existingPlatform.name) {
      const nameTaken = await prisma.fundingPlatform.findFirst({
        where: { name, id: { not: id } },
      });

      if (nameTaken) {
        return res.status(400).json({
          success: false,
          message: 'Platform with this name already exists',
        });
      }
    }

    // Validate platform type if being updated
    if (type && !Object.values(PlatformType).includes(type)) {
      return res.status(400).json({
        success: false,
        message: `Invalid platform type. Must be one of: ${Object.values(PlatformType).join(', ')}`,
      });
    }

    const updatedPlatform = await prisma.fundingPlatform.update({
      where: { id },
      data: {
        name: name || existingPlatform.name,
        type: type || existingPlatform.type,
        description: description !== undefined ? description : existingPlatform.description,
        apiUrl: apiUrl !== undefined ? apiUrl : existingPlatform.apiUrl,
        isActive: isActive !== undefined ? isActive : existingPlatform.isActive,
      },
    });

    // Remove sensitive data from response
    const { ...platformData } = updatedPlatform;

    res.json({
      success: true,
      data: platformData,
    });
  } catch (error) {
    console.error('Update funding platform error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating funding platform',
    });
  }
};

export const deleteFundingPlatform = async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    // Check if platform exists
    const platform = await prisma.fundingPlatform.findUnique({
      where: { id },
    });

    if (!platform) {
      return res.status(404).json({
        success: false,
        message: 'Funding platform not found',
      });
    }

    // Check if platform is being used in any funding
    const fundingCount = await prisma.funding.count({
      where: { platformId: id },
    });

    if (fundingCount > 0) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete platform that is being used in active funding',
      });
    }

    // Delete the platform
    await prisma.fundingPlatform.delete({
      where: { id },
    });

    res.json({
      success: true,
      message: 'Funding platform deleted successfully',
    });
  } catch (error) {
    console.error('Delete funding platform error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting funding platform',
    });
  }
};
