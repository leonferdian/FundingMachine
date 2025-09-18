import { container } from 'tsyringe';
import { PrismaClient } from '@prisma/client';
import { mockDeep, mockReset, DeepMockProxy } from 'jest-mock-extended';

// Create a mock Prisma client
const prismaMock = mockDeep<PrismaClient>();

// Reset all mocks before each test
beforeEach(() => {
  mockReset(prismaMock);
  // Clear all instances and calls to constructor and all methods
  jest.clearAllMocks();
});

// Register the mock Prisma client
container.register('PrismaClient', { useValue: prismaMock });

// Export the mock for use in tests
export { prismaMock };

// Global test timeout
jest.setTimeout(30000);
