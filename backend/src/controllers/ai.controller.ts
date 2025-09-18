import { Request, Response, NextFunction } from 'express';
import { validationResult } from 'express-validator';
import { aiService } from '@/services/ai.service';
import { authMiddleware } from '@/middleware/auth.middleware';
import { validate } from '@/middleware/validation.middleware';
import { 
  generateResponseSchema, 
  analyzeTransactionsSchema, 
  detectFraudSchema, 
  financialSummarySchema 
} from '@/schemas/ai.schema';

// Using the singleton instance of AIService

export const aiController = {
  /**
   * Generate AI response for user query
   */
  generateResponse: [
    authMiddleware,
    validate(generateResponseSchema),
    async (req: Request, res: Response, next: NextFunction) => {
      try {
        const { prompt, context } = req.body;
        const response = await aiService.generateResponse(prompt, context);
        return res.status(200).json({ success: true, data: { response } });
      } catch (error) {
        console.error('Error generating AI response:', error);
        return res.status(500).json({ 
          success: false, 
          message: 'Failed to generate AI response' 
        });
      }
    }
  ],

  /**
   * Analyze transaction patterns
   */
  analyzeTransactions: [
    authMiddleware,
    validate(analyzeTransactionsSchema),
    async (req: Request, res: Response, next: NextFunction) => {
      try {
        const { transactions } = req.body;
        const userId = req.user?.id;
        const analysis = await aiService.analyzeTransactionPatterns(userId, transactions);
        return res.status(200).json({ success: true, data: { analysis } });
      } catch (error) {
        console.error('Error analyzing transactions:', error);
        return res.status(500).json({ 
          success: false, 
          message: 'Failed to analyze transactions' 
        });
      }
    }
  ],

  /**
   * Get funding recommendations
   */
  getRecommendations: [
    authMiddleware,
    async (req: Request, res: Response, next: NextFunction) => {
      try {
        // In a real app, you would fetch the user's profile from the database
        const userProfile = {
          id: req.user?.id,
          // Add other user profile fields as needed
        };
        const recommendations = await aiService.generateFundingRecommendations(userProfile);
        return res.status(200).json({ success: true, data: { recommendations } });
      } catch (error) {
        console.error('Error getting recommendations:', error);
        return res.status(500).json({ 
          success: false, 
          message: 'Failed to get recommendations' 
        });
      }
    }
  ],

  /**
   * Check for potential fraud in a transaction
   */
  detectFraud: [
    authMiddleware,
    validate(detectFraudSchema),
    async (req: Request, res: Response, next: NextFunction) => {
      try {
        const { transaction, userHistory } = req.body;
        const fraudCheck = await aiService.detectFraud(transaction, userHistory);
        return res.status(200).json({ success: true, data: { fraudCheck } });
      } catch (error) {
        console.error('Error detecting fraud:', error);
        return res.status(500).json({ 
          success: false, 
          message: 'Failed to detect fraud' 
        });
      }
    }
  ],

  /**
   * Generate a summary of user's financial status
   */
  generateFinancialSummary: [
    authMiddleware,
    validate(financialSummarySchema),
    async (req: Request, res: Response, next: NextFunction) => {
      try {
        const userId = req.user?.id;
        const { financialData } = req.body;
        const summary = await aiService.generateFinancialSummary(userId, financialData);
        return res.status(200).json({ success: true, data: { summary } });
      } catch (error) {
        console.error('Error generating financial summary:', error);
        return res.status(500).json({ 
          success: false, 
          message: 'Failed to generate financial summary' 
        });
      }
    }
  ]
};
