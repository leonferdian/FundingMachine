import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import prisma from '../config/database';
import { encrypt } from '../utils/encryption';

export const getPaymentMethods = async (req: Request, res: Response) => {
  const userId = req.user?.id;

  try {
    const paymentMethods = await prisma.paymentMethod.findMany({
      where: { userId, isActive: true },
      orderBy: [
        { isDefault: 'desc' },
        { createdAt: 'desc' }
      ],
    });

    // Remove sensitive data from response
    const sanitizedMethods = paymentMethods.map((method: any) => ({
      id: method.id,
      type: method.type,
      provider: method.provider,
      last4: method.last4,
      expiryMonth: method.expiryMonth,
      expiryYear: method.expiryYear,
      isDefault: method.isDefault,
      createdAt: method.createdAt,
    }));

    res.json({
      success: true,
      count: paymentMethods.length,
      data: sanitizedMethods,
    });
  } catch (error) {
    console.error('Get payment methods error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching payment methods',
    });
  }
};

export const getPaymentMethodById = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    const paymentMethod = await prisma.paymentMethod.findFirst({
      where: { id, userId, isActive: true },
    });

    if (!paymentMethod) {
      return res.status(404).json({
        success: false,
        message: 'Payment method not found',
      });
    }

    // Remove sensitive data from response
    const sanitizedMethod = {
      id: paymentMethod.id,
      type: paymentMethod.type,
      provider: paymentMethod.provider,
      last4: paymentMethod.last4,
      expiryMonth: paymentMethod.expiryMonth,
      expiryYear: paymentMethod.expiryYear,
      isDefault: paymentMethod.isDefault,
      createdAt: paymentMethod.createdAt,
    };

    res.json({
      success: true,
      data: sanitizedMethod,
    });
  } catch (error) {
    console.error('Get payment method by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching payment method',
    });
  }
};

export const createPaymentMethod = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const userId = req.user?.id;
  const {
    type,
    cardNumber,
    expiryMonth,
    expiryYear,
    cvv,
    holderName,
    paypalEmail,
    bankAccountNumber,
    bankRoutingNumber
  } = req.body;

  try {
    // Check if user already has a default payment method
    const existingDefault = await prisma.paymentMethod.findFirst({
      where: { userId, isDefault: true, isActive: true },
    });

    let metadata: any = {};

    // Encrypt sensitive data based on payment method type
    if (type === 'CARD' && cardNumber) {
      metadata = {
        encryptedCardNumber: encrypt(cardNumber),
        encryptedCvv: encrypt(cvv),
        holderName: encrypt(holderName),
      };
    } else if (type === 'PAYPAL' && paypalEmail) {
      metadata = {
        encryptedEmail: encrypt(paypalEmail),
      };
    } else if (type === 'BANK_ACCOUNT' && bankAccountNumber) {
      metadata = {
        encryptedAccountNumber: encrypt(bankAccountNumber),
        encryptedRoutingNumber: encrypt(bankRoutingNumber),
      };
    }

    // Create new payment method
    const paymentMethod = await prisma.paymentMethod.create({
      data: {
        userId,
        type,
        provider: type === 'CARD' ? 'credit_card' : type.toLowerCase(),
        last4: cardNumber ? cardNumber.slice(-4) : null,
        expiryMonth: type === 'CARD' ? parseInt(expiryMonth) : null,
        expiryYear: type === 'CARD' ? parseInt(expiryYear) : null,
        isDefault: !existingDefault, // Set as default if no other default exists
        metadata,
      },
    });

    // If this is the new default, unset other defaults
    if (paymentMethod.isDefault && existingDefault) {
      await prisma.paymentMethod.updateMany({
        where: { userId, id: { not: paymentMethod.id } },
        data: { isDefault: false },
      });
    }

    // Remove sensitive data from response
    const sanitizedMethod = {
      id: paymentMethod.id,
      type: paymentMethod.type,
      provider: paymentMethod.provider,
      last4: paymentMethod.last4,
      expiryMonth: paymentMethod.expiryMonth,
      expiryYear: paymentMethod.expiryYear,
      isDefault: paymentMethod.isDefault,
      createdAt: paymentMethod.createdAt,
    };

    res.status(201).json({
      success: true,
      data: sanitizedMethod,
    });
  } catch (error) {
    console.error('Create payment method error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating payment method',
    });
  }
};

export const updatePaymentMethod = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const userId = req.user?.id;
  const { isDefault, isActive } = req.body;

  try {
    // Check if payment method exists and belongs to user
    const paymentMethod = await prisma.paymentMethod.findFirst({
      where: { id, userId },
    });

    if (!paymentMethod) {
      return res.status(404).json({
        success: false,
        message: 'Payment method not found',
      });
    }

    // Handle default payment method logic
    if (isDefault === true) {
      // Unset all other default payment methods for this user
      await prisma.paymentMethod.updateMany({
        where: { userId, id: { not: id } },
        data: { isDefault: false },
      });
    }

    // Update payment method
    const updatedPaymentMethod = await prisma.paymentMethod.update({
      where: { id },
      data: {
        isDefault,
        isActive,
      },
    });

    // Remove sensitive data from response
    const sanitizedMethod = {
      id: updatedPaymentMethod.id,
      type: updatedPaymentMethod.type,
      provider: updatedPaymentMethod.provider,
      last4: updatedPaymentMethod.last4,
      expiryMonth: updatedPaymentMethod.expiryMonth,
      expiryYear: updatedPaymentMethod.expiryYear,
      isDefault: updatedPaymentMethod.isDefault,
      isActive: updatedPaymentMethod.isActive,
      createdAt: updatedPaymentMethod.createdAt,
    };

    res.json({
      success: true,
      data: sanitizedMethod,
    });
  } catch (error) {
    console.error('Update payment method error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating payment method',
    });
  }
};

export const deletePaymentMethod = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    // Check if payment method exists and belongs to user
    const paymentMethod = await prisma.paymentMethod.findFirst({
      where: { id, userId },
    });

    if (!paymentMethod) {
      return res.status(404).json({
        success: false,
        message: 'Payment method not found',
      });
    }

    // Soft delete - mark as inactive
    await prisma.paymentMethod.update({
      where: { id },
      data: { isActive: false },
    });

    res.json({
      success: true,
      message: 'Payment method deleted successfully',
    });
  } catch (error) {
    console.error('Delete payment method error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting payment method',
    });
  }
};

export const setDefaultPaymentMethod = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    // Check if payment method exists and belongs to user
    const paymentMethod = await prisma.paymentMethod.findFirst({
      where: { id, userId, isActive: true },
    });

    if (!paymentMethod) {
      return res.status(404).json({
        success: false,
        message: 'Payment method not found',
      });
    }

    // Unset all other default payment methods for this user
    await prisma.paymentMethod.updateMany({
      where: { userId, id: { not: id } },
      data: { isDefault: false },
    });

    // Set this payment method as default
    const updatedPaymentMethod = await prisma.paymentMethod.update({
      where: { id },
      data: { isDefault: true },
    });

    res.json({
      success: true,
      data: {
        id: updatedPaymentMethod.id,
        isDefault: updatedPaymentMethod.isDefault,
      },
    });
  } catch (error) {
    console.error('Set default payment method error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while setting default payment method',
    });
  }
};
