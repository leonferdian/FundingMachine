import { Router } from 'express';
import { body, param, query } from 'express-validator';
import * as fundingController from '../controllers/funding.controller';
import { protect } from '../utils/jwt';

// Define FundingStatus enum locally
const FundingStatus = {
  ACTIVE: 'ACTIVE',
  PAUSED: 'PAUSED',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
} as const;

type FundingStatus = typeof FundingStatus[keyof typeof FundingStatus];

const router = Router();

// Apply protect middleware to all routes
router.use(protect);

/**
 * @route   POST /api/funding
 * @desc    Create a new funding
 * @access  Private
 */
router.post(
  '/',
  [
    body('platformId', 'Platform ID is required').isUUID(),
    body('amount', 'Amount must be a positive number').isFloat({ min: 0 }),
    body('profitShare', 'Profit share must be a number between 0 and 100')
      .optional()
      .isFloat({ min: 0, max: 100 }),
  ],
  fundingController.createFunding
);

/**
 * @route   GET /api/funding
 * @desc    Get all fundings for the current user
 * @access  Private
 */
router.get(
  '/',
  [
    query('status')
      .optional()
      .isIn(Object.values(FundingStatus))
      .withMessage(`Status must be one of: ${Object.values(FundingStatus).join(', ')}`),
  ],
  fundingController.getUserFundings
);

/**
 * @route   GET /api/funding/:id
 * @desc    Get funding by ID
 * @access  Private
 */
router.get(
  '/:id',
  [param('id', 'Invalid funding ID').isUUID()],
  fundingController.getFundingById
);

/**
 * @route   PATCH /api/funding/:id/status
 * @desc    Update funding status
 * @access  Private
 */
router.patch(
  '/:id/status',
  [
    param('id', 'Invalid funding ID').isUUID(),
    body('status', `Status must be one of: ${Object.values(FundingStatus).join(', ')}`)
      .isIn(Object.values(FundingStatus)),
  ],
  fundingController.updateFundingStatus
);

/**
 * @route   POST /api/funding/:id/profit
 * @desc    Record profit for a funding
 * @access  Private
 */
router.post(
  '/:id/profit',
  [
    param('id', 'Invalid funding ID').isUUID(),
    body('amount', 'Amount must be a positive number').isFloat({ min: 0 }),
    body('description', 'Description is required').optional().isString(),
  ],
  fundingController.recordProfit
);

export default router;
