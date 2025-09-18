// Import jest-dom for additional matchers
import '@testing-library/jest-dom';

// Mock any global objects or functions
(global as any).fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve({}),
  })
);

// Mock environment variables
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = 'file:./test.db';
process.env.JWT_SECRET = 'test-secret';
process.env.JWT_EXPIRES_IN = '1h';

// Mock console methods to keep test output clean
const originalConsole = { ...console };
const consoleMocks = ['log', 'error', 'warn', 'info', 'debug'];

beforeAll(() => {
  consoleMocks.forEach((method) => {
    jest.spyOn(console, method as any).mockImplementation(() => {});
  });
});

afterAll(() => {
  // Restore original console methods
  consoleMocks.forEach((method) => {
    (console[method as keyof Console] as any) = originalConsole[method as keyof Console];
  });
});

// Mock Prisma Client
jest.mock('@prisma/client', () => {
  const mockPrismaClient = {
    user: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      count: jest.fn(),
    },
    $connect: jest.fn(),
    $disconnect: jest.fn(),
    $on: jest.fn(),
  };

  return {
    PrismaClient: jest.fn(() => mockPrismaClient),
    PrismaClientKnownRequestError: jest.fn(),
    PrismaClientValidationError: jest.fn(),
    PrismaClientInitializationError: jest.fn(),
    PrismaClientRustPanicError: jest.fn(),
  };
});
