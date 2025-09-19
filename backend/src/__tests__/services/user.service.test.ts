import 'reflect-metadata';
import { UserService, UserServiceError } from '../../services/user.service';
import { IUserRepository, IAuthService } from '../../interfaces/user-service.interface';

// Define the User type for testing
interface User {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  password: string;
  avatar: string | null;
  isVerified: boolean;
  role: 'USER' | 'ADMIN';
  createdAt: Date;
  updatedAt: Date;
}

// Define Role enum for testing
enum Role {
  USER = 'USER',
  ADMIN = 'ADMIN',
}

// Helper function to create a mock user
const createMockUser = (overrides: Partial<User> = {}): User => ({
  id: '1',
  name: 'Test User',
  email: 'test@example.com',
  phone: '+1234567890',
  password: 'hashedpassword123',
  avatar: null,
  isVerified: true,
  role: Role.USER,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides,
});

// Mock the dependencies
const mockUserRepository: jest.Mocked<IUserRepository> = {
  findByEmail: jest.fn(),
  create: jest.fn(),
  findById: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
  updatePassword: jest.fn(),
  markAsVerified: jest.fn(),
  exists: jest.fn(),
};
  exists: jest.fn(),
};

const mockAuthService: jest.Mocked<IAuthService> = {
  hashPassword: jest.fn(),
  comparePasswords: jest.fn(),
  generateToken: jest.fn(),
  verifyToken: jest.fn(),
};

describe('UserService', () => {
  let userService: UserService;

  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
    
    // Create a new instance of UserService with the mocked dependencies
    userService = new UserService(mockUserRepository, mockAuthService);
  });

  describe('register', () => {
    const userData = {
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      phone: '+1234567890',
    };

    it('should register a new user', async () => {
      // Arrange
      const hashedPassword = 'hashed_password123';
      const createdUser: User = {
        id: '1',
        ...userData,
        password: hashedPassword,
        isVerified: false,
        role: Role.USER,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockAuthService.hashPassword.mockResolvedValue(hashedPassword);
      mockUserRepository.create.mockResolvedValue(createdUser);

      // Act
      const result = await userService.register(userData);

      // Assert
      expect(result).toEqual(createdUser);
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(userData.email);
      expect(mockAuthService.hashPassword).toHaveBeenCalledWith(userData.password);
      expect(mockUserRepository.create).toHaveBeenCalledWith({
        ...userData,
        password: hashedPassword,
        isVerified: false,
      });
    });

    it('should throw an error if user already exists', async () => {
      // Arrange
      const existingUser: User = {
        id: '1',
        ...userData,
        password: 'hashed_password123',
        isVerified: true,
        role: Role.USER,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockUserRepository.findByEmail.mockResolvedValue(existingUser);

      // Act & Assert
      await expect(userService.register(userData)).rejects.toThrow(
        UserServiceError
      );
      await expect(userService.register(userData)).rejects.toMatchObject({
        message: 'User with this email already exists',
      });
    });
  });

  describe('login', () => {
    const email = 'test@example.com';
    const password = 'password123';
    const hashedPassword = 'hashed_password123';
    
    const mockUser: User = {
      id: '1',
      name: 'Test User',
      email,
      password: hashedPassword,
      phone: '+1234567890',
      isVerified: true,
      role: Role.USER,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    it('should login a user with valid credentials', async () => {
      // Arrange
      const token = 'test-jwt-token';
      
      mockUserRepository.findByEmail.mockResolvedValue(mockUser);
      mockAuthService.comparePasswords.mockResolvedValue(true);
      mockAuthService.generateToken.mockReturnValue(token);

      // Act
      const result = await userService.login(email, password);

      // Assert
      expect(result.user).toEqual({
        id: mockUser.id,
        name: mockUser.name,
        email: mockUser.email,
        phone: mockUser.phone,
        isVerified: mockUser.isVerified,
        role: mockUser.role,
        createdAt: mockUser.createdAt,
        updatedAt: mockUser.updatedAt,
      });
      expect(result.token).toBe(token);
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(email);
      expect(mockAuthService.comparePasswords).toHaveBeenCalledWith(password, hashedPassword);
    });

    it('should throw an error for invalid email', async () => {
      // Arrange
      mockUserRepository.findByEmail.mockResolvedValue(null);

      // Act & Assert
      await expect(userService.login('nonexistent@example.com', password)).rejects.toThrow(
        UserServiceError
      );
      await expect(userService.login('nonexistent@example.com', password)).rejects.toMatchObject({
        message: 'Invalid credentials',
        statusCode: 401,
      });
    });

    it('should throw an error for invalid password', async () => {
      // Arrange
      mockUserRepository.findByEmail.mockResolvedValue(mockUser);
      mockAuthService.comparePasswords.mockResolvedValue(false);

      // Act & Assert
      await expect(userService.login(email, 'wrongpassword')).rejects.toThrow(
        UserServiceError
      );
      await expect(userService.login(email, 'wrongpassword')).rejects.toMatchObject({
        message: 'Invalid credentials',
        statusCode: 401,
      });
    });

    it('should throw an error for unverified email', async () => {
      // Arrange
      const unverifiedUser = { ...mockUser, isVerified: false };
      mockUserRepository.findByEmail.mockResolvedValue(unverifiedUser);
      mockAuthService.comparePasswords.mockResolvedValue(true);

      // Act & Assert
      await expect(userService.login(email, password)).rejects.toThrow(
        UserServiceError
      );
      await expect(userService.login(email, password)).rejects.toMatchObject({
        message: 'Please verify your email address',
        statusCode: 403,
      });
    });
  });

  describe('verifyEmail', () => {
    it('should verify email with a valid token', async () => {
      // Arrange
      const token = 'valid-token';
      const userId = '1';
      
      mockAuthService.verifyToken.mockReturnValue({ userId, email: 'test@example.com' });
      mockUserRepository.markAsVerified.mockResolvedValue(undefined);

      // Act
      const result = await userService.verifyEmail(token);

      // Assert
      expect(result).toBe(true);
      expect(mockAuthService.verifyToken).toHaveBeenCalledWith(token);
      expect(mockUserRepository.markAsVerified).toHaveBeenCalledWith(userId);
    });

    it('should throw an error for invalid token', async () => {
      // Arrange
      const token = 'invalid-token';
      
      mockAuthService.verifyToken.mockImplementation(() => {
        throw new Error('Invalid token');
      });

      // Act & Assert
      await expect(userService.verifyEmail(token)).rejects.toThrow(
        UserServiceError
      );
      await expect(userService.verifyEmail(token)).rejects.toMatchObject({
        message: 'Invalid or expired verification token',
        statusCode: 400,
      });
    });
  });

  describe('changePassword', () => {
    const userId = '1';
    const currentPassword = 'current-password';
    const newPassword = 'new-password';
    const hashedNewPassword = 'hashed-new-password';
    
    const mockUser: User = {
      id: userId,
      name: 'Test User',
      email: 'test@example.com',
      password: 'hashed-current-password',
      phone: '+1234567890',
      isVerified: true,
      role: Role.USER,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    it('should change the password with valid current password', async () => {
      // Arrange
      mockUserRepository.findById.mockResolvedValue(mockUser);
      mockAuthService.comparePasswords.mockResolvedValue(true);
      mockAuthService.hashPassword.mockResolvedValue(hashedNewPassword);
      mockUserRepository.updatePassword.mockResolvedValue(undefined);

      // Act
      await userService.changePassword(userId, currentPassword, newPassword);

      // Assert
      expect(mockUserRepository.findById).toHaveBeenCalledWith(userId);
      expect(mockAuthService.comparePasswords).toHaveBeenCalledWith(currentPassword, mockUser.password);
      expect(mockAuthService.hashPassword).toHaveBeenCalledWith(newPassword);
      expect(mockUserRepository.updatePassword).toHaveBeenCalledWith(userId, hashedNewPassword);
    });

    it('should throw an error if user not found', async () => {
      // Arrange
      mockUserRepository.findById.mockResolvedValue(null);

      // Act & Assert
      await expect(
        userService.changePassword('nonexistent-user', currentPassword, newPassword)
      ).rejects.toThrow(UserServiceError);
    });

    it('should throw an error for incorrect current password', async () => {
      // Arrange
      mockUserRepository.findById.mockResolvedValue(mockUser);
      mockAuthService.comparePasswords.mockResolvedValue(false);

      // Act & Assert
      await expect(
        userService.changePassword(userId, 'wrong-password', newPassword)
      ).rejects.toThrow(UserServiceError);
    });
  });
});

// Mock config
jest.mock('../../config/config', () => ({
  jwt: {
    secret: 'test-secret',
    expiresIn: '1h',
  },
}));

// Mock bcrypt and jsonwebtoken
jest.mock('bcryptjs', () => ({
  hash: jest.fn().mockResolvedValue('hashedpassword123'),
  compare: jest.fn().mockResolvedValue(true),
}));

jest.mock('jsonwebtoken', () => ({
  sign: jest.fn().mockReturnValue('mocked-jwt-token'),
  verify: jest.fn().mockReturnValue({ userId: '1', email: 'test@example.com' }),
}));
}));

// Define the User type for testing
interface User {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  password: string;
  avatar: string | null;
  isVerified: boolean;
  role: 'USER' | 'ADMIN';
  createdAt: Date;
  updatedAt: Date;
}
jest.mock('../../config/config', () => ({
  jwt: {
    secret: 'test-secret',
    expiresIn: '1h',
  },
}));

// Mock the UserRepository
jest.mock('../../repositories/user.repository', () => {
  return {
    UserRepository: jest.fn().mockImplementation(() => ({
      create: jest.fn(),
      findUnique: jest.fn(),
      findByEmail: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      updatePassword: jest.fn(),
      markAsVerified: jest.fn(),
      exists: jest.fn(),
    })),
  };
});

// Create a mock User for testing
const createMockUser = (overrides: Partial<User> = {}): User => ({
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
  ...overrides,
});

describe('UserService', () => {
  let userService: UserService;
  let userRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    // Reset all mocks
    jest.clearAllMocks();
    
    // Create a fresh instance of UserService with a new mock repository
    const { UserRepository } = require('../../repositories/user.repository');
    userRepository = new UserRepository() as jest.Mocked<UserRepository>;
    userService = new UserService(userRepository);
  });

  (hash as jest.Mock).mockImplementation((password: string) => 
      Promise.resolve(`hashed${password}`)
    );
    
    (compare as jest.Mock).mockImplementation((plainText: string, hashed: string) => 
      Promise.resolve(hashed === `hashed${plainText}`)
    );

    (jwt.sign as jest.Mock).mockReturnValue('mocked-jwt-token');

    // Create user service with the mock repository
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

      const mockNewUser = createMockUser({
        ...userData,
        password: 'hashedpassword',
      });

      userRepository.findByEmail.mockResolvedValue(null);
      userRepository.create.mockResolvedValue(mockNewUser);

      // Act
      const result = await userService.register(userData);

      // Assert
      expect(result).toMatchObject({
        name: userData.name,
        email: userData.email,
      });
      expect(hash).toHaveBeenCalledWith(userData.password, 10);
      expect(userRepository.create).toHaveBeenCalledWith({
        ...userData,
        password: 'hashedpassword123', // This matches our mock implementation
      });
    });

    it('should throw an error if user already exists', async () => {
      // Arrange
      const userData = {
        name: 'Existing User',
        email: 'existing@example.com',
        password: 'password123',
        phone: '+1234567890',
      };

      const existingUser = createMockUser({ email: userData.email });
      userRepository.findByEmail.mockResolvedValue(existingUser);

      // Act & Assert
      await expect(userService.register(userData)).rejects.toThrow(
        'User with this email already exists'
      );
      expect(userRepository.findByEmail).toHaveBeenCalledWith(userData.email);
    });
  });

  describe('login', () => {
    it('should login a user with valid credentials', async () => {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const token = 'test-token';

      const user = createMockUser({
        email,
        password: 'hashedpassword123', // This matches our mock compare implementation
      });

      userRepository.findByEmail.mockResolvedValue(user);
      (jwt.sign as jest.Mock).mockReturnValue(token);

      // Act
      const result = await userService.login(email, password);

      // Assert
      expect(result.user).not.toHaveProperty('password');
      expect(result.token).toBe(token);
      expect(userRepository.findByEmail).toHaveBeenCalledWith(email);
      expect(compare).toHaveBeenCalledWith(password, user.password);
      expect(jwt.sign).toHaveBeenCalledWith(
        { userId: user.id, email: user.email },
        'test-secret',
        { expiresIn: '1h' }
      );
    });

    it('should throw an error with invalid credentials', async () => {
      // Arrange
      const email = 'nonexistent@example.com';
      const password = 'wrongpassword';

      userRepository.findByEmail.mockResolvedValue(null);

      // Act & Assert
      await expect(userService.login(email, password)).rejects.toThrow(
        'Invalid credentials'
      );
      expect(userRepository.findByEmail).toHaveBeenCalledWith(email);
    });
  });

  describe('changePassword', () => {
    it('should change the password with valid current password', async () => {
      // Arrange
      const userId = '1';
      const currentPassword = 'oldPassword';
      const newPassword = 'newSecurePassword';
      const hashedNewPassword = 'hashednewSecurePassword'; // Matches our mock hash implementation

      const user = createMockUser({
        id: userId,
        password: 'hashedoldPassword', // This will match our mock compare implementation
      });

      userRepository.findUnique.mockResolvedValue(user);
      userRepository.update.mockResolvedValue({
        ...user,
        password: hashedNewPassword,
      });

      // Act
      await userService.changePassword(userId, currentPassword, newPassword);

      // Assert
      expect(userRepository.findUnique).toHaveBeenCalledWith({ id: userId });
      expect(compare).toHaveBeenCalledWith(currentPassword, user.password);
      expect(hash).toHaveBeenCalledWith(newPassword, 10);
      expect(userRepository.update).toHaveBeenCalledWith(
        { id: userId },
        { password: hashedNewPassword }
      );
    });
  });
});
