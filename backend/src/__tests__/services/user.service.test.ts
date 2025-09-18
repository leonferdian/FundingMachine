import 'jest';
import { UserService } from '../../services/user.service';
import { UserRepository } from '../../repositories/user.repository';
import { prismaMock } from '../setup';
import { User, Prisma, Role } from '@prisma/client';
import { hash, compare } from 'bcryptjs';
import * as jwt from 'jsonwebtoken';
import config from '../../config/config';

// Mock the entire Prisma client
jest.mock('@prisma/client', () => {
  return {
    PrismaClient: jest.fn().mockImplementation(() => ({
      user: {
        create: jest.fn(),
        findUnique: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
        findMany: jest.fn(),
        count: jest.fn(),
      },
      $connect: jest.fn(),
      $disconnect: jest.fn(),
    })),
    Role: {
      USER: 'USER',
      ADMIN: 'ADMIN',
    },
  };
});

// Mock bcrypt and jwt
jest.mock('bcryptjs');
jest.mock('jsonwebtoken');

const mockUser: User = {
  id: '1',
  name: 'Test User',
  email: 'test@example.com',
  phone: '+1234567890',
  password: 'hashedpassword',
  avatar: null,
  isVerified: false,
  role: 'USER',
  createdAt: new Date(),
  updatedAt: new Date(),
};

describe('UserService', () => {
  let userService: UserService;
  let userRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    // Reset all mocks
    jest.clearAllMocks();
    
    // Create a mock user repository
    userRepository = {
      ...prismaMock.user,
      findByEmail: jest.fn(),
      updatePassword: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
    } as unknown as jest.Mocked<UserRepository>;

    // Create user service with mock repository
    userService = new UserService(userRepository);
  });

  describe('register', () => {
    it('should register a new user', async () => {
      // Arrange
      const userData = {
        name: 'New User',
        email: 'new@example.com',
        password: 'password123',
        phone: '+1234567890',
      };

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);
      (hash as jest.Mock).mockResolvedValue('hashedpassword');
      (userRepository.create as jest.Mock).mockResolvedValue({
        ...mockUser,
        ...userData,
        password: 'hashedpassword',
      });

      // Act
      const result = await userService.register(userData);

      // Assert
      expect(result).toMatchObject({
        name: userData.name,
        email: userData.email,
      });
      expect(hash).toHaveBeenCalledWith(userData.password, 10);
    });

    it('should throw an error if user already exists', async () => {
      // Arrange
      const userData = {
        name: 'Existing User',
        email: 'existing@example.com',
        password: 'password123',
        phone: '+1234567890',
      };

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(mockUser);

      // Act & Assert
      await expect(userService.register(userData)).rejects.toThrow(
        'User with this email already exists'
      );
    });
  });

  describe('login', () => {
    it('should login a user with valid credentials', async () => {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const token = 'test-token';

      (userRepository.findByEmail as jest.Mock).mockResolvedValue({
        ...mockUser,
        password: 'hashedpassword',
      });
      (compare as jest.Mock).mockResolvedValue(true);
      (jwt.sign as jest.Mock).mockReturnValue(token);

      // Act
      const result = await userService.login(email, password);

      // Assert
      expect(result.user).not.toHaveProperty('password');
      expect(result.token).toBe(token);
      expect(jwt.sign).toHaveBeenCalledWith(
        { userId: mockUser.id, email: mockUser.email },
        config.jwt.secret,
        { expiresIn: config.jwt.expiresIn }
      );
    });

    it('should throw an error with invalid credentials', async () => {
      // Arrange
      const email = 'nonexistent@example.com';
      const password = 'wrongpassword';

      (userRepository.findByEmail as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(userService.login(email, password)).rejects.toThrow(
        'Invalid credentials'
      );
    });
  });

  describe('changePassword', () => {
    it('should change the password with valid current password', async () => {
      // Arrange
      const userId = '1';
      const currentPassword = 'oldPassword';
      const newPassword = 'newSecurePassword';
      const hashedNewPassword = 'hashedNewPassword';

      (userRepository.findUnique as jest.Mock).mockResolvedValue({
        ...mockUser,
        password: 'hashedOldPassword',
      });
      (compare as jest.Mock).mockResolvedValue(true);
      (hash as jest.Mock).mockResolvedValue(hashedNewPassword);
      (userRepository.update as jest.Mock).mockResolvedValue({
        ...mockUser,
        password: hashedNewPassword,
      });

      // Act
      await userService.changePassword(userId, currentPassword, newPassword);

      // Assert
      expect(compare).toHaveBeenCalledWith(currentPassword, 'hashedOldPassword');
      expect(hash).toHaveBeenCalledWith(newPassword, 10);
      expect(userRepository.update).toHaveBeenCalledWith(
        { id: userId },
        { password: hashedNewPassword }
      );
    });
  });
});
