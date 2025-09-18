import { container } from 'tsyringe';
import { UserRepository } from '../repositories';
import { UserService } from './user.service';
import { PrismaClient } from '@prisma/client';

// Register services with dependency injection
export const registerServices = () => {
  // Register repositories if not already registered
  if (!container.isRegistered('UserRepository')) {
    const prisma = new PrismaClient();
    container.register('PrismaClient', { useValue: prisma });
    container.register('UserRepository', { useClass: UserRepository });
  }

  // Register services
  container.register('UserService', { useClass: UserService });
};

// Export services
export * from './base.service';
export * from './user.service';
