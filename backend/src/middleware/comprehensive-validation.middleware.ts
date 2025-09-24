import { Request, Response, NextFunction } from 'express';
import { validationResult } from 'express-validator';
import { userValidation, paymentMethodValidation, bankAccountValidation, fundingPlatformValidation, transactionValidation, subscriptionValidation, aiValidation, queryValidation } from '../validations/comprehensive.validations';

// Validation middleware factory
export const validateRequest = (validations: any[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    // Run all validations
    await Promise.all(validations.map(validation => validation.run(req)));

    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array().map(error => ({
          field: (error as any).path || (error as any).param || 'unknown',
          message: error.msg,
          value: (error as any).value || req.body[(error as any).param] || 'unknown',
        })),
      });
    }

    next();
  };
};

// Specific validation middleware for each endpoint
export const validateUserCreate = validateRequest(userValidation.create);
export const validateUserLogin = validateRequest(userValidation.login);
export const validateUserUpdate = validateRequest(userValidation.update);
export const validateUserGetById = validateRequest(userValidation.getById);

export const validatePaymentMethodCreate = validateRequest(paymentMethodValidation.create);
export const validatePaymentMethodUpdate = validateRequest(paymentMethodValidation.update);
export const validatePaymentMethodGetById = validateRequest(paymentMethodValidation.getById);
export const validatePaymentMethodSetDefault = validateRequest(paymentMethodValidation.setDefault);

export const validateBankAccountCreate = validateRequest(bankAccountValidation.create);
export const validateBankAccountUpdate = validateRequest(bankAccountValidation.update);
export const validateBankAccountGetById = validateRequest(bankAccountValidation.getById);

export const validateFundingPlatformCreate = validateRequest(fundingPlatformValidation.create);
export const validateFundingPlatformUpdate = validateRequest(fundingPlatformValidation.update);
export const validateFundingPlatformGetById = validateRequest(fundingPlatformValidation.getById);

export const validateTransactionCreate = validateRequest(transactionValidation.create);
export const validateTransactionUpdate = validateRequest(transactionValidation.update);
export const validateTransactionGetById = validateRequest(transactionValidation.getById);

export const validateSubscriptionCreate = validateRequest(subscriptionValidation.create);
export const validateSubscriptionUpdate = validateRequest(subscriptionValidation.update);
export const validateSubscriptionGetById = validateRequest(subscriptionValidation.getById);

export const validateAIGenerateResponse = validateRequest(aiValidation.generateResponse);
export const validateAIAnalyzeTransactions = validateRequest(aiValidation.analyzeTransactions);
export const validateAIGenerateRecommendations = validateRequest(aiValidation.generateRecommendations);
export const validateAIDetectFraud = validateRequest(aiValidation.detectFraud);
export const validateAIGenerateSummary = validateRequest(aiValidation.generateSummary);
export const validateAIUserQuery = validateRequest(aiValidation.userQuery);

// Query parameter validation middleware
export const validatePagination = validateRequest(queryValidation.pagination);
export const validateSearch = validateRequest(queryValidation.search);
export const validateFilters = validateRequest(queryValidation.filters);

// Combined validation middleware for endpoints that need multiple types of validation
export const validatePaymentMethodList = [
  validatePagination,
  validateSearch,
  validateFilters,
];

// Custom validation middleware for specific business rules
export const validatePasswordStrength = (req: Request, res: Response, next: NextFunction) => {
  const { password } = req.body;

  if (password) {
    const errors: string[] = [];

    if (password.length < 8) {
      errors.push('Password must be at least 8 characters long');
    }

    if (!/(?=.*[a-z])/.test(password)) {
      errors.push('Password must contain at least one lowercase letter');
    }

    if (!/(?=.*[A-Z])/.test(password)) {
      errors.push('Password must contain at least one uppercase letter');
    }

    if (!/(?=.*\d)/.test(password)) {
      errors.push('Password must contain at least one number');
    }

    if (!/(?=.*[@$!%*?&])/.test(password)) {
      errors.push('Password must contain at least one special character');
    }

    if (errors.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Password does not meet security requirements',
        errors,
      });
    }
  }

  next();
};

export const validatePaymentMethodOwnership = (req: Request, res: Response, next: NextFunction) => {
  // This middleware would typically check if the payment method belongs to the authenticated user
  // For now, we'll just pass through
  next();
};

export const validateSufficientFunds = (req: Request, res: Response, next: NextFunction) => {
  const { amount } = req.body;

  // This middleware would check if the user has sufficient funds for the transaction
  // For now, we'll just pass through
  next();
};

export const validateTransactionLimits = (req: Request, res: Response, next: NextFunction) => {
  const { amount, type } = req.body;

  // Daily transaction limits
  const dailyLimits = {
    DEPOSIT: 10000,
    WITHDRAWAL: 5000,
    INVESTMENT: 25000,
  };

  if (amount && type && dailyLimits[type as keyof typeof dailyLimits]) {
    const limit = dailyLimits[type as keyof typeof dailyLimits];

    if (amount > limit) {
      return res.status(400).json({
        success: false,
        message: `Transaction amount exceeds daily limit of $${limit} for ${type.toLowerCase()} transactions`,
      });
    }
  }

  next();
};

// Rate limiting validation middleware
export const validateRateLimit = (req: Request, res: Response, next: NextFunction) => {
  // This would integrate with express-rate-limit or similar
  // For now, we'll just pass through
  next();
};

// File upload validation middleware
export const validateFileUpload = (req: Request, res: Response, next: NextFunction) => {
  // This would validate file uploads (size, type, etc.)
  // For now, we'll just pass through
  next();
};

// Sanitization middleware
export const sanitizeInput = (req: Request, res: Response, next: NextFunction) => {
  // Sanitize input data to prevent XSS and other attacks
  if (req.body) {
    Object.keys(req.body).forEach(key => {
      if (typeof req.body[key] === 'string') {
        // Basic sanitization - remove HTML tags and escape special characters
        req.body[key] = req.body[key]
          .replace(/<[^>]*>/g, '') // Remove HTML tags
          .replace(/[&<>"']/g, (match) => {
            const escapeChars: { [key: string]: string } = {
              '&': '&amp;',
              '<': '&lt;',
              '>': '&gt;',
              '"': '&quot;',
              "'": '&#x27;',
            };
            return escapeChars[match];
          });
      }
    });
  }

  next();
};

// Error handling middleware for validation errors
export const handleValidationError = (error: any, req: Request, res: Response, next: NextFunction) => {
  if (error.name === 'ValidationError') {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: error.errors || [error.message],
    });
  }

  next(error);
};

// Comprehensive validation middleware that combines multiple validations
export const comprehensiveValidation = (req: Request, res: Response, next: NextFunction) => {
  // Apply sanitization first
  sanitizeInput(req, res, (err) => {
    if (err) return next(err);

    // Apply rate limiting
    validateRateLimit(req, res, (err) => {
      if (err) return next(err);

      next();
    });
  });
};
