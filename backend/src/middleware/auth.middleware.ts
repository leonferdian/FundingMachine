import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import config from '../config/config';
import { AuthUser } from '../types/user';

/**
 * Middleware to authenticate JWT tokens
 */
export const authMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): Response | void => {
  try {
    // Get token from header
    const authHeader = req.headers.authorization;
    const token = authHeader?.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No authentication token, authorization denied.',
      });
    }

    // Verify token
    const decoded = jwt.verify(token, config.jwt.secret) as { user: any };
    req.user = decoded.user;
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(401).json({
      success: false,
      message: 'Token is not valid or has expired.',
    });
  }
};

/**
 * Middleware to check if user has required role
 */
export const roleMiddleware = (roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction): Response | void => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required.',
      });
    }

    if (roles.length > 0 && !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Insufficient permissions to access this resource.',
      });
    }

    next();
  };
};
