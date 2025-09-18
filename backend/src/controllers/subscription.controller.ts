import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import prisma from '../config/database';
// Define SubscriptionStatus enum locally
const SubscriptionStatus = {
  ACTIVE: 'ACTIVE',
  CANCELLED: 'CANCELLED',
  EXPIRED: 'EXPIRED',
  PAYMENT_FAILED: 'PAYMENT_FAILED',
  RENEWED: 'RENEWED',
} as const;

type SubscriptionStatus = typeof SubscriptionStatus[keyof typeof SubscriptionStatus];

// Define Subscription type locally
type Subscription = {
  id: string;
  userId: string;
  planId: string;
  amount: number;
  startDate: Date;
  endDate: Date;
  status: SubscriptionStatus;
  paymentId: string | null;
  autoRenew: boolean;
  cancelledAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
};
import { v4 as uuidv4 } from 'uuid';

// Mock payment gateway integration
const processPayment = async (amount: number, paymentMethod: string) => {
  // In a real application, this would integrate with a payment gateway
  return {
    success: true,
    transactionId: `pay_${uuidv4().replace(/-/g, '')}`,
    status: 'COMPLETED',
  };
};

export const getSubscriptionPlans = async (req: Request, res: Response) => {
  try {
    const plans = [
      {
        id: 'plan_monthly',
        name: 'Monthly',
        description: 'Billed monthly',
        price: 12000, // IDR 12,000
        billingCycle: 'monthly',
        features: [
          'Access to all funding platforms',
          'Basic analytics',
          'Email support',
          'Standard withdrawal processing',
        ],
      },
      {
        id: 'plan_quarterly',
        name: 'Quarterly',
        description: 'Billed every 3 months',
        price: 30000, // IDR 30,000 (save 16.7%)
        billingCycle: 'quarterly',
        features: [
          'Everything in Monthly',
          'Priority support',
          'Faster withdrawal processing',
          'Exclusive quarterly reports',
        ],
      },
      {
        id: 'plan_annual',
        name: 'Annual',
        description: 'Billed annually',
        price: 120000, // IDR 120,000 (save 16.7%)
        billingCycle: 'annual',
        features: [
          'Everything in Quarterly',
          'VIP support',
          'Instant withdrawal processing',
          'Personal account manager',
          'Exclusive investment opportunities',
        ],
      },
    ];

    res.json({
      success: true,
      data: plans,
    });
  } catch (error) {
    console.error('Get subscription plans error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching subscription plans',
    });
  }
};

export const getCurrentSubscription = async (req: Request, res: Response) => {
  const userId = req.user?.id;

  try {
    const subscription = await prisma.subscription.findFirst({
      where: { userId, status: 'ACTIVE' },
      orderBy: { endDate: 'desc' },
    });

    if (!subscription) {
      return res.json({
        success: true,
        data: null,
        message: 'No active subscription found',
      });
    }

    res.json({
      success: true,
      data: subscription,
    });
  } catch (error) {
    console.error('Get current subscription error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching current subscription',
    });
  }
};

export const createSubscription = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { planId, paymentMethod } = req.body;
  const userId = req.user?.id;

  try {
    // Get plan details
    const plans = [
      { id: 'plan_monthly', price: 12000, months: 1 },
      { id: 'plan_quarterly', price: 30000, months: 3 },
      { id: 'plan_annual', price: 120000, months: 12 },
    ];

    const plan = plans.find((p) => p.id === planId);
    if (!plan) {
      return res.status(400).json({
        success: false,
        message: 'Invalid plan ID',
      });
    }

    // Check if user already has an active subscription
    const existingSubscription = await prisma.subscription.findFirst({
      where: { userId, status: 'ACTIVE' },
    });

    if (existingSubscription) {
      return res.status(400).json({
        success: false,
        message: 'You already have an active subscription',
      });
    }

    // Process payment
    const paymentResult = await processPayment(plan.price, paymentMethod);

    if (!paymentResult.success) {
      return res.status(400).json({
        success: false,
        message: 'Payment failed',
      });
    }

    // Calculate subscription dates
    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + plan.months);

    // Create subscription
    const subscription = await prisma.subscription.create({
      data: {
        userId,
        planId: plan.id,
        amount: plan.price,
        startDate,
        endDate,
        status: 'ACTIVE',
        paymentId: paymentResult.transactionId,
        autoRenew: true,
      },
    });

    // Create transaction record
    await prisma.transaction.create({
      data: {
        userId,
        type: 'SUBSCRIPTION',
        amount: plan.price,
        status: 'COMPLETED',
        description: `Subscription payment for ${plan.id}`,
        metadata: {
          subscriptionId: subscription.id,
          planId: plan.id,
          paymentId: paymentResult.transactionId,
        },
      },
    });

    res.status(201).json({
      success: true,
      data: subscription,
    });
  } catch (error) {
    console.error('Create subscription error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating subscription',
    });
  }
};

export const cancelSubscription = async (req: Request, res: Response) => {
  const { id } = req.params;
  const userId = req.user?.id;

  try {
    // Find the subscription
    const subscription = await prisma.subscription.findFirst({
      where: { id, userId, status: 'ACTIVE' },
    });

    if (!subscription) {
      return res.status(404).json({
        success: false,
        message: 'Active subscription not found',
      });
    }

    // Update subscription status
    const updatedSubscription = await prisma.subscription.update({
      where: { id },
      data: {
        status: 'CANCELLED',
        autoRenew: false,
        cancelledAt: new Date(),
      },
    });

    res.json({
      success: true,
      data: updatedSubscription,
      message: 'Subscription has been cancelled. It will remain active until the end of the current billing period.',
    });
  } catch (error) {
    console.error('Cancel subscription error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while cancelling subscription',
    });
  }
};

export const updateAutoRenew = async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const { autoRenew } = req.body;
  const userId = req.user?.id;

  try {
    // Find the subscription
    const subscription = await prisma.subscription.findFirst({
      where: { id, userId },
    });

    if (!subscription) {
      return res.status(404).json({
        success: false,
        message: 'Subscription not found',
      });
    }

    // Update auto-renew setting
    const updatedSubscription = await prisma.subscription.update({
      where: { id },
      data: { autoRenew },
    });

    res.json({
      success: true,
      data: updatedSubscription,
      message: `Auto-renew has been ${autoRenew ? 'enabled' : 'disabled'} for this subscription`,
    });
  } catch (error) {
    console.error('Update auto-renew error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating auto-renew setting',
    });
  }
};

// This would be called by a scheduled job to process subscription renewals
export const processSubscriptionRenewals = async () => {
  try {
    const expiringSubscriptions = await prisma.subscription.findMany({
      where: {
        status: 'ACTIVE',
        autoRenew: true,
        endDate: {
          lte: new Date(new Date().setDate(new Date().getDate() + 3)), // Due in next 3 days
          gte: new Date(), // Not already expired
        },
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            // Add other user fields needed for payment processing
          },
        },
      },
    });

    for (const subscription of expiringSubscriptions) {
      try {
        // Process payment
        const paymentResult = await processPayment(
          subscription.amount,
          'saved_payment_method' // In a real app, you'd get this from the user's saved payment methods
        );

        if (paymentResult.success) {
          // Calculate new dates
          const months = subscription.planId === 'plan_annual' ? 12 : 
                        subscription.planId === 'plan_quarterly' ? 3 : 1;
          
          const newEndDate = new Date(subscription.endDate);
          newEndDate.setMonth(newEndDate.getMonth() + months);

          // Create new subscription period
          await prisma.subscription.create({
            data: {
              userId: subscription.userId,
              planId: subscription.planId,
              amount: subscription.amount,
              startDate: subscription.endDate,
              endDate: newEndDate,
              status: 'ACTIVE',
              paymentId: paymentResult.transactionId,
              autoRenew: true,
            },
          });

          // Create transaction record
          await prisma.transaction.create({
            data: {
              userId: subscription.userId,
              type: 'SUBSCRIPTION',
              amount: subscription.amount,
              status: 'COMPLETED',
              description: `Subscription renewal for ${subscription.planId}`,
              metadata: {
                subscriptionId: subscription.id,
                planId: subscription.planId,
                paymentId: paymentResult.transactionId,
              },
            },
          });

          // Update old subscription
          await prisma.subscription.update({
            where: { id: subscription.id },
            data: { status: 'RENEWED' },
          });

          // Send confirmation email (in a real app)
          // await sendSubscriptionRenewalConfirmation(subscription.user.email, subscription);
        } else {
          // Handle failed payment
          await prisma.subscription.update({
            where: { id: subscription.id },
            data: { 
              status: 'PAYMENT_FAILED',
              autoRenew: false,
            },
          });

          // Send payment failure email (in a real app)
          // await sendSubscriptionPaymentFailed(subscription.user.email, subscription);
        }
      } catch (error) {
        console.error(`Error processing renewal for subscription ${subscription.id}:`, error);
        // Log the error and continue with the next subscription
      }
    }
  } catch (error) {
    console.error('Error in subscription renewal job:', error);
  }
};
