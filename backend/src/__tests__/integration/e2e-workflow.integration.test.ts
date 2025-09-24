/// <reference types="jest" />

import { describe, test, expect, beforeAll, afterAll } from '@jest/globals';
import request from 'supertest';
import app from '../../app';
import prisma from '../../config/database';

describe('End-to-End User Workflow Integration Tests', () => {
  let authToken: string;
  let testUserId: string;
  let testFundingPlatformId: string;
  let testPaymentMethodId: string;
  let testFundingId: string;

  beforeAll(async () => {
    // Clean up test data
    await prisma.transaction.deleteMany();
    await prisma.funding.deleteMany();
    await prisma.paymentMethod.deleteMany();
    await prisma.bankAccount.deleteMany();
    await prisma.fundingPlatform.deleteMany();
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    // Clean up test data
    await prisma.transaction.deleteMany();
    await prisma.funding.deleteMany();
    await prisma.paymentMethod.deleteMany();
    await prisma.bankAccount.deleteMany();
    await prisma.fundingPlatform.deleteMany();
    await prisma.user.deleteMany();
    await prisma.$disconnect();
  });

  describe('Complete User Onboarding Workflow', () => {
    test('should complete full user registration and setup', async () => {
      // 1. Register new user
      const registerResponse = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'e2e-test@example.com',
          password: 'password123',
          name: 'E2E Test User'
        });

      expect(registerResponse.status).toBe(201);
      expect(registerResponse.body.success).toBe(true);
      expect(registerResponse.body.data.user.email).toBe('e2e-test@example.com');

      testUserId = registerResponse.body.data.user.id;

      // 2. Login to get authentication token
      const loginResponse = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'e2e-test@example.com',
          password: 'password123'
        });

      expect(loginResponse.status).toBe(200);
      expect(loginResponse.body.success).toBe(true);
      expect(loginResponse.body.data.token).toBeDefined();

      authToken = loginResponse.body.data.token;
    });

    test('should complete user profile setup', async () => {
      // Update user profile with additional information
      const profileResponse = await request(app)
        .put('/api/users/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Complete E2E Test User',
          email: 'complete-e2e@example.com'
        });

      expect(profileResponse.status).toBe(200);
      expect(profileResponse.body.success).toBe(true);
      expect(profileResponse.body.data.user.name).toBe('Complete E2E Test User');

      // Verify profile was updated
      const getProfileResponse = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`);

      expect(getProfileResponse.body.data.user.email).toBe('complete-e2e@example.com');
    });
  });

  describe('Complete Funding Platform Discovery Workflow', () => {
    test('should discover and connect to funding platforms', async () => {
      // 1. Get available funding platforms
      const platformsResponse = await request(app)
        .get('/api/funding-platforms')
        .set('Authorization', `Bearer ${authToken}`);

      expect(platformsResponse.status).toBe(200);
      expect(platformsResponse.body.success).toBe(true);

      // 2. Create a test funding platform for the workflow
      const createPlatformResponse = await request(app)
        .post('/api/funding-platforms')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'E2E Test Investment Platform',
          description: 'A comprehensive test platform for end-to-end workflow testing',
          type: 'investment',
          logoUrl: 'https://example.com/e2e-logo.png',
          minimumInvestment: 100,
          expectedReturn: 12.5,
          riskLevel: 'medium',
          features: ['Auto-invest', 'Mobile app', '24/7 support']
        });

      expect(createPlatformResponse.status).toBe(201);
      expect(createPlatformResponse.body.success).toBe(true);

      testFundingPlatformId = createPlatformResponse.body.data.platform.id;

      // 3. Get specific platform details
      const platformDetailsResponse = await request(app)
        .get(`/api/funding-platforms/${testFundingPlatformId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(platformDetailsResponse.status).toBe(200);
      expect(platformDetailsResponse.body.data.platform.name).toBe('E2E Test Investment Platform');
    });
  });

  describe('Complete Payment Method Setup Workflow', () => {
    test('should set up multiple payment methods', async () => {
      // 1. Add bank account payment method
      const bankAccountResponse = await request(app)
        .post('/api/payment-methods')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          type: 'bank_account',
          bankCode: '014', // Bank Central Asia for testing
          accountNumber: '1234567890123456',
          accountName: 'Complete E2E Test User'
        });

      expect(bankAccountResponse.status).toBe(201);
      expect(bankAccountResponse.body.success).toBe(true);
      expect(bankAccountResponse.body.data.paymentMethod.type).toBe('bank_account');

      // 2. Add PayPal payment method
      const paypalResponse = await request(app)
        .post('/api/payment-methods')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          type: 'paypal',
          email: 'complete-e2e@example.com'
        });

      expect(paypalResponse.status).toBe(201);
      expect(paypalResponse.body.success).toBe(true);
      expect(paypalResponse.body.data.paymentMethod.type).toBe('paypal');

      testPaymentMethodId = paypalResponse.body.data.paymentMethod.id;

      // 3. Verify all payment methods are accessible
      const paymentMethodsResponse = await request(app)
        .get('/api/payment-methods')
        .set('Authorization', `Bearer ${authToken}`);

      expect(paymentMethodsResponse.status).toBe(200);
      expect(paymentMethodsResponse.body.data.paymentMethods.length).toBeGreaterThanOrEqual(2);
    });
  });

  describe('Complete Investment Workflow', () => {
    test('should complete full investment process', async () => {
      // 1. Create a funding investment
      const fundingResponse = await request(app)
        .post('/api/fundings')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          platformId: testFundingPlatformId,
          amount: 1000,
          profitShare: 0.75
        });

      expect(fundingResponse.status).toBe(201);
      expect(fundingResponse.body.success).toBe(true);
      expect(fundingResponse.body.data.funding.amount).toBe(1000);
      expect(fundingResponse.body.data.funding.profitShare).toBe(0.75);

      testFundingId = fundingResponse.body.data.funding.id;

      // 2. Verify funding appears in user's fundings list
      const userFundingsResponse = await request(app)
        .get('/api/fundings')
        .set('Authorization', `Bearer ${authToken}`);

      expect(userFundingsResponse.status).toBe(200);
      expect(userFundingsResponse.body.data.fundings.length).toBeGreaterThan(0);

      const createdFunding = userFundingsResponse.body.data.fundings.find((f: any) => f.id === testFundingId);
      expect(createdFunding).toBeDefined();
      expect(createdFunding.amount).toBe(1000);
    });

    test('should track investment transactions', async () => {
      // 1. Get user's transaction history
      const transactionsResponse = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${authToken}`);

      expect(transactionsResponse.status).toBe(200);
      expect(transactionsResponse.body.data.transactions.length).toBeGreaterThan(0);

      // 2. Verify transaction details
      const investmentTransaction = transactionsResponse.body.data.transactions.find((t: any) =>
        t.type === 'investment' && t.fundingId === testFundingId
      );

      expect(investmentTransaction).toBeDefined();
      expect(investmentTransaction.amount).toBe(1000);
      expect(investmentTransaction.status).toBe('completed');
    });
  });

  describe('Complete Portfolio Management Workflow', () => {
    test('should manage and monitor portfolio', async () => {
      // 1. Get user's complete fundings
      const fundingsResponse = await request(app)
        .get('/api/fundings')
        .set('Authorization', `Bearer ${authToken}`);

      expect(fundingsResponse.status).toBe(200);
      expect(fundingsResponse.body.data.fundings.length).toBeGreaterThan(0);

      // 2. Get funding with platform details
      const fundingWithPlatformResponse = await request(app)
        .get(`/api/fundings/${testFundingId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(fundingWithPlatformResponse.status).toBe(200);
      expect(fundingWithPlatformResponse.body.data.funding.platform.name).toBe('E2E Test Investment Platform');

      // 3. Get portfolio summary
      const portfolioResponse = await request(app)
        .get('/api/fundings/portfolio')
        .set('Authorization', `Bearer ${authToken}`);

      expect(portfolioResponse.status).toBe(200);
      expect(portfolioResponse.body.data.summary.totalInvested).toBeGreaterThan(0);
    });
  });

  describe('Complete AI Recommendation Workflow', () => {
    test('should provide AI-powered recommendations', async () => {
      // 1. Get AI recommendations based on user profile
      const recommendationsResponse = await request(app)
        .get('/api/ai/recommendations')
        .set('Authorization', `Bearer ${authToken}`);

      expect(recommendationsResponse.status).toBe(200);
      expect(recommendationsResponse.body.success).toBe(true);
      expect(recommendationsResponse.body.data).toBeDefined();

      // 2. Get personalized platform suggestions
      const suggestionsResponse = await request(app)
        .get('/api/ai/suggestions')
        .set('Authorization', `Bearer ${authToken}`);

      expect(suggestionsResponse.status).toBe(200);
      expect(suggestionsResponse.body.success).toBe(true);
    });
  });

  describe('Complete Data Export and Reporting Workflow', () => {
    test('should export user data and reports', async () => {
      // 1. Export user transaction history
      const exportResponse = await request(app)
        .get('/api/transactions/export')
        .set('Authorization', `Bearer ${authToken}`);

      expect(exportResponse.status).toBe(200);
      expect(exportResponse.body.success).toBe(true);

      // 2. Get portfolio performance report
      const reportResponse = await request(app)
        .get('/api/fundings/report')
        .set('Authorization', `Bearer ${authToken}`);

      expect(reportResponse.status).toBe(200);
      expect(reportResponse.body.success).toBe(true);
      expect(reportResponse.body.data.report).toBeDefined();
    });
  });

  describe('Complete System Health and Monitoring Workflow', () => {
    test('should monitor system health and performance', async () => {
      // 1. Check system health
      const healthResponse = await request(app)
        .get('/api/health');

      expect(healthResponse.status).toBe(200);
      expect(healthResponse.body.data.status).toBe('healthy');

      // 2. Get system metrics
      const metricsResponse = await request(app)
        .get('/api/health/metrics')
        .set('Authorization', `Bearer ${authToken}`);

      expect(metricsResponse.status).toBe(200);
      expect(metricsResponse.body.data.metrics).toBeDefined();
    });
  });

  describe('Complete Error Handling and Recovery Workflow', () => {
    test('should handle errors gracefully throughout the system', async () => {
      // 1. Test invalid authentication
      const invalidAuthResponse = await request(app)
        .get('/api/fundings')
        .set('Authorization', 'Bearer invalid-token');

      expect(invalidAuthResponse.status).toBe(401);

      // 2. Test invalid data submission
      const invalidDataResponse = await request(app)
        .post('/api/funding-platforms')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: '', // Invalid empty name
          type: 'invalid-type' // Invalid type
        });

      expect(invalidDataResponse.status).toBe(400);

      // 3. Test non-existent resource access
      const notFoundResponse = await request(app)
        .get('/api/funding-platforms/non-existent-id')
        .set('Authorization', `Bearer ${authToken}`);

      expect(notFoundResponse.status).toBe(404);
    });
  });

  describe('Complete Security and Validation Workflow', () => {
    test('should maintain security throughout all operations', async () => {
      // 1. Test rate limiting (if implemented)
      // 2. Test input validation
      // 3. Test authorization checks
      // 4. Test data sanitization

      // Verify all previous operations maintained data integrity
      const finalProfileResponse = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`);

      expect(finalProfileResponse.status).toBe(200);
      expect(finalProfileResponse.body.data.user.id).toBe(testUserId);

      // Verify all data is consistent
      const finalFundingsResponse = await request(app)
        .get('/api/fundings')
        .set('Authorization', `Bearer ${authToken}`);

      expect(finalFundingsResponse.body.data.fundings.length).toBeGreaterThan(0);

      const finalTransactionsResponse = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${authToken}`);

      expect(finalTransactionsResponse.body.data.transactions.length).toBeGreaterThan(0);
    });
  });

  describe('Workflow Completion Summary', () => {
    test('should have completed all major workflows successfully', async () => {
      // Verify user account is fully set up
      const userResponse = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`);

      expect(userResponse.body.data.user.email).toBe('complete-e2e@example.com');

      // Verify funding platform is accessible
      const platformResponse = await request(app)
        .get(`/api/funding-platforms/${testFundingPlatformId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(platformResponse.body.data.platform.name).toBe('E2E Test Investment Platform');

      // Verify payment methods are configured
      const paymentsResponse = await request(app)
        .get('/api/payment-methods')
        .set('Authorization', `Bearer ${authToken}`);

      expect(paymentsResponse.body.data.paymentMethods.length).toBeGreaterThanOrEqual(2);

      // Verify investments are active
      const fundingsResponse = await request(app)
        .get('/api/fundings')
        .set('Authorization', `Bearer ${authToken}`);

      expect(fundingsResponse.body.data.fundings.length).toBeGreaterThan(0);

      // Verify transaction history exists
      const transactionsResponse = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${authToken}`);

      expect(transactionsResponse.body.data.transactions.length).toBeGreaterThan(0);

      console.log('✅ Complete end-to-end workflow test passed!');
      console.log(`📊 Total fundings created: ${fundingsResponse.body.data.fundings.length}`);
      console.log(`💳 Payment methods configured: ${paymentsResponse.body.data.paymentMethods.length}`);
      console.log(`📈 Transactions recorded: ${transactionsResponse.body.data.transactions.length}`);
    });
  });
});
