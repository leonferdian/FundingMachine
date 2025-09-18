import { Router } from 'express';
import { body, param } from 'express-validator';
import * as subscriptionController from '../controllers/subscription.controller';
import { protect } from '../utils/jwt';

// Define SubscriptionStatus enum locally
const SubscriptionStatus = {
  ACTIVE: 'ACTIVE',
  CANCELLED: 'CANCELLED',
  EXPIRED: 'EXPIRED',
  PAYMENT_FAILED: 'PAYMENT_FAILED',
  RENEWED: 'RENEWED',
} as const;

type SubscriptionStatus = typeof SubscriptionStatus[keyof typeof SubscriptionStatus];

const router = Router();

// Apply protect middleware to all routes
router.use(protect);

/**
 * @route   GET /api/subscriptions/plans
 * @desc    Get available subscription plans
 * @access  Public
 */
router.get('/plans', subscriptionController.getSubscriptionPlans);

/**
 * @route   GET /api/subscriptions/current
 * @desc    Get current user's active subscription
 * @access  Private
 */
router.get('/current', subscriptionController.getCurrentSubscription);

/**
 * @route   POST /api/subscriptions
 * @desc    Create a new subscription
 * @access  Private
 */
router.post(
  '/',
  [
    body('planId', 'Plan ID is required')
      .isString()
      .isIn(['plan_monthly', 'plan_quarterly', 'plan_annual'])
      .withMessage('Invalid plan ID'),
    body('paymentMethod', 'Payment method is required').isString(),
  ],
  subscriptionController.createSubscription
);

/**
 * @route   PATCH /api/subscriptions/:id/cancel
 * @desc    Cancel a subscription
 * @access  Private
 */
router.patch(
  '/:id/cancel',
  [param('id', 'Invalid subscription ID').isUUID()],
  subscriptionController.cancelSubscription
);

/**
 * @route   PATCH /api/subscriptions/:id/auto-renew
 * @desc    Update auto-renew setting for a subscription
 * @access  Private
 */
router.patch(
  '/:id/auto-renew',
  [
    param('id', 'Invalid subscription ID').isUUID(),
    body('autoRenew', 'Auto-renew must be a boolean').isBoolean(),
  ],
  subscriptionController.updateAutoRenew
);

// Note: The processSubscriptionRenewals endpoint is not exposed as a route
// It should be called by a scheduled job (e.g., using node-cron or similar)

// Example of how to set up the scheduled job (in your server.ts or similar):
// import { processSubscriptionRenewals } from './controllers/subscription.controller';
// import cron from 'node-cron';
// 
// // Run every day at 2 AM
// cron.schedule('0 2 * * *', async () => {
//   console.log('Running subscription renewal job...');
//   await processSubscriptionRenewals();
// });

export default router;
