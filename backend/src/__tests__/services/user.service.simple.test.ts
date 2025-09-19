// Simple test to check if we can import and instantiate UserService
import 'reflect-metadata';
import { UserService } from '../../services/user.service';
import { PrismaClient } from '@prisma/client';
import { BaseRepository } from '../../repositories/base.repository';

// Create a mock PrismaClient
const mockPrisma = {} as PrismaClient;

// Create a mock BaseRepository
class MockBaseRepository<T> extends BaseRepository<T> {
  constructor() {
    super(mockPrisma);
  }

  get model() {
    return {
      create: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      count: jest.fn(),
    };
  }
}

// Create a mock UserRepository
class MockUserRepository extends MockBaseRepository<any> {
  findByEmail = jest.fn();
  updatePassword = jest.fn();
  markAsVerified = jest.fn();
}

describe('UserService Simple Test', () => {
  it('should be able to create a UserService instance', () => {
    // Arrange
    const mockUserRepo = new MockUserRepository();

    // Act
    const userService = new UserService(mockUserRepo);

    // Assert
    expect(userService).toBeInstanceOf(UserService);
  });
});
