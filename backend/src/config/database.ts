import { PrismaClient } from '@prisma/client';
import config from './config';

// Add prisma to the NodeJS global type
declare global {
  // eslint-disable-next-line no-var
  var prisma: PrismaClient | undefined;
}

// Prevent multiple instances of Prisma Client in development
const prisma: PrismaClient = global.prisma || new PrismaClient({
  log: process.env.NODE_ENV === 'development' 
    ? ['query', 'info', 'warn', 'error'] 
    : ['error'],
});

// Store prisma in globalThis in development to prevent hot-reloading issues
if (process.env.NODE_ENV === 'development') {
  global.prisma = prisma;
}

/**
 * Connects to the database and verifies the connection
 */
export const connectDB = async (): Promise<void> => {
  try {
    await prisma.$connect();
    console.log('✅ Database connected successfully');
    
    // Verify the database connection
    await prisma.$queryRaw`SELECT 1`;
    console.log('✅ Database connection verified');
  } catch (error) {
    console.error('❌ Database connection error:', error);
    throw error;
  }
};

// Handle process termination
process.on('SIGINT', async () => {
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  await prisma.$disconnect();
  process.exit(0);
});

export default prisma;
