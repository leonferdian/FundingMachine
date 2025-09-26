import 'reflect-metadata';
import { container } from 'tsyringe';
import { UserRepository } from '../repositories';
import { UserService } from '../services';

// Create a mock PrismaClient for now to get the app running
const prisma = {
  // Add basic methods as needed
  $connect: async () => console.log('Mock DB connected'),
  $disconnect: async () => console.log('Mock DB disconnected'),
  user: {
    findMany: async () => [],
    findUnique: async () => null,
    create: async () => ({}),
    update: async () => ({}),
    delete: async () => ({})
  }
};

/**
 * Configure and register all dependencies for dependency injection
 */
export const configureDI = () => {
  // Register Prisma Client as a singleton
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
