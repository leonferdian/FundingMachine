import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import prisma from '../config/database';
import { protect } from '../utils/jwt';

export const addBankAccount = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { bankCode, accountNumber, accountName, isDefault = false } = req.body;
  const userId = req.user?.id;

  try {
    // Check if bank account already exists
    const existingAccount = await prisma.bankAccount.findFirst({
      where: {
        userId,
        bankCode,
        accountNumber,
      },
    });

    if (existingAccount) {
      return res.status(400).json({
        success: false,
        message: 'Bank account already exists',
      });
    }

    // If setting as default, unset other default accounts
    if (isDefault) {
      await prisma.bankAccount.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      });
    }

    // Create new bank account
    const bankAccount = await prisma.bankAccount.create({
      data: {
        userId,
        bankCode,
        accountNumber,
        accountName,
        isDefault,
      },
    });

    res.status(201).json({
      success: true,
      data: bankAccount,
    });
  } catch (error) {
    console.error('Add bank account error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while adding bank account',
    });
  }
};

export const getBankAccounts = async (req: Request, res: Response) => {
  const userId = req.user?.id;

  try {
    const bankAccounts = await prisma.bankAccount.findMany({
      where: { userId },
      orderBy: { isDefault: 'desc' },
    });

    res.json({
      success: true,
      count: bankAccounts.length,
      data: bankAccounts,
    });
  } catch (error) {
    console.error('Get bank accounts error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching bank accounts',
    });
  }
};

export const updateBankAccount = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const { bankCode, accountNumber, accountName, isDefault } = req.body;
  const userId = req.user?.id;

  try {
    // Check if bank account exists and belongs to user
    const existingAccount = await prisma.bankAccount.findFirst({
      where: { id, userId },
    });

    if (!existingAccount) {
      return res.status(404).json({
        success: false,
        message: 'Bank account not found',
      });
    }

    // If setting as default, unset other default accounts
    if (isDefault) {
      await prisma.bankAccount.updateMany({
        where: { userId, isDefault: true, id: { not: id } },
        data: { isDefault: false },
      });
    }

    // Update bank account
    const updatedAccount = await prisma.bankAccount.update({
      where: { id },
      data: {
        bankCode,
        accountNumber,
        accountName,
        isDefault: isDefault ?? existingAccount.isDefault,
      },
    });

    res.json({
      success: true,
      data: updatedAccount,
    });
  } catch (error) {
    console.error('Update bank account error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating bank account',
    });
  }
};

export const deleteBankAccount = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    // Check if bank account exists and belongs to user
    const existingAccount = await prisma.bankAccount.findFirst({
      where: { id, userId },
    });

    if (!existingAccount) {
      return res.status(404).json({
        success: false,
        message: 'Bank account not found',
      });
    }

    // Don't allow deletion if it's the only bank account
    const accountCount = await prisma.bankAccount.count({ where: { userId } });
    if (accountCount <= 1) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete the only bank account',
      });
    }

    // Delete bank account
    await prisma.bankAccount.delete({
      where: { id },
    });

    // If the deleted account was default, set another one as default
    if (existingAccount.isDefault) {
      const firstAccount = await prisma.bankAccount.findFirst({
        where: { userId },
      });
      
      if (firstAccount) {
        await prisma.bankAccount.update({
          where: { id: firstAccount.id },
          data: { isDefault: true },
        });
      }
    }

    res.json({
      success: true,
      message: 'Bank account deleted successfully',
    });
  } catch (error) {
    console.error('Delete bank account error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting bank account',
    });
  }
};

export const setDefaultBankAccount = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    // Check if bank account exists and belongs to user
    const existingAccount = await prisma.bankAccount.findFirst({
      where: { id, userId },
    });

    if (!existingAccount) {
      return res.status(404).json({
        success: false,
        message: 'Bank account not found',
      });
    }

    // Unset current default account
    await prisma.bankAccount.updateMany({
      where: { userId, isDefault: true, id: { not: id } },
      data: { isDefault: false },
    });

    // Set new default account
    const updatedAccount = await prisma.bankAccount.update({
      where: { id },
      data: { isDefault: true },
    });

    res.json({
      success: true,
      data: updatedAccount,
    });
  } catch (error) {
    console.error('Set default bank account error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while setting default bank account',
    });
  }
};
