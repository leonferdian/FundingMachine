import { Router } from 'express';
import { body, param } from 'express-validator';
import * as paymentMethodController from '../controllers/paymentMethod.controller';
import { protect } from '../utils/jwt';

const PaymentMethodType = {
  CARD: 'CARD',
  PAYPAL: 'PAYPAL',
  BANK_ACCOUNT: 'BANK_ACCOUNT',
  DIGITAL_WALLET: 'DIGITAL_WALLET',
  CRYPTO: 'CRYPTO',
} as const;

type PaymentMethodType = typeof PaymentMethodType[keyof typeof PaymentMethodType];

const router = Router();

// Apply protect middleware to all routes
router.use(protect);

/**
 * @route   GET /api/payment-methods
 * @desc    Get all payment methods for the current user
 * @access  Private
 */
router.get('/', paymentMethodController.getPaymentMethods);

/**
 * @route   GET /api/payment-methods/:id
 * @desc    Get payment method by ID
 * @access  Private
 */
router.get(
  '/:id',
  [param('id', 'Invalid payment method ID').isUUID()],
  paymentMethodController.getPaymentMethodById
);

/**
 * @route   POST /api/payment-methods
 * @desc    Create a new payment method
 * @access  Private
 */
router.post(
  '/',
  [
    body('type', `Type must be one of: ${Object.values(PaymentMethodType).join(', ')}`)
      .isIn(Object.values(PaymentMethodType)),
    // Card-specific validation
    body('cardNumber')
      .if(body('type').equals('CARD'))
      .isLength({ min: 13, max: 19 })
      .withMessage('Card number must be between 13 and 19 digits')
      .matches(/^\d+$/)
      .withMessage('Card number must contain only digits'),
    body('expiryMonth')
      .if(body('type').equals('CARD'))
      .isInt({ min: 1, max: 12 })
      .withMessage('Expiry month must be between 1 and 12'),
    body('expiryYear')
      .if(body('type').equals('CARD'))
      .isInt({ min: new Date().getFullYear() })
      .withMessage('Expiry year must be current year or later'),
    body('cvv')
      .if(body('type').equals('CARD'))
      .isLength({ min: 3, max: 4 })
      .withMessage('CVV must be 3 or 4 digits')
      .matches(/^\d+$/)
      .withMessage('CVV must contain only digits'),
    body('holderName')
      .if(body('type').equals('CARD'))
      .notEmpty()
      .withMessage('Cardholder name is required'),
    // PayPal-specific validation
    body('paypalEmail')
      .if(body('type').equals('PAYPAL'))
      .isEmail()
      .withMessage('Valid PayPal email is required'),
    // Bank account-specific validation
    body('bankAccountNumber')
      .if(body('type').equals('BANK_ACCOUNT'))
      .notEmpty()
      .withMessage('Bank account number is required'),
    body('bankRoutingNumber')
      .if(body('type').equals('BANK_ACCOUNT'))
      .notEmpty()
      .withMessage('Bank routing number is required'),
  ],
  paymentMethodController.createPaymentMethod
);

/**
 * @route   PUT /api/payment-methods/:id
 * @desc    Update a payment method
 * @access  Private
 */
router.put(
  '/:id',
  [
    param('id', 'Invalid payment method ID').isUUID(),
    body('isDefault').optional().isBoolean().withMessage('isDefault must be a boolean'),
    body('isActive').optional().isBoolean().withMessage('isActive must be a boolean'),
  ],
  paymentMethodController.updatePaymentMethod
);

/**
 * @route   DELETE /api/payment-methods/:id
 * @desc    Delete a payment method
 * @access  Private
 */
router.delete(
  '/:id',
  [param('id', 'Invalid payment method ID').isUUID()],
  paymentMethodController.deletePaymentMethod
);

/**
 * @route   PATCH /api/payment-methods/:id/default
 * @desc    Set payment method as default
 * @access  Private
 */
router.patch(
  '/:id/default',
  [param('id', 'Invalid payment method ID').isUUID()],
  paymentMethodController.setDefaultPaymentMethod
);

export default router;
