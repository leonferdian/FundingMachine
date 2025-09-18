import { Router } from 'express';
import { query, param, body } from 'express-validator';
import * as transactionController from '../controllers/transaction.controller';
import { protect } from '../utils/jwt';

// Define TransactionType enum locally
const TransactionType = {
  DEPOSIT: 'DEPOSIT',
  WITHDRAWAL: 'WITHDRAWAL',
  PROFIT: 'PROFIT',
  SUBSCRIPTION: 'SUBSCRIPTION',
  REFUND: 'REFUND',
} as const;

type TransactionType = typeof TransactionType[keyof typeof TransactionType];

// Define TransactionStatus enum locally
const TransactionStatus = {
  PENDING: 'PENDING',
  COMPLETED: 'COMPLETED',
  FAILED: 'FAILED',
  CANCELLED: 'CANCELLED',
} as const;

type TransactionStatus = typeof TransactionStatus[keyof typeof TransactionStatus];

const router = Router();

// Apply protect middleware to all routes
router.use(protect);

/**
 * @route   GET /api/transactions
 * @desc    Get all transactions for the current user
 * @access  Private
 */
router.get(
  '/',
  [
    query('type')
      .optional()
      .isIn(Object.values(TransactionType))
      .withMessage(`Type must be one of: ${Object.values(TransactionType).join(', ')}`),
    query('status')
      .optional()
      .isIn(Object.values(TransactionStatus))
      .withMessage(`Status must be one of: ${Object.values(TransactionStatus).join(', ')}`),
    query('startDate')
      .optional()
      .isISO8601()
      .withMessage('Start date must be a valid ISO 8601 date'),
    query('endDate')
      .optional()
      .isISO8601()
      .withMessage('End date must be a valid ISO 8601 date'),
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Page must be a positive integer'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100'),
  ],
  transactionController.getTransactions
);

/**
 * @route   GET /api/transactions/summary
 * @desc    Get transaction summary for the current user
 * @access  Private
 */
router.get('/summary', transactionController.getTransactionSummary);

/**
 * @route   GET /api/transactions/:id
 * @desc    Get transaction by ID
 * @access  Private
 */
router.get(
  '/:id',
  [param('id', 'Invalid transaction ID').isUUID()],
  transactionController.getTransactionById
);

/**
 * @route   POST /api/transactions/withdraw
 * @desc    Request a withdrawal
 * @access  Private
 */
router.post(
  '/withdraw',
  [
    body('amount', 'Amount must be a positive number')
      .isFloat({ min: 10000 }) // Minimum withdrawal amount: 10,000
      .withMessage('Minimum withdrawal amount is 10,000'),
    body('bankAccountId', 'Bank account ID is required').isUUID(),
    body('description', 'Description must be a string')
      .optional()
      .isString()
      .isLength({ max: 500 })
      .withMessage('Description must be less than 500 characters'),
  ],
  transactionController.requestWithdrawal
);

export default router;
