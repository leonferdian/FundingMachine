import { Router } from 'express';
import { healthCheck, apiInfo } from '../controllers/health.controller';

const router = Router();

/**
 * @route   GET /
 * @desc    API information
 * @access  Public
 */
router.get('/', apiInfo);

/**
 * @route   GET /health
 * @desc    Health check endpoint
 * @access  Public
 */
router.get('/health', healthCheck);

export default router;
