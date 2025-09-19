import 'reflect-metadata';
import { UserService } from '../../services/user.service';
import { BaseRepository } from '../../repositories/base.repository';
import { PrismaClient } from '@prisma/client';

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

// Create an instance of the mock repository
const mockUserRepository = new MockUserRepository();

// Mock bcrypt
jest.mock('bcryptjs', () => ({
  hash: jest.fn().mockResolvedValue('hashedpassword123'),
}));

// Mock config
jest.mock('../../config/config', () => ({
  jwt: {
    secret: 'test-secret',
    expiresIn: '1h',
  },
}));

describe('UserService - Simplified', () => {
  let userService: UserService;

  beforeEach(() => {
    // Clear all mocks
    jest.clearAllMocks();
    
    // Create a new instance of UserService with the mocked repository
    userService = new UserService(mockUserRepository as any);
  });

  describe('register', () => {
    it('should create a new user with hashed password', async () => {
      // Arrange
      const userData = {
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        phone: '+1234567890',
      };

      const createdUser = {
        id: '1',
        ...userData,
        password: 'hashedpassword123',
        avatar: null,
        isVerified: false,
        role: 'USER',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Setup mock implementations
      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockUserRepository.create.mockResolvedValue(createdUser);

      // Act
      const result = await userService.register(userData);

      // Assert
      expect(result).toHaveProperty('id');
      expect(result.name).toBe(userData.name);
      expect(result.email).toBe(userData.email);
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(userData.email);
      expect(mockUserRepository.create).toHaveBeenCalledWith({
        ...userData,
        password: 'hashedpassword123',
      });
    });
  });
});
