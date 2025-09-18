import { Request, Response, NextFunction } from 'express';
import { validationResult, ValidationChain } from 'express-validator';

export const validationMiddleware = (validations: ValidationChain[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    // Run all validations
    await Promise.all(validations.map(validation => validation.run(req)));

    // Check for validation errors
    const errors = validationResult(req);
    if (errors.isEmpty()) {
      return next();
    }

    // Format validation errors
    const errorMessages = errors.array().map(error => {
      // Check if it's a standard validation error
      if ('param' in error) {
        return {
          field: error.param,
          message: error.msg,
          value: (error as any).value,
          location: (error as any).location,
        };
      }
      // Handle alternative validation errors
      return {
        message: error.msg,
      };
    });

    // Return validation errors (422 Unprocessable Entity)
    return res.status(422).json({
      success: false,
      message: 'Validation failed',
      errors: errorMessages,
    });
  };
};

/**
 * Middleware to validate request body against a schema
 */
export const validate = (schema: any) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body, { abortEarly: false });
    
    if (error) {
      const errorMessages = error.details.map((detail: any) => ({
        field: detail.path.join('.'),
        message: detail.message,
        type: detail.type,
      }));

      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errorMessages,
      });
    }

    next();
  };
};
