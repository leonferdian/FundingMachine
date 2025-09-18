import { Router } from 'express';
import { aiController } from '../controllers/ai.controller';

const router = Router();

/**
 * @swagger
 * /api/ai/chat:
 *   post:
 *     summary: Generate AI response for user query
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - prompt
 *             properties:
 *               prompt:
 *                 type: string
 *                 description: User's prompt or question
 *               context:
 *                 type: object
 *                 description: Additional context for the AI
 *     responses:
 *       200:
 *         description: AI response generated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     response:
 *                       type: string
 */
router.post('/chat', ...aiController.generateResponse);

/**
 * @swagger
 * /api/ai/analyze/transactions:
 *   post:
 *     summary: Analyze transaction patterns
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - transactions
 *             properties:
 *               transactions:
 *                 type: array
 *                 items:
 *                   type: object
 *                 description: Array of transaction objects
 *     responses:
 *       200:
 *         description: Transaction analysis completed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     analysis:
 *                       type: string
 */
router.post('/analyze/transactions', ...aiController.analyzeTransactions);

/**
 * @swagger
 * /api/ai/recommendations:
 *   get:
 *     summary: Get funding recommendations
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Funding recommendations generated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     recommendations:
 *                       type: string
 */
router.get('/recommendations', ...aiController.getRecommendations);

/**
 * @swagger
 * /api/ai/fraud/detect:
 *   post:
 *     summary: Check for potential fraud in a transaction
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - transaction
 *             properties:
 *               transaction:
 *                 type: object
 *                 description: Transaction data to check for fraud
 *               userHistory:
 *                 type: array
 *                 items:
 *                   type: object
 *                 description: User's transaction history
 *     responses:
 *       200:
 *         description: Fraud detection completed
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     fraudCheck:
 *                       type: object
 *                       properties:
 *                         isFraud:
 *                           type: boolean
 *                         confidence:
 *                           type: number
 *                         reasons:
 *                           type: array
 *                           items:
 *                             type: string
 */
router.post('/fraud/detect', ...aiController.detectFraud);

/**
 * @swagger
 * /api/ai/summary/financial:
 *   post:
 *     summary: Generate financial summary
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - financialData
 *             properties:
 *               financialData:
 *                 type: object
 *                 description: Financial data to generate summary from
 *     responses:
 *       200:
 *         description: Financial summary generated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     summary:
 *                       type: string
 */
router.post('/summary/financial', ...aiController.generateFinancialSummary);

export default router;
