import { Request, Response, NextFunction, RequestHandler } from 'express';
import { validationResult, ValidationChain } from 'express-validator';

// Type for validation error response
type ValidationErrorResponse = {
  field: string;
  message: string;
  value?: any;
};

/**
 * Middleware to handle validation errors
 */
export const validate = (validations: ValidationChain[]): RequestHandler[] => {
  return [
    // Run all validations
    ...validations,
    
    // Process validation results
    (req: Request, res: Response, next: NextFunction) => {
      const errors = validationResult(req);
      
      if (errors.isEmpty()) {
        return next();
      }

      // Format validation errors
      const errorMessages = errors.array().map((err: any) => ({
        field: err.param || 'unknown',
        message: err.msg,
        value: err.value,
      }));

      // 422 Unprocessable Entity
      return res.status(422).json({
        success: false,
        message: 'Validation failed',
        errors: errorMessages,
      });
    }
  ];
};

/**
 * Middleware to handle validation errors (legacy)
 */
export const handleValidationErrors = (req: Request, res: Response, next: NextFunction) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map((err: any) => ({
      field: err.param || 'unknown',
      message: err.msg,
      value: err.value,
    }));

    return res.status(400).json({
      success: false,
      message: 'Validation error',
      errors: errorMessages,
    });
  }
  next();
};

/**
 * Common validation rules
 */
export const commonValidations = {
  email: {
    isEmail: {
      errorMessage: 'Please provide a valid email address',
    },
    normalizeEmail: true,
  },
  password: {
    isLength: {
      options: { min: 8 },
      errorMessage: 'Password must be at least 8 characters long',
    },
    matches: {
      options: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$/,
      errorMessage: 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character',
    },
  },
  name: {
    isLength: {
      options: { min: 2, max: 50 },
      errorMessage: 'Name must be between 2 and 50 characters',
    },
    trim: true,
    escape: true,
  },
  phone: {
    isMobilePhone: {
      options: ['any', { strictMode: false }],
      errorMessage: 'Please provide a valid phone number',
    },
  },
  uuid: {
    isUUID: {
      options: ['4'],
      errorMessage: 'Invalid ID format',
    },
  },
  positiveNumber: {
    isInt: {
      options: { min: 0 },
      errorMessage: 'Must be a positive number',
    },
    toInt: true,
  },
};
