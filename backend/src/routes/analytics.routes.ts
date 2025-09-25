import { Router } from 'express';
import { AnalyticsController } from '../controllers/analytics.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const analyticsController = new AnalyticsController();

// Apply authentication middleware to all routes
router.use(authMiddleware);

// Analytics tracking endpoints
router.post('/track', analyticsController.trackEvent.bind(analyticsController));
router.post('/track/funding', analyticsController.trackFundingInteraction.bind(analyticsController));

// Data retrieval endpoints
router.get('/user', analyticsController.getUserAnalytics.bind(analyticsController));
router.get('/funding', analyticsController.getFundingAnalytics.bind(analyticsController));
router.get('/system', analyticsController.getSystemMetrics.bind(analyticsController));

// Report generation endpoints
router.post('/report', analyticsController.generateReport.bind(analyticsController));

export default router;
