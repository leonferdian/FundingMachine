/// <reference types="jest" />

import { describe, test, expect, beforeAll, afterAll } from '@jest/globals';
import request from 'supertest';
import app from '../../app';
import prisma from '../../config/database';
import { AuthService } from '../../services/auth.service';

describe('API Integration Tests', () => {
  let authToken: string;
  let testUserId: string;
  let testFundingPlatformId: string;

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

  describe('Authentication Integration', () => {
    test('should register a new user', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User'
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe('test@example.com');
      expect(response.body.data.user.name).toBe('Test User');
    });

    test('should login user and return token', async () => {
      const response = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'password123'
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.token).toBeDefined();
      expect(response.body.data.user.email).toBe('test@example.com');

      authToken = response.body.data.token;
      testUserId = response.body.data.user.id;
    });

    test('should access protected route with valid token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe('test@example.com');
    });
  });

  describe('User Management Integration', () => {
    test('should get user profile', async () => {
      const response = await request(app)
        .get('/api/users/profile')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe('test@example.com');
    });

    test('should update user profile', async () => {
      const response = await request(app)
        .put('/api/users/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Updated Test User',
          email: 'updated@example.com'
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user.name).toBe('Updated Test User');
      expect(response.body.data.user.email).toBe('updated@example.com');
    });
  });

  describe('Funding Platform Integration', () => {
    test('should get all funding platforms', async () => {
      const response = await request(app)
        .get('/api/funding-platforms')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data.platforms)).toBe(true);
    });

    test('should create a new funding platform', async () => {
      const response = await request(app)
        .post('/api/funding-platforms')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Test Investment Platform',
          description: 'A test investment platform for integration testing',
          type: 'investment',
          logoUrl: 'https://example.com/logo.png',
          minimumInvestment: 100,
          expectedReturn: 8.5,
          riskLevel: 'medium',
          features: ['Auto-invest', 'Low fees']
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.platform.name).toBe('Test Investment Platform');
      expect(response.body.data.platform.type).toBe('investment');

      testFundingPlatformId = response.body.data.platform.id;
    });

    test('should get funding platform by id', async () => {
      const response = await request(app)
        .get(`/api/funding-platforms/${testFundingPlatformId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.platform.id).toBe(testFundingPlatformId);
      expect(response.body.data.platform.name).toBe('Test Investment Platform');
    });

    test('should update funding platform', async () => {
      const response = await request(app)
        .put(`/api/funding-platforms/${testFundingPlatformId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Updated Test Platform',
          description: 'Updated description for testing'
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.platform.name).toBe('Updated Test Platform');
    });
  });

  describe('Payment Method Integration', () => {
    test('should create a bank account payment method', async () => {
      const response = await request(app)
        .post('/api/payment-methods')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          type: 'bank_account',
          bankCode: '002',
          accountNumber: '1234567890',
          accountName: 'Test User'
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.paymentMethod.type).toBe('bank_account');
      expect(response.body.data.paymentMethod.bankCode).toBe('002');
    });

    test('should get user payment methods', async () => {
      const response = await request(app)
        .get('/api/payment-methods')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data.paymentMethods)).toBe(true);
      expect(response.body.data.paymentMethods.length).toBeGreaterThan(0);
    });
  });

  describe('Funding Integration', () => {
    test('should create a new funding', async () => {
      const response = await request(app)
        .post('/api/fundings')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          platformId: testFundingPlatformId,
          amount: 1000,
          profitShare: 0.7
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.funding.amount).toBe(1000);
      expect(response.body.data.funding.profitShare).toBe(0.7);
    });

    test('should get user fundings', async () => {
      const response = await request(app)
        .get('/api/fundings')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data.fundings)).toBe(true);
      expect(response.body.data.fundings.length).toBeGreaterThan(0);
    });
  });

  describe('Transaction Integration', () => {
    test('should get user transactions', async () => {
      const response = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data.transactions)).toBe(true);
    });

    test('should get transactions with filters', async () => {
      const response = await request(app)
        .get('/api/transactions?type=investment&limit=10')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(Array.isArray(response.body.data.transactions)).toBe(true);
    });
  });

  describe('AI Service Integration', () => {
    test('should get AI recommendations', async () => {
      const response = await request(app)
        .get('/api/ai/recommendations')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeDefined();
    });
  });

  describe('Health Check Integration', () => {
    test('should return health status', async () => {
      const response = await request(app)
        .get('/api/health');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe('healthy');
    });
  });

  describe('Error Handling Integration', () => {
    test('should handle invalid token', async () => {
      const response = await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toBeDefined();
    });

    test('should handle missing authentication', async () => {
      const response = await request(app)
        .get('/api/auth/me');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    test('should handle not found routes', async () => {
      const response = await request(app)
        .get('/api/non-existent-route')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
    });
  });

  describe('Data Consistency Integration', () => {
    test('should maintain data consistency across operations', async () => {
      // Create a payment method
      const paymentMethodResponse = await request(app)
        .post('/api/payment-methods')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          type: 'paypal',
          email: 'test@example.com'
        });

      expect(paymentMethodResponse.status).toBe(201);
      const paymentMethodId = paymentMethodResponse.body.data.paymentMethod.id;

      // Verify it exists in the list
      const listResponse = await request(app)
        .get('/api/payment-methods')
        .set('Authorization', `Bearer ${authToken}`);

      expect(listResponse.status).toBe(200);
      const paymentMethodExists = listResponse.body.data.paymentMethods
        .some((pm: any) => pm.id === paymentMethodId);
      expect(paymentMethodExists).toBe(true);
    });
  });
});
