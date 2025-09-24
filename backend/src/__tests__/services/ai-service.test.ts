/// <reference types="jest" />

import { describe, it, expect, jest, beforeEach, afterEach } from '@jest/globals';
import { AIService } from '../../services/ai.service';
import config from '../../config/config';

// Mock the config
jest.mock('../../config/config', () => ({
  openai: {
    apiKey: 'test-openai-key',
    model: 'gpt-3.5-turbo',
    temperature: 0.7,
  },
  ai: {
    maxTokens: 1000,
    maxRetries: 3,
    timeout: 30000,
  },
}));

// Mock OpenAI/LangChain
jest.mock('@langchain/openai', () => ({
  ChatOpenAI: jest.fn().mockImplementation(() => ({
    invoke: jest.fn(),
  })),
}));

describe('AIService', () => {
  let aiService: AIService;
  let mockModel: any;

  beforeEach(() => {
    // Reset singleton instance
    (AIService as any).instance = null;
    aiService = AIService.getInstance();

    // Get the mocked model instance
    const ChatOpenAI = require('@langchain/openai').ChatOpenAI;
    mockModel = ChatOpenAI.mock.results[0].value;
  });

  afterEach(() => {
    jest.clearAllMocks();
    (AIService as any).instance = null;
  });

  describe('Singleton Pattern', () => {
    it('should return the same instance on multiple calls', () => {
      const instance1 = AIService.getInstance();
      const instance2 = AIService.getInstance();
      expect(instance1).toBe(instance2);
    });

    it('should create a new instance if none exists', () => {
      (AIService as any).instance = null;
      const instance = AIService.getInstance();
      expect(instance).toBeInstanceOf(AIService);
    });
  });

  describe('generateResponse', () => {
    it('should generate a response successfully', async () => {
      const mockResponse = { content: 'Test AI response' };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const result = await aiService.generateResponse('Test prompt');

      expect(mockModel.invoke).toHaveBeenCalledWith([
        expect.objectContaining({
          content: 'You are a helpful AI assistant for the Funding Machine platform.',
        }),
        expect.objectContaining({
          content: 'Test prompt',
        }),
      ]);
      expect(result).toBe('Test AI response');
    });

    it('should handle custom system message', async () => {
      const mockResponse = { content: 'Custom response' };
      mockModel.invoke.mockResolvedValue(mockResponse);
      const customSystemMessage = 'Custom system message';

      const result = await aiService.generateResponse('Test prompt', {}, customSystemMessage);

      expect(mockModel.invoke).toHaveBeenCalledWith([
        expect.objectContaining({
          content: customSystemMessage,
        }),
        expect.objectContaining({
          content: 'Test prompt',
        }),
      ]);
      expect(result).toBe('Custom response');
    });

    it('should handle context data', async () => {
      const mockResponse = { content: 'Context-aware response' };
      mockModel.invoke.mockResolvedValue(mockResponse);
      const context = { userId: '123', preferences: ['option1'] };

      await aiService.generateResponse('Test prompt', context);

      expect(mockModel.invoke).toHaveBeenCalledWith([
        expect.objectContaining({
          content: 'You are a helpful AI assistant for the Funding Machine platform.',
        }),
        expect.objectContaining({
          content: 'Test prompt',
        }),
      ]);
    });

    it('should handle API errors gracefully', async () => {
      const errorMessage = 'OpenAI API Error';
      mockModel.invoke.mockRejectedValue(new Error(errorMessage));

      await expect(aiService.generateResponse('Test prompt')).rejects.toThrow('Failed to generate AI response');
    });

    it('should handle non-string response content', async () => {
      const mockResponse = { content: { text: 'Object response' } };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const result = await aiService.generateResponse('Test prompt');

      expect(result).toBe('[object Object]');
    });
  });

  describe('analyzeTransactionPatterns', () => {
    it('should analyze transaction patterns successfully', async () => {
      const mockResponse = { content: 'Transaction analysis complete' };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const userId = 'user123';
      const transactions = [
        { id: 1, amount: 100, type: 'income' },
        { id: 2, amount: 50, type: 'expense' },
      ];

      const result = await aiService.analyzeTransactionPatterns(userId, transactions);

      expect(mockModel.invoke).toHaveBeenCalledWith([
        expect.objectContaining({
          content: 'You are a financial analyst AI that provides insights on transaction patterns.',
        }),
        expect.objectContaining({
          content: expect.stringContaining('Analyze the following transaction data'),
        }),
      ]);
      expect(result).toBe('Transaction analysis complete');
    });

    it('should handle empty transactions array', async () => {
      const mockResponse = { content: 'No transactions to analyze' };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const result = await aiService.analyzeTransactionPatterns('user123', []);

      expect(result).toBe('No transactions to analyze');
    });
  });

  describe('generateFundingRecommendations', () => {
    it('should generate funding recommendations successfully', async () => {
      const mockResponse = { content: 'Funding recommendations generated' };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const userProfile = {
        age: 30,
        riskTolerance: 'medium',
        availableCapital: 10000,
        timeCommitment: 'part-time',
      };

      const result = await aiService.generateFundingRecommendations(userProfile);

      expect(mockModel.invoke).toHaveBeenCalledWith([
        expect.objectContaining({
          content: 'You are an expert in passive income and funding strategies. Provide detailed, personalized recommendations.',
        }),
        expect.objectContaining({
          content: expect.stringContaining('Generate personalized funding recommendations'),
        }),
      ]);
      expect(result).toBe('Funding recommendations generated');
    });

    it('should handle minimal user profile', async () => {
      const mockResponse = { content: 'Basic recommendations' };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const userProfile = { age: 25 };

      const result = await aiService.generateFundingRecommendations(userProfile);

      expect(result).toBe('Basic recommendations');
    });
  });

  describe('detectFraud', () => {
    it('should detect fraud successfully', async () => {
      const mockAIResponse = JSON.stringify({
        isFraud: false,
        confidence: 0.95,
        reasons: ['Transaction appears legitimate'],
      });
      const mockResponse = { content: mockAIResponse };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const transaction = {
        id: 'tx123',
        amount: 1000,
        merchant: 'Test Merchant',
        timestamp: new Date().toISOString(),
      };

      const userHistory = [
        { amount: 500, merchant: 'Regular Merchant' },
        { amount: 750, merchant: 'Another Merchant' },
      ];

      const result = await aiService.detectFraud(transaction, userHistory);

      expect(result).toEqual({
        isFraud: false,
        confidence: 0.95,
        reasons: ['Transaction appears legitimate'],
      });
    });

    it('should handle fraud detection errors', async () => {
      const invalidJsonResponse = 'Invalid JSON response from AI';
      const mockResponse = { content: invalidJsonResponse };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const transaction = { id: 'tx123', amount: 100 };
      const userHistory = [];

      const result = await aiService.detectFraud(transaction, userHistory);

      expect(result).toEqual({
        isFraud: false,
        confidence: 0,
        reasons: ['Unable to analyze transaction at this time.'],
      });
    });

    it('should handle malformed JSON response', async () => {
      const malformedJson = '{ isFraud: true, confidence: 0.8 }'; // Missing quotes
      const mockResponse = { content: malformedJson };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const transaction = { id: 'tx123', amount: 100 };
      const userHistory = [];

      const result = await aiService.detectFraud(transaction, userHistory);

      expect(result).toEqual({
        isFraud: false,
        confidence: 0,
        reasons: ['Unable to analyze transaction at this time.'],
      });
    });
  });

  describe('generateFinancialSummary', () => {
    it('should generate financial summary successfully', async () => {
      const mockResponse = { content: 'Financial summary generated' };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const userId = 'user123';
      const financialData = {
        totalIncome: 5000,
        totalExpenses: 3000,
        investments: [
          { type: 'stocks', value: 10000, performance: 0.15 },
          { type: 'bonds', value: 5000, performance: 0.05 },
        ],
        savings: 2000,
      };

      const result = await aiService.generateFinancialSummary(userId, financialData);

      expect(mockModel.invoke).toHaveBeenCalledWith([
        expect.objectContaining({
          content: 'You are a financial advisor AI. Provide clear, actionable financial summaries and advice.',
        }),
        expect.objectContaining({
          content: expect.stringContaining('Generate a comprehensive financial summary'),
        }),
      ]);
      expect(result).toBe('Financial summary generated');
    });

    it('should handle minimal financial data', async () => {
      const mockResponse = { content: 'Basic financial overview' };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const financialData = { totalIncome: 1000 };

      const result = await aiService.generateFinancialSummary('user123', financialData);

      expect(result).toBe('Basic financial overview');
    });
  });

  describe('handleUserQuery', () => {
    it('should handle user queries successfully', async () => {
      const mockResponse = { content: 'Query answered successfully' };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const query = 'How do I get started with funding?';
      const userContext = {
        userId: 'user123',
        experience: 'beginner',
        availableCapital: 5000,
      };

      const result = await aiService.handleUserQuery(query, userContext);

      expect(mockModel.invoke).toHaveBeenCalledWith([
        expect.objectContaining({
          content: 'You are a helpful assistant for the Funding Machine platform. Provide accurate and friendly responses to user queries.',
        }),
        expect.objectContaining({
          content: expect.stringContaining('User query: How do I get started with funding?'),
        }),
      ]);
      expect(result).toBe('Query answered successfully');
    });

    it('should handle queries without user context', async () => {
      const mockResponse = { content: 'General guidance provided' };
      mockModel.invoke.mockResolvedValue(mockResponse);

      const query = 'What is Funding Machine?';

      const result = await aiService.handleUserQuery(query);

      expect(result).toBe('General guidance provided');
    });
  });

  describe('Error Handling', () => {
    it('should handle network timeouts', async () => {
      mockModel.invoke.mockRejectedValue(new Error('Network timeout'));

      await expect(aiService.generateResponse('Test prompt')).rejects.toThrow('Failed to generate AI response');
    });

    it('should handle invalid API keys', async () => {
      mockModel.invoke.mockRejectedValue(new Error('Invalid API key'));

      await expect(aiService.generateResponse('Test prompt')).rejects.toThrow('Failed to generate AI response');
    });

    it('should handle rate limiting', async () => {
      mockModel.invoke.mockRejectedValue(new Error('Rate limit exceeded'));

      await expect(aiService.generateResponse('Test prompt')).rejects.toThrow('Failed to generate AI response');
    });
  });
});
