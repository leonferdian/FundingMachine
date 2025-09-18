import { Router } from 'express';
import { body, param, query } from 'express-validator';
import * as fundingPlatformController from '../controllers/fundingPlatform.controller';
import { protect, authorize } from '../utils/jwt';

// Use the same PlatformType definition as in the controller
const PlatformType = {
  ADS: 'ADS',
  SURVEY: 'SURVEY',
  INVESTMENT: 'INVESTMENT',
  AFFILIATE: 'AFFILIATE',
  OTHER: 'OTHER',
} as const;

type PlatformType = typeof PlatformType[keyof typeof PlatformType];

const router = Router();

// Public routes
router.get('/', fundingPlatformController.getFundingPlatforms);
router.get('/:id', fundingPlatformController.getFundingPlatformById);

// Protected routes (admin only)
router.use(protect);
router.use(authorize('ADMIN', 'SUPER_ADMIN'));

/**
 * @route   POST /api/funding-platforms
 * @desc    Create a new funding platform (Admin only)
 * @access  Private/Admin
 */
router.post(
  '/',
  [
    body('name', 'Name is required').not().isEmpty(),
    body('type', `Type must be one of: ${Object.values(PlatformType).join(', ')}`)
      .isIn(Object.values(PlatformType)),
    body('description', 'Description is required').optional().isString(),
    body('apiUrl', 'API URL must be a valid URL').optional().isURL(),
  ],
  fundingPlatformController.createFundingPlatform
);

/**
 * @route   PUT /api/funding-platforms/:id
 * @desc    Update a funding platform (Admin only)
 * @access  Private/Admin
 */
router.put(
  '/:id',
  [
    param('id', 'Invalid platform ID').isUUID(),
    body('name', 'Name is required').optional().not().isEmpty(),
    body('type', `Type must be one of: ${Object.values(PlatformType).join(', ')}`)
      .optional()
      .isIn(Object.values(PlatformType)),
    body('description', 'Description must be a string').optional().isString(),
    body('apiUrl', 'API URL must be a valid URL').optional().isURL(),
    body('isActive', 'isActive must be a boolean').optional().isBoolean(),
  ],
  fundingPlatformController.updateFundingPlatform
);

/**
 * @route   DELETE /api/funding-platforms/:id
 * @desc    Delete a funding platform (Admin only)
 * @access  Private/Admin
 */
router.delete(
  '/:id',
  [param('id', 'Invalid platform ID').isUUID()],
  fundingPlatformController.deleteFundingPlatform
);

export default router;
