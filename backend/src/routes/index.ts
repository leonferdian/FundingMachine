import { Router, Request, Response, NextFunction, RequestHandler } from 'express';
import { body, validationResult, ValidationChain } from 'express-validator';
import { protect } from '../utils/jwt';
import authRoutes from './auth.routes';
import bankAccountRoutes from './bankAccount.routes';
import fundingPlatformRoutes from './fundingPlatform.routes';
import fundingRoutes from './funding.routes';
import transactionRoutes from './transaction.routes';
import subscriptionRoutes from './subscription.routes';
import healthRoutes from './health.routes';
import aiRoutes from './ai.routes';
import paymentMethodRoutes from './paymentMethod.routes';
import notificationRoutes from './notification.routes';
import syncRoutes from './sync.routes';
import analyticsRoutes from './analytics.routes';

const router = Router();

// API Information
router.get('/', (req, res) => {
  res.json({
    name: 'Funding Machine API',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    documentation: 'Coming soon',
    endpoints: {
      auth: '/api/auth',
      bankAccounts: '/api/bank-accounts',
      fundingPlatforms: '/api/funding-platforms',
      fundings: '/api/funding',
      sync: '/api/sync',
      subscriptions: '/api/subscriptions',
      notifications: '/api/notifications',
      analytics: '/api/analytics',
      health: '/api/health',
      ai: {
        chat: '/api/ai/chat',
        recommendations: '/api/ai/recommendations',
        fraudDetection: '/api/ai/fraud/detect',
        financialSummary: '/api/ai/summary/financial'
      }
    }
  });
});

// Health check routes
router.use(healthRoutes);

// Simple test route to verify the server is working
router.get('/test', (req: Request, res: Response) => {
  res.json({
    success: true,
    message: 'Server is running!',
    timestamp: new Date().toISOString()
  });
});

// Test validation route (public, for testing validation middleware)
router.post('/test-validation', [
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters long'),
  body('name').notEmpty().withMessage('Name is required')
], (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((err: any) => ({
        field: err.param || 'unknown',
        message: err.msg,
        value: err.value
      }))
    });
  }
  
  // This will only be called if validation passes
  const { email, name } = req.body;
  
  res.json({
    success: true,
    message: 'Validation passed!',
    data: { email, name }
  });
});

// Public routes
router.use('/auth', authRoutes);

// Protected routes (require authentication)
router.use('/bank-accounts', protect, bankAccountRoutes);
router.use('/funding-platforms', protect, fundingPlatformRoutes);
router.use('/funding', protect, fundingRoutes);
router.use('/transactions', protect, transactionRoutes);
router.use('/subscriptions', protect, subscriptionRoutes);
router.use('/sync', protect, syncRoutes);
router.use('/notifications', protect, notificationRoutes);
router.use('/payment-methods', protect, paymentMethodRoutes);
router.use('/ai', protect, aiRoutes);
router.use('/analytics', protect, analyticsRoutes);
router.use('/health', healthRoutes);

export default router;
