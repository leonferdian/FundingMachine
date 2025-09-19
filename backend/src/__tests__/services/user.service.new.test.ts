import 'reflect-metadata';
import 'jest';
import { UserService } from '../../services/user.service';
import { UserRepository } from '../../repositories/user.repository';
import { container } from 'tsyringe';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';

// Mock the bcrypt module
jest.mock('bcryptjs');
const mockedBcrypt = bcrypt as jest.Mocked<typeof bcrypt>;
mockedBcrypt.hash.mockResolvedValue('hashedpassword123');
mockedBcrypt.compare.mockResolvedValue(true);

// Mock the jsonwebtoken module
jest.mock('jsonwebtoken');
const mockedJwt = jwt as jest.Mocked<typeof jwt>;
mockedJwt.sign.mockReturnValue('mocked-jwt-token' as any);

// Mock the config module
jest.mock('../../config/config', () => ({
  jwt: {
    secret: 'test-secret',
    expiresIn: '1h',
  },
}));

// Create a mock UserRepository
const mockUserRepository: jest.Mocked<UserRepository> = {
  // BaseRepository methods
  create: jest.fn(),
  findUnique: jest.fn(),
  findMany: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
  count: jest.fn(),
  exists: jest.fn(),
  findFirst: jest.fn(),
  updateMany: jest.fn(),
  deleteMany: jest.fn(),
  upsert: jest.fn(),
  aggregate: jest.fn(),
  groupBy: jest.fn(),
  
  // UserRepository specific methods
  findByEmail: jest.fn(),
  updatePassword: jest.fn(),
  markAsVerified: jest.fn(),
} as any; // Use type assertion to bypass TypeScript checks

// Register the mock repository with the DI container
container.register('UserRepository', {
  useValue: mockUserRepository,
});

describe('UserService', () => {
  let userService: UserService;

  beforeEach(() => {
    // Clear all mocks
    jest.clearAllMocks();
    
    // Create a new instance of UserService with the mocked repository
    userService = new UserService(mockUserRepository);
  });

  describe('register', () => {
    it('should create a new user', async () => {
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
      mockedBcrypt.hash.mockResolvedValueOnce('hashedpassword123');

      // Act
      const result = await userService.register(userData);

      // Assert
      expect(result).toHaveProperty('id');
      expect(result.name).toBe(userData.name);
      expect(result.email).toBe(userData.email);
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(userData.email);
      expect(mockedBcrypt.hash).toHaveBeenCalledWith(userData.password, 10);
      expect(mockUserRepository.create).toHaveBeenCalledWith({
        ...userData,
        password: 'hashedpassword123',
      });
    });

    it('should throw an error if email already exists', async () => {
      // Arrange
      const userData = {
        name: 'Existing User',
        email: 'existing@example.com',
        password: 'password123',
        phone: '+1234567890',
      };

      // Setup mock to return an existing user
      mockUserRepository.findByEmail.mockResolvedValue({
        id: 'existing-user-id',
        ...userData,
        password: 'hashedpassword',
      } as any);

      // Act & Assert
      await expect(userService.register(userData)).rejects.toThrow(
        'User with this email already exists'
      );
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(userData.email);
      expect(mockUserRepository.create).not.toHaveBeenCalled();
    });
  });

  describe('login', () => {
    it('should return a user and token for valid credentials', async () => {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const user = {
        id: '1',
        name: 'Test User',
        email,
        password: 'hashedpassword123',
        phone: '+1234567890',
        avatar: null,
        isVerified: true,
        role: 'USER',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Setup mocks
      mockUserRepository.findByEmail.mockResolvedValue(user as any);
      mockedBcrypt.compare.mockResolvedValueOnce(true);
      mockedJwt.sign.mockReturnValue('mocked-jwt-token' as any);

      // Act
      const result = await userService.login(email, password);

      // Assert
      expect(result).toHaveProperty('user');
      expect(result).toHaveProperty('token', 'mocked-jwt-token');
      expect(result.user.email).toBe(email);
      expect((result.user as any).password).toBeUndefined();
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(email);
      expect(mockedBcrypt.compare).toHaveBeenCalledWith(password, user.password);
      expect(mockedJwt.sign).toHaveBeenCalledWith(
        { userId: user.id, email: user.email },
        'test-secret',
        { expiresIn: '1h' }
      );
    });

    it('should throw an error for invalid credentials', async () => {
      // Arrange
      const email = 'nonexistent@example.com';
      const password = 'wrongpassword';

      // Setup mocks
      mockUserRepository.findByEmail.mockResolvedValue(null);

      // Act & Assert
      await expect(userService.login(email, password)).rejects.toThrow('Invalid credentials');
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(email);
      expect(mockedBcrypt.compare).not.toHaveBeenCalled();
    });

    it('should throw an error for incorrect password', async () => {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrongpassword';
      const user = {
        id: '1',
        email,
        password: 'hashedpassword123',
      };

      // Setup mocks
      mockUserRepository.findByEmail.mockResolvedValue(user as any);
      mockedBcrypt.compare.mockResolvedValueOnce(false);

      // Act & Assert
      await expect(userService.login(email, password)).rejects.toThrow('Invalid credentials');
      expect(mockedBcrypt.compare).toHaveBeenCalledWith(password, user.password);
    });
  });
});
