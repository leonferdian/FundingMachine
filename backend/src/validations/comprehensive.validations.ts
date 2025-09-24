import { body, param, query } from 'express-validator';

// User validation schemas
export const userValidation = {
  create: [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email is required'),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      .withMessage('Password must contain at least one uppercase letter, one lowercase letter, and one number'),
    body('firstName')
      .trim()
      .isLength({ min: 1, max: 50 })
      .withMessage('First name is required and must be 1-50 characters'),
    body('lastName')
      .trim()
      .isLength({ min: 1, max: 50 })
      .withMessage('Last name is required and must be 1-50 characters'),
  ],

  login: [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email is required'),
    body('password')
      .notEmpty()
      .withMessage('Password is required'),
  ],

  update: [
    body('firstName')
      .optional()
      .trim()
      .isLength({ min: 1, max: 50 })
      .withMessage('First name must be 1-50 characters'),
    body('lastName')
      .optional()
      .trim()
      .isLength({ min: 1, max: 50 })
      .withMessage('Last name must be 1-50 characters'),
    body('email')
      .optional()
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid email format required'),
  ],

  getById: [
    param('id')
      .isUUID()
      .withMessage('Invalid user ID format'),
  ],
};

// Payment method validation schemas
export const paymentMethodValidation = {
  create: [
    body('type')
      .isIn(['CARD', 'PAYPAL', 'BANK_ACCOUNT', 'DIGITAL_WALLET', 'CRYPTO'])
      .withMessage('Invalid payment method type'),
    body('provider')
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Provider is required and must be 1-100 characters'),

    // Card-specific validations
    body('cardNumber')
      .if(body('type').equals('CARD'))
      .isLength({ min: 13, max: 19 })
      .isNumeric()
      .withMessage('Card number must be 13-19 digits'),
    body('expiryMonth')
      .if(body('type').equals('CARD'))
      .isInt({ min: 1, max: 12 })
      .withMessage('Expiry month must be 1-12'),
    body('expiryYear')
      .if(body('type').equals('CARD'))
      .isInt({ min: new Date().getFullYear() })
      .withMessage('Expiry year must be current year or later'),
    body('cvv')
      .if(body('type').equals('CARD'))
      .isLength({ min: 3, max: 4 })
      .isNumeric()
      .withMessage('CVV must be 3-4 digits'),
    body('holderName')
      .if(body('type').equals('CARD'))
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Holder name is required'),

    // PayPal validations
    body('paypalEmail')
      .if(body('type').equals('PAYPAL'))
      .isEmail()
      .normalizeEmail()
      .withMessage('Valid PayPal email is required'),

    // Bank account validations
    body('accountNumber')
      .if(body('type').equals('BANK_ACCOUNT'))
      .isLength({ min: 8, max: 20 })
      .isNumeric()
      .withMessage('Account number must be 8-20 digits'),
    body('routingNumber')
      .if(body('type').equals('BANK_ACCOUNT'))
      .isLength({ min: 9, max: 9 })
      .isNumeric()
      .withMessage('Routing number must be 9 digits'),
    body('bankName')
      .if(body('type').equals('BANK_ACCOUNT'))
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Bank name is required'),

    // Digital wallet validations
    body('walletAddress')
      .if(body('type').equals('DIGITAL_WALLET'))
      .trim()
      .isLength({ min: 10, max: 100 })
      .withMessage('Wallet address is required'),
    body('walletType')
      .if(body('type').equals('DIGITAL_WALLET'))
      .isIn(['VENMO', 'CASH_APP', 'ZELLE', 'OTHER'])
      .withMessage('Valid wallet type is required'),

    // Crypto validations
    body('cryptoAddress')
      .if(body('type').equals('CRYPTO'))
      .trim()
      .isLength({ min: 20, max: 100 })
      .withMessage('Crypto address is required'),
    body('cryptoType')
      .if(body('type').equals('CRYPTO'))
      .isIn(['BITCOIN', 'ETHEREUM', 'LITE_COIN', 'OTHER'])
      .withMessage('Valid crypto type is required'),

    body('isDefault')
      .optional()
      .isBoolean()
      .withMessage('isDefault must be a boolean'),
  ],

  update: [
    param('id')
      .isUUID()
      .withMessage('Invalid payment method ID format'),
    body('provider')
      .optional()
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Provider must be 1-100 characters'),
    body('isDefault')
      .optional()
      .isBoolean()
      .withMessage('isDefault must be a boolean'),
  ],

  getById: [
    param('id')
      .isUUID()
      .withMessage('Invalid payment method ID format'),
  ],

  setDefault: [
    param('id')
      .isUUID()
      .withMessage('Invalid payment method ID format'),
  ],
};

// Bank account validation schemas
export const bankAccountValidation = {
  create: [
    body('bankName')
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Bank name is required'),
    body('accountNumber')
      .isLength({ min: 8, max: 20 })
      .isNumeric()
      .withMessage('Account number must be 8-20 digits'),
    body('routingNumber')
      .isLength({ min: 9, max: 9 })
      .isNumeric()
      .withMessage('Routing number must be 9 digits'),
    body('accountType')
      .isIn(['CHECKING', 'SAVINGS', 'BUSINESS_CHECKING', 'BUSINESS_SAVINGS'])
      .withMessage('Invalid account type'),
    body('isDefault')
      .optional()
      .isBoolean()
      .withMessage('isDefault must be a boolean'),
  ],

  update: [
    param('id')
      .isUUID()
      .withMessage('Invalid bank account ID format'),
    body('bankName')
      .optional()
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Bank name must be 1-100 characters'),
    body('accountType')
      .optional()
      .isIn(['CHECKING', 'SAVINGS', 'BUSINESS_CHECKING', 'BUSINESS_SAVINGS'])
      .withMessage('Invalid account type'),
    body('isDefault')
      .optional()
      .isBoolean()
      .withMessage('isDefault must be a boolean'),
  ],

  getById: [
    param('id')
      .isUUID()
      .withMessage('Invalid bank account ID format'),
  ],
};

// Funding platform validation schemas
export const fundingPlatformValidation = {
  create: [
    body('name')
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Platform name is required'),
    body('description')
      .trim()
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be 10-1000 characters'),
    body('website')
      .optional()
      .isURL()
      .withMessage('Valid website URL is required'),
    body('category')
      .isIn(['P2P_LENDING', 'CROWDFUNDING', 'REAL_ESTATE', 'STOCKS', 'CRYPTO', 'OTHER'])
      .withMessage('Invalid platform category'),
    body('minimumInvestment')
      .isFloat({ min: 0 })
      .withMessage('Minimum investment must be a positive number'),
    body('expectedReturn')
      .isFloat({ min: 0, max: 100 })
      .withMessage('Expected return must be between 0-100%'),
    body('riskLevel')
      .isIn(['LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH'])
      .withMessage('Invalid risk level'),
    body('features')
      .optional()
      .isArray()
      .withMessage('Features must be an array'),
    body('features.*')
      .optional()
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Each feature must be 1-100 characters'),
  ],

  update: [
    param('id')
      .isUUID()
      .withMessage('Invalid platform ID format'),
    body('name')
      .optional()
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Platform name must be 1-100 characters'),
    body('description')
      .optional()
      .trim()
      .isLength({ min: 10, max: 1000 })
      .withMessage('Description must be 10-1000 characters'),
    body('website')
      .optional()
      .isURL()
      .withMessage('Valid website URL required'),
    body('category')
      .optional()
      .isIn(['P2P_LENDING', 'CROWDFUNDING', 'REAL_ESTATE', 'STOCKS', 'CRYPTO', 'OTHER'])
      .withMessage('Invalid platform category'),
    body('minimumInvestment')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Minimum investment must be a positive number'),
    body('expectedReturn')
      .optional()
      .isFloat({ min: 0, max: 100 })
      .withMessage('Expected return must be between 0-100%'),
    body('riskLevel')
      .optional()
      .isIn(['LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH'])
      .withMessage('Invalid risk level'),
  ],

  getById: [
    param('id')
      .isUUID()
      .withMessage('Invalid platform ID format'),
  ],
};

// Transaction validation schemas
export const transactionValidation = {
  create: [
    body('amount')
      .isFloat({ min: 0.01 })
      .withMessage('Amount must be greater than 0'),
    body('type')
      .isIn(['DEPOSIT', 'WITHDRAWAL', 'INVESTMENT', 'RETURN', 'FEE', 'OTHER'])
      .withMessage('Invalid transaction type'),
    body('description')
      .trim()
      .isLength({ min: 1, max: 500 })
      .withMessage('Description is required and must be 1-500 characters'),
    body('paymentMethodId')
      .optional()
      .isUUID()
      .withMessage('Invalid payment method ID'),
    body('fundingPlatformId')
      .optional()
      .isUUID()
      .withMessage('Invalid funding platform ID'),
    body('bankAccountId')
      .optional()
      .isUUID()
      .withMessage('Invalid bank account ID'),
  ],

  update: [
    param('id')
      .isUUID()
      .withMessage('Invalid transaction ID format'),
    body('amount')
      .optional()
      .isFloat({ min: 0.01 })
      .withMessage('Amount must be greater than 0'),
    body('description')
      .optional()
      .trim()
      .isLength({ min: 1, max: 500 })
      .withMessage('Description must be 1-500 characters'),
  ],

  getById: [
    param('id')
      .isUUID()
      .withMessage('Invalid transaction ID format'),
  ],
};

// Subscription validation schemas
export const subscriptionValidation = {
  create: [
    body('plan')
      .isIn(['BASIC', 'PREMIUM', 'ENTERPRISE'])
      .withMessage('Invalid subscription plan'),
    body('billingCycle')
      .isIn(['MONTHLY', 'YEARLY'])
      .withMessage('Invalid billing cycle'),
    body('paymentMethodId')
      .isUUID()
      .withMessage('Valid payment method ID is required'),
  ],

  update: [
    param('id')
      .isUUID()
      .withMessage('Invalid subscription ID format'),
    body('plan')
      .optional()
      .isIn(['BASIC', 'PREMIUM', 'ENTERPRISE'])
      .withMessage('Invalid subscription plan'),
    body('billingCycle')
      .optional()
      .isIn(['MONTHLY', 'YEARLY'])
      .withMessage('Invalid billing cycle'),
    body('paymentMethodId')
      .optional()
      .isUUID()
      .withMessage('Valid payment method ID required'),
  ],

  getById: [
    param('id')
      .isUUID()
      .withMessage('Invalid subscription ID format'),
  ],
};

// AI validation schemas
export const aiValidation = {
  generateResponse: [
    body('prompt')
      .trim()
      .isLength({ min: 1, max: 2000 })
      .withMessage('Prompt is required and must be 1-2000 characters'),
    body('context')
      .optional()
      .isObject()
      .withMessage('Context must be an object'),
    body('systemMessage')
      .optional()
      .trim()
      .isLength({ min: 1, max: 500 })
      .withMessage('System message must be 1-500 characters'),
  ],

  analyzeTransactions: [
    body('userId')
      .isUUID()
      .withMessage('Valid user ID is required'),
    body('transactions')
      .isArray({ min: 1 })
      .withMessage('Transactions array is required and must not be empty'),
    body('transactions.*.id')
      .isUUID()
      .withMessage('Each transaction must have a valid ID'),
    body('transactions.*.amount')
      .isFloat()
      .withMessage('Each transaction must have a valid amount'),
  ],

  generateRecommendations: [
    body('userProfile')
      .isObject()
      .withMessage('User profile object is required'),
    body('userProfile.age')
      .isInt({ min: 18, max: 120 })
      .withMessage('Age must be between 18 and 120'),
    body('userProfile.riskTolerance')
      .optional()
      .isIn(['LOW', 'MEDIUM', 'HIGH'])
      .withMessage('Invalid risk tolerance level'),
  ],

  detectFraud: [
    body('transaction')
      .isObject()
      .withMessage('Transaction object is required'),
    body('userHistory')
      .isArray()
      .withMessage('User history array is required'),
  ],

  generateSummary: [
    body('userId')
      .isUUID()
      .withMessage('Valid user ID is required'),
    body('financialData')
      .isObject()
      .withMessage('Financial data object is required'),
  ],

  userQuery: [
    body('query')
      .trim()
      .isLength({ min: 1, max: 1000 })
      .withMessage('Query is required and must be 1-1000 characters'),
    body('userContext')
      .optional()
      .isObject()
      .withMessage('User context must be an object'),
  ],
};

// Query parameter validations
export const queryValidation = {
  pagination: [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Page must be a positive integer'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100'),
    query('sortBy')
      .optional()
      .isIn(['createdAt', 'updatedAt', 'name', 'amount', 'date'])
      .withMessage('Invalid sort field'),
    query('sortOrder')
      .optional()
      .isIn(['asc', 'desc', 'ASC', 'DESC'])
      .withMessage('Sort order must be asc or desc'),
  ],

  search: [
    query('search')
      .optional()
      .trim()
      .isLength({ min: 1, max: 100 })
      .withMessage('Search term must be 1-100 characters'),
  ],

  filters: [
    query('type')
      .optional()
      .isIn(['CARD', 'PAYPAL', 'BANK_ACCOUNT', 'DIGITAL_WALLET', 'CRYPTO'])
      .withMessage('Invalid payment method type filter'),
    query('isDefault')
      .optional()
      .isBoolean()
      .withMessage('isDefault filter must be boolean'),
    query('startDate')
      .optional()
      .isISO8601()
      .withMessage('Invalid start date format'),
    query('endDate')
      .optional()
      .isISO8601()
      .withMessage('Invalid end date format'),
  ],
};
