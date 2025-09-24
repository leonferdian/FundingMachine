import { PrismaClient } from '@prisma/client';
import { mockDeep, DeepMockProxy } from 'jest-mock-extended';

// Test database configuration
export interface TestDatabaseConfig {
  databaseUrl: string;
  enableLogging: boolean;
  enableSeeding: boolean;
}

// Test database setup
export class TestDatabase {
  private static instance: TestDatabase;
  private prisma: PrismaClient;
  private isConnected: boolean = false;

  private constructor() {
    this.prisma = new PrismaClient({
      datasources: {
        db: {
          url: process.env.TEST_DATABASE_URL || 'postgresql://test:test@localhost:5432/funding_machine_test',
        },
      },
      log: process.env.ENABLE_TEST_DB_LOGGING === 'true' ? ['query', 'info', 'warn', 'error'] : [],
    });
  }

  public static getInstance(): TestDatabase {
    if (!TestDatabase.instance) {
      TestDatabase.instance = new TestDatabase();
    }
    return TestDatabase.instance;
  }

  public getPrisma(): PrismaClient {
    return this.prisma;
  }

  public async connect(): Promise<void> {
    if (!this.isConnected) {
      try {
        await this.prisma.$connect();
        this.isConnected = true;
        console.log('✅ Test database connected successfully');
      } catch (error) {
        console.error('❌ Failed to connect to test database:', error);
        throw error;
      }
    }
  }

  public async disconnect(): Promise<void> {
    if (this.isConnected) {
      try {
        await this.prisma.$disconnect();
        this.isConnected = false;
        console.log('✅ Test database disconnected successfully');
      } catch (error) {
        console.error('❌ Failed to disconnect from test database:', error);
        throw error;
      }
    }
  }

  public async clearDatabase(): Promise<void> {
    if (!this.isConnected) {
      throw new Error('Database not connected');
    }

    try {
      // Delete all records in reverse order of dependencies
      await this.prisma.transaction.deleteMany({});
      await this.prisma.subscription.deleteMany({});
      await this.prisma.funding.deleteMany({});
      await this.prisma.paymentMethod.deleteMany({});
      await this.prisma.bankAccount.deleteMany({});
      await this.prisma.fundingPlatform.deleteMany({});
      await this.prisma.user.deleteMany({});

      console.log('✅ Test database cleared successfully');
    } catch (error) {
      console.error('❌ Failed to clear test database:', error);
      throw error;
    }
  }

  public async seedDatabase(): Promise<void> {
    if (!this.isConnected) {
      throw new Error('Database not connected');
    }

    try {
      // Seed test users
      const testUser1 = await this.prisma.user.create({
        data: {
          email: 'test1@example.com',
          password: 'hashed_password_1',
          name: 'Test User1',
        },
      });

      const testUser2 = await this.prisma.user.create({
        data: {
          email: 'test2@example.com',
          password: 'hashed_password_2',
          name: 'Test User2',
        },
      });

      // Seed funding platforms
      const platform1 = await this.prisma.fundingPlatform.create({
        data: {
          name: 'Test Platform 1',
          description: 'A test funding platform for automated testing',
          type: 'INVESTMENT',
        },
      });

      const platform2 = await this.prisma.fundingPlatform.create({
        data: {
          name: 'Test Platform 2',
          description: 'Another test funding platform',
          type: 'AFFILIATE',
        },
      });

      // Seed payment methods
      const paymentMethod1 = await this.prisma.paymentMethod.create({
        data: {
          userId: testUser1.id,
          type: 'CARD',
          provider: 'Test Bank',
          last4: '4242',
          expiryMonth: 12,
          expiryYear: 2025,
          isDefault: true,
        },
      });

      const paymentMethod2 = await this.prisma.paymentMethod.create({
        data: {
          userId: testUser1.id,
          type: 'PAYPAL',
          provider: 'PayPal',
          last4: 'paypal',
          isDefault: false,
        },
      });

      // Seed bank accounts
      const bankAccount1 = await this.prisma.bankAccount.create({
        data: {
          userId: testUser1.id,
          bankCode: '123456',
          accountNumber: '1234567890',
          accountName: 'Test Bank',
          isDefault: true,
        },
      });

      const funding1 = await this.prisma.funding.create({
        data: {
          userId: testUser1.id,
          platformId: platform1.id,
          amount: 1000,
          profitShare: 0.1,
          status: 'ACTIVE',
        },
      });

      // Seed transactions
      const transaction1 = await this.prisma.transaction.create({
        data: {
          userId: testUser1.id,
          amount: 1000,
          type: 'DEPOSIT',
          description: 'Initial deposit for testing',
        },
      });

      const transaction2 = await this.prisma.transaction.create({
        data: {
          userId: testUser1.id,
          amount: 1000,
          type: 'PROFIT',
          description: 'Investment profit',
          fundingId: funding1.id,
        },
      });

      console.log('✅ Test database seeded successfully');
    } catch (error) {
      throw error;
    }
  }

  public async resetDatabase(): Promise<void> {
    await this.clearDatabase();
    await this.seedDatabase();
  }
}

// Mock database for unit tests
export const createMockPrisma = (): DeepMockProxy<PrismaClient> => {
  return mockDeep<PrismaClient>();
};

// Test utilities
export const testUtils = {
  createTestUser: async (prisma: PrismaClient, overrides: any = {}) => {
    return await prisma.user.create({
      data: {
        email: `test${Date.now()}@example.com`,
        password: 'hashed_password',
        name: 'Test User',
        ...overrides,
      },
    });
  },

  createTestPaymentMethod: async (prisma: PrismaClient, userId: string, overrides: any = {}) => {
    return await prisma.paymentMethod.create({
      data: {
        userId,
        type: 'CARD',
        provider: 'Test Bank',
        last4: '4242',
        expiryMonth: 12,
        expiryYear: 2025,
        isDefault: false,
        ...overrides,
      },
    });
  },

  createTestFundingPlatform: async (prisma: PrismaClient, overrides: any = {}) => {
    return await prisma.fundingPlatform.create({
      data: {
        name: 'Test Platform',
        description: 'A test funding platform',
        type: 'INVESTMENT',
        ...overrides,
      },
    });
  },

  createTestTransaction: async (prisma: PrismaClient, userId: string, overrides: any = {}) => {
    return await prisma.transaction.create({
      data: {
        userId,
        amount: 1000,
        type: 'DEPOSIT',
        description: 'Test transaction',
        ...overrides,
      },
    });
  },
};

// Test data factories
export const testDataFactory = {
  user: {
    valid: () => ({
      email: `test${Date.now()}@example.com`,
      password: 'TestPassword123!',
      name: 'Test User',
    }),

    invalid: {
      noEmail: { password: 'password123', name: 'Test User' },
      noPassword: { email: 'test@example.com', name: 'Test User' },
      invalidEmail: { email: 'invalid-email', password: 'password123', name: 'Test User' },
      weakPassword: { email: 'test@example.com', password: '123', name: 'Test User' },
    },
  },

  paymentMethod: {
    card: (userId: string) => ({
      userId,
      type: 'CARD' as const,
      provider: 'Test Bank',
      last4: '4242',
      expiryMonth: 12,
      expiryYear: 2025,
      holderName: 'Test User',
    }),

    paypal: (userId: string) => ({
      userId,
      type: 'PAYPAL' as const,
      provider: 'PayPal',
      last4: 'paypal',
      paypalEmail: 'test@example.com',
    }),

    invalid: {
      noType: { provider: 'Test Bank', last4: '4242' },
      invalidType: { type: 'INVALID', provider: 'Test Bank', last4: '4242' },
      invalidCard: { type: 'CARD', provider: 'Test Bank', last4: '123' }, // Invalid card number
    },
  },

  fundingPlatform: {
    valid: () => ({
      name: 'Test Platform',
      description: 'A comprehensive test funding platform with all required fields',
      type: 'P2P_LENDING' as const,
    }),

    invalid: {
      noName: { description: 'Test platform', type: 'INVESTMENT' },
      noDescription: { name: 'Test Platform', type: 'INVESTMENT' },
      invalidCategory: { name: 'Test Platform', description: 'Test platform', type: 'INVALID' },
    },
  },
};
