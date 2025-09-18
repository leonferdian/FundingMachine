import 'reflect-metadata';
import { container } from 'tsyringe';
import { PrismaClient } from '@prisma/client';
import { UserRepository } from '../repositories';
import { UserService } from '../services';

/**
 * Configure and register all dependencies for dependency injection
 */
export const configureDI = () => {
  // Register Prisma Client as a singleton
  const prisma = new PrismaClient();
  container.register('PrismaClient', { useValue: prisma });

  // Register repositories
  container.register('UserRepository', { useClass: UserRepository });
  
  // Register services
  container.register('UserService', { useClass: UserService });

  // Return the container in case it's needed for further configuration
  return container;
};

// Export the configured container
export const diContainer = configureDI();

// Export types for type-safe dependency injection
export const TYPES = {
  UserRepository: 'UserRepository',
  UserService: 'UserService',
  PrismaClient: 'PrismaClient',
};
