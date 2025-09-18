import { Router } from 'express';
import * as authController from '../controllers/auth.controller';
import { protect } from '../utils/jwt';
import { validate } from '../middleware/validation';
import {
  registerValidation,
  loginValidation,
  refreshTokenValidation,
  forgotPasswordValidation,
  resetPasswordValidation
} from '../validations/auth.validations';

const router = Router();

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post(
  '/register',
  [
    ...registerValidation,
    validate
  ],
  authController.register
);

/**
 * @route   POST /api/auth/login
 * @desc    Authenticate user & get token
 * @access  Public
 */
router.post(
  '/login',
  [
    ...loginValidation,
    validate
  ],
  authController.login
);

/**
 * @route   POST /api/auth/refresh-token
 * @desc    Get new access token using refresh token
 * @access  Public
 */
router.post(
  '/refresh-token',
  [
    ...refreshTokenValidation,
    validate
  ],
  authController.refreshToken
);

/**
 * @route   POST /api/auth/forgot-password
 * @desc    Request password reset
 * @access  Public
 */
router.post(
  '/forgot-password',
  [
    ...forgotPasswordValidation,
    validate
  ],
  authController.forgotPassword
);

/**
 * @route   POST /api/auth/reset-password
 * @desc    Reset user password
 * @access  Public
 */
router.post(
  '/reset-password',
  [
    ...resetPasswordValidation,
    validate
  ],
  authController.resetPassword
);

/**
 * @route   GET /api/auth/me
 * @desc    Get current user
 * @access  Private
 */
router.get('/me', protect, authController.getMe);

/**
 * @route   GET /api/auth/verify-token
 * @desc    Verify token and get user data
 * @access  Private
 */
router.get('/verify-token', protect, authController.verifyToken);

export default router;
