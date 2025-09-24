/// <reference types="jest" />

import { beforeAll, afterAll, beforeEach, afterEach } from '@jest/globals';
import { TestDatabase, testUtils, testDataFactory } from './test-database.config';

// Global test setup
export interface TestContext {
  testDatabase: TestDatabase;
  testUtils: typeof testUtils;
  testDataFactory: typeof testDataFactory;
  createdUsers: any[];
  createdPaymentMethods: any[];
  createdPlatforms: any[];
  createdTransactions: any[];
}

// Global test context
declare global {
  var __TEST_CONTEXT__: TestContext;
}

// Setup global test context
const setupTestContext = (): TestContext => {
  const testDatabase = TestDatabase.getInstance();

  return {
    testDatabase,
    testUtils,
    testDataFactory,
    createdUsers: [],
    createdPaymentMethods: [],
    createdPlatforms: [],
    createdTransactions: [],
  };
};

// Global setup before all tests
beforeAll(async () => {
  console.log('🚀 Starting test suite...');

  // Initialize test context
  global.__TEST_CONTEXT__ = setupTestContext();

  // Connect to test database
  try {
    await global.__TEST_CONTEXT__.testDatabase.connect();
    console.log('✅ Test database connected');
  } catch (error) {
    console.error('❌ Failed to connect to test database:', error);
    throw error;
  }

  // Clear and seed database if enabled
  if (process.env.SEED_TEST_DATABASE === 'true') {
    try {
      await global.__TEST_CONTEXT__.testDatabase.clearDatabase();
      await global.__TEST_CONTEXT__.testDatabase.seedDatabase();
      console.log('✅ Test database seeded');
    } catch (error) {
      console.error('❌ Failed to seed test database:', error);
      throw error;
    }
  }
}, 60000); // 60 second timeout for database operations

// Global teardown after all tests
afterAll(async () => {
  console.log('🛑 Cleaning up test suite...');

  // Disconnect from test database
  try {
    await global.__TEST_CONTEXT__.testDatabase.disconnect();
    console.log('✅ Test database disconnected');
  } catch (error) {
    console.error('❌ Failed to disconnect from test database:', error);
  }

  console.log('✅ Test suite cleanup completed');
}, 30000); // 30 second timeout

// Setup before each test
beforeEach(async () => {
  // Reset test context for each test
  global.__TEST_CONTEXT__.createdUsers = [];
  global.__TEST_CONTEXT__.createdPaymentMethods = [];
  global.__TEST_CONTEXT__.createdPlatforms = [];
  global.__TEST_CONTEXT__.createdTransactions = [];

  // Clear database between tests if isolation is enabled
  if (process.env.TEST_ISOLATION === 'true') {
    try {
      await global.__TEST_CONTEXT__.testDatabase.clearDatabase();
    } catch (error) {
      console.warn('⚠️ Failed to clear database between tests:', error);
    }
  }
});

// Teardown after each test
afterEach(async () => {
  // Clean up any remaining test data
  const context = global.__TEST_CONTEXT__;

  // Clean up created records
  try {
    if (context.createdTransactions.length > 0) {
      await context.testDatabase.getPrisma().transaction.deleteMany({
        where: {
          id: {
            in: context.createdTransactions.map(t => t.id),
          },
        },
      });
    }

    if (context.createdPaymentMethods.length > 0) {
      await context.testDatabase.getPrisma().paymentMethod.deleteMany({
        where: {
          id: {
            in: context.createdPaymentMethods.map(pm => pm.id),
          },
        },
      });
    }

    if (context.createdPlatforms.length > 0) {
      await context.testDatabase.getPrisma().fundingPlatform.deleteMany({
        where: {
          id: {
            in: context.createdPlatforms.map(p => p.id),
          },
        },
      });
    }

    if (context.createdUsers.length > 0) {
      await context.testDatabase.getPrisma().user.deleteMany({
        where: {
          id: {
            in: context.createdUsers.map(u => u.id),
          },
        },
      });
    }
  } catch (error) {
    console.warn('⚠️ Failed to clean up test data:', error);
  }
});

// Test utilities available globally
(global as any).testUtils = testUtils;
(global as any).testDataFactory = testDataFactory;

// Helper functions for tests
export const createTestUser = async (overrides: any = {}) => {
  const user = await global.__TEST_CONTEXT__.testUtils.createTestUser(
    global.__TEST_CONTEXT__.testDatabase.getPrisma(),
    overrides
  );
  global.__TEST_CONTEXT__.createdUsers.push(user);
  return user;
};

export const createTestPaymentMethod = async (userId: string, overrides: any = {}) => {
  const paymentMethod = await global.__TEST_CONTEXT__.testUtils.createTestPaymentMethod(
    global.__TEST_CONTEXT__.testDatabase.getPrisma(),
    userId,
    overrides
  );
  global.__TEST_CONTEXT__.createdPaymentMethods.push(paymentMethod);
  return paymentMethod;
};

export const createTestPlatform = async (overrides: any = {}) => {
  const platform = await global.__TEST_CONTEXT__.testUtils.createTestFundingPlatform(
    global.__TEST_CONTEXT__.testDatabase.getPrisma(),
    overrides
  );
  global.__TEST_CONTEXT__.createdPlatforms.push(platform);
  return platform;
};

export const createTestTransaction = async (userId: string, overrides: any = {}) => {
  const transaction = await global.__TEST_CONTEXT__.testUtils.createTestTransaction(
    global.__TEST_CONTEXT__.testDatabase.getPrisma(),
    userId,
    overrides
  );
  global.__TEST_CONTEXT__.createdTransactions.push(transaction);
  return transaction;
};

// Test data helpers
export const getValidUserData = () => global.__TEST_CONTEXT__.testDataFactory.user.valid();
export const getValidPaymentMethodData = (userId: string) =>
  global.__TEST_CONTEXT__.testDataFactory.paymentMethod.card(userId);
export const getValidPlatformData = () => global.__TEST_CONTEXT__.testDataFactory.fundingPlatform.valid();

// Mock data generators
export const generateMockUser = (overrides: any = {}) => ({
  id: `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
  email: `test${Date.now()}@example.com`,
  password: 'hashed_password',
  firstName: 'Test',
  lastName: 'User',
  isActive: true,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

export const generateMockPaymentMethod = (userId: string, overrides: any = {}) => ({
  id: `pm_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
  userId,
  type: 'CARD',
  provider: 'Test Bank',
  last4: '4242',
  expiryMonth: 12,
  expiryYear: 2025,
  isDefault: false,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

export const generateMockPlatform = (overrides: any = {}) => ({
  id: `platform_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
  name: 'Test Platform',
  description: 'A test funding platform',
  category: 'P2P_LENDING',
  minimumInvestment: 100,
  expectedReturn: 8.5,
  riskLevel: 'MEDIUM',
  features: ['Auto-invest', 'Low fees'],
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

export const generateMockTransaction = (userId: string, overrides: any = {}) => ({
  id: `transaction_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
  userId,
  amount: 1000,
  type: 'DEPOSIT',
  description: 'Test transaction',
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

// Test assertion helpers
export const expectToBeValidUUID = (value: string) => {
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  expect(value).toMatch(uuidRegex);
};

export const expectToBeValidEmail = (value: string) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  expect(value).toMatch(emailRegex);
};

export const expectToBeValidAmount = (value: number) => {
  expect(value).toBeGreaterThan(0);
  expect(value).toBeLessThan(1000000); // Reasonable upper limit
};

export const expectToBeInEnum = <T>(value: string, enumObject: Record<string, string>) => {
  const validValues = Object.values(enumObject) as string[];
  expect(validValues).toContain(value);
};

// Performance testing helpers
export const measurePerformance = async (operation: () => Promise<any>, operationName: string) => {
  const startTime = Date.now();
  const result = await operation();
  const endTime = Date.now();
  const duration = endTime - startTime;

  console.log(`⏱️ ${operationName} took ${duration}ms`);

  if (duration > 1000) {
    console.warn(`⚠️ ${operationName} took longer than 1 second (${duration}ms)`);
  }

  return { result, duration };
};

// Error testing helpers
export const expectToThrowWithMessage = async (operation: () => Promise<any>, expectedMessage: string) => {
  try {
    await operation();
    throw new Error('Expected operation to throw');
  } catch (error: any) {
    expect(error.message).toContain(expectedMessage);
  }
};

export const expectToThrowWithStatus = async (operation: () => Promise<any>, expectedStatus: number) => {
  try {
    await operation();
    throw new Error('Expected operation to throw');
  } catch (error: any) {
    if (error.status) {
      expect(error.status).toBe(expectedStatus);
    } else {
      expect(error.response?.status).toBe(expectedStatus);
    }
  }
};

// Test configuration helpers
export const getTestConfig = () => ({
  enableLogging: process.env.ENABLE_TEST_LOGGING === 'true',
  enableSeeding: process.env.SEED_TEST_DATABASE === 'true',
  testIsolation: process.env.TEST_ISOLATION === 'true',
  timeout: parseInt(process.env.TEST_TIMEOUT || '30000'),
  retries: parseInt(process.env.TEST_RETRIES || '3'),
});

console.log('📋 Test configuration:', getTestConfig());
