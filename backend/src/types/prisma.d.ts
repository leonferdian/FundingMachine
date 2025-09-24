import { PrismaClient as BasePrismaClient } from '@prisma/client';

declare module '@prisma/client' {
  interface PrismaClient extends BasePrismaClient {
    // Add custom methods here if needed
  }
}
