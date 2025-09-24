/// <reference types="jest" />

import { describe, test, expect, beforeAll, afterAll } from '@jest/globals';
import request from 'supertest';
import app from '../../app';
import prisma from '../../config/database';

describe('Performance Integration Tests', () => {
  let authToken: string;
  let testUserId: string;

  beforeAll(async () => {
    // Clean up test data
    await prisma.transaction.deleteMany();
    await prisma.funding.deleteMany();
    await prisma.paymentMethod.deleteMany();
    await prisma.bankAccount.deleteMany();
    await prisma.fundingPlatform.deleteMany();
    await prisma.user.deleteMany();

    // Create test user
    const hashedPassword = await require('bcrypt').hash('password123', 12);
    const user = await prisma.user.create({
      data: {
        email: 'perf-test@example.com',
        password: hashedPassword,
        name: 'Performance Test User'
      }
    });

    testUserId = user.id;

    // Login to get token
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'perf-test@example.com',
        password: 'password123'
      });

    authToken = loginResponse.body.data.token;
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

  describe('API Response Time Tests', () => {
    test('authentication endpoints should respond within 100ms', async () => {
      const startTime = Date.now();

      await request(app)
        .post('/api/auth/login')
        .send({
          email: 'perf-test@example.com',
          password: 'password123'
        });

      const endTime = Date.now();
      const responseTime = endTime - startTime;

      expect(responseTime).toBeLessThan(100);
      console.log(`Login response time: ${responseTime}ms`);
    });

    test('protected routes should respond within 50ms', async () => {
      const startTime = Date.now();

      await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`);

      const endTime = Date.now();
      const responseTime = endTime - startTime;

      expect(responseTime).toBeLessThan(50);
      console.log(`Profile access response time: ${responseTime}ms`);
    });

    test('list endpoints should respond within 200ms', async () => {
      const startTime = Date.now();

      await request(app)
        .get('/api/funding-platforms')
        .set('Authorization', `Bearer ${authToken}`);

      const endTime = Date.now();
      const responseTime = endTime - startTime;

      expect(responseTime).toBeLessThan(200);
      console.log(`Funding platforms list response time: ${responseTime}ms`);
    });
  });

  describe('Database Performance Tests', () => {
    test('should handle multiple concurrent requests', async () => {
      const numberOfRequests = 10;
      const startTime = Date.now();

      const promises = Array.from({ length: numberOfRequests }, () =>
        request(app)
          .get('/api/funding-platforms')
          .set('Authorization', `Bearer ${authToken}`)
      );

      await Promise.all(promises);

      const endTime = Date.now();
      const totalTime = endTime - startTime;
      const averageTime = totalTime / numberOfRequests;

      expect(averageTime).toBeLessThan(100);
      console.log(`Concurrent requests average time: ${averageTime}ms`);
    });

    test('should handle large data sets efficiently', async () => {
      // Create multiple funding platforms for testing
      const platforms = [];
      for (let i = 0; i < 50; i++) {
        platforms.push({
          name: `Performance Test Platform ${i}`,
          description: `Test platform ${i} for performance testing`,
          type: 'investment',
          logoUrl: 'https://example.com/logo.png',
          minimumInvestment: 100 + i * 10,
          expectedReturn: 5 + Math.random() * 10,
          riskLevel: 'medium',
          features: ['Feature 1', 'Feature 2']
        });
      }

      const startTime = Date.now();

      for (const platform of platforms) {
        await request(app)
          .post('/api/funding-platforms')
          .set('Authorization', `Bearer ${authToken}`)
          .send(platform);
      }

      const endTime = Date.now();
      const totalTime = endTime - startTime;
      const averageTime = totalTime / platforms.length;

      expect(averageTime).toBeLessThan(50);
      console.log(`Bulk platform creation average time: ${averageTime}ms per platform`);
    });
  });

  describe('Memory Usage Tests', () => {
    test('should not leak memory on repeated requests', async () => {
      const initialMemoryUsage = process.memoryUsage().heapUsed;
      const numberOfIterations = 100;

      for (let i = 0; i < numberOfIterations; i++) {
        await request(app)
          .get('/api/health');
      }

      const finalMemoryUsage = process.memoryUsage().heapUsed;
      const memoryIncrease = finalMemoryUsage - initialMemoryUsage;
      const memoryPerRequest = memoryIncrease / numberOfIterations;

      expect(memoryPerRequest).toBeLessThan(1024); // Less than 1KB per request
      console.log(`Memory usage per request: ${memoryPerRequest} bytes`);
    });
  });

  describe('Error Recovery Tests', () => {
    test('should recover quickly from invalid requests', async () => {
      const startTime = Date.now();

      await request(app)
        .get('/api/invalid-endpoint')
        .set('Authorization', `Bearer ${authToken}`);

      const endTime = Date.now();
      const responseTime = endTime - startTime;

      expect(responseTime).toBeLessThan(10);
      console.log(`Error response time: ${responseTime}ms`);
    });

    test('should handle rapid successive errors', async () => {
      const numberOfErrors = 20;
      const startTime = Date.now();

      const promises = Array.from({ length: numberOfErrors }, () =>
        request(app)
          .get('/api/invalid-endpoint')
          .set('Authorization', `Bearer ${authToken}`)
      );

      await Promise.all(promises);

      const endTime = Date.now();
      const totalTime = endTime - startTime;
      const averageTime = totalTime / numberOfErrors;

      expect(averageTime).toBeLessThan(5);
      console.log(`Rapid error handling average time: ${averageTime}ms`);
    });
  });

  describe('Load Testing Simulation', () => {
    test('should handle moderate load without degradation', async () => {
      const numberOfUsers = 5;
      const requestsPerUser = 10;
      const startTime = Date.now();

      const userPromises = Array.from({ length: numberOfUsers }, async (_, userIndex) => {
        const userRequests = Array.from({ length: requestsPerUser }, () =>
          request(app)
            .get('/api/funding-platforms')
            .set('Authorization', `Bearer ${authToken}`)
        );

        return Promise.all(userRequests);
      });

      await Promise.all(userPromises);

      const endTime = Date.now();
      const totalTime = endTime - startTime;
      const totalRequests = numberOfUsers * requestsPerUser;
      const requestsPerSecond = totalRequests / (totalTime / 1000);

      expect(requestsPerSecond).toBeGreaterThan(5); // At least 5 requests per second
      console.log(`Load test: ${requestsPerSecond.toFixed(2)} requests/second`);
    });
  });

  describe('Database Connection Pool Tests', () => {
    test('should handle database-intensive operations', async () => {
      const startTime = Date.now();

      // Perform multiple database operations
      for (let i = 0; i < 10; i++) {
        await request(app)
          .post('/api/funding-platforms')
          .set('Authorization', `Bearer ${authToken}`)
          .send({
            name: `DB Test Platform ${i}`,
            description: `Database test platform ${i}`,
            type: 'investment',
            logoUrl: 'https://example.com/logo.png',
            minimumInvestment: 100,
            expectedReturn: 8.0,
            riskLevel: 'medium',
            features: ['Test feature']
          });
      }

      const endTime = Date.now();
      const totalTime = endTime - startTime;
      const averageTime = totalTime / 10;

      expect(averageTime).toBeLessThan(100);
      console.log(`Database operation average time: ${averageTime}ms`);
    });
  });
});
