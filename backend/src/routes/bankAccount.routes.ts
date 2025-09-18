import { Router } from 'express';
import { body, param } from 'express-validator';
import * as bankAccountController from '../controllers/bankAccount.controller';
import { protect } from '../utils/jwt';

const router = Router();

// Apply protect middleware to all routes
router.use(protect);

/**
 * @route   POST /api/bank-accounts
 * @desc    Add a new bank account
 * @access  Private
 */
router.post(
  '/',
  [
    body('bankCode', 'Bank code is required').not().isEmpty(),
    body('accountNumber', 'Account number is required').not().isEmpty(),
    body('accountName', 'Account name is required').not().isEmpty(),
    body('isDefault', 'isDefault must be a boolean').optional().isBoolean(),
  ],
  bankAccountController.addBankAccount
);

/**
 * @route   GET /api/bank-accounts
 * @desc    Get all bank accounts for the current user
 * @access  Private
 */
router.get('/', bankAccountController.getBankAccounts);

/**
 * @route   PUT /api/bank-accounts/:id
 * @desc    Update a bank account
 * @access  Private
 */
router.put(
  '/:id',
  [
    param('id', 'Invalid bank account ID').isUUID(),
    body('bankCode', 'Bank code is required').optional().not().isEmpty(),
    body('accountNumber', 'Account number is required').optional().not().isEmpty(),
    body('accountName', 'Account name is required').optional().not().isEmpty(),
    body('isDefault', 'isDefault must be a boolean').optional().isBoolean(),
  ],
  bankAccountController.updateBankAccount
);

/**
 * @route   DELETE /api/bank-accounts/:id
 * @desc    Delete a bank account
 * @access  Private
 */
router.delete(
  '/:id',
  [param('id', 'Invalid bank account ID').isUUID()],
  bankAccountController.deleteBankAccount
);

/**
 * @route   PATCH /api/bank-accounts/:id/set-default
 * @desc    Set a bank account as default
 * @access  Private
 */
router.patch(
  '/:id/set-default',
  [param('id', 'Invalid bank account ID').isUUID()],
  bankAccountController.setDefaultBankAccount
);

export default router;
