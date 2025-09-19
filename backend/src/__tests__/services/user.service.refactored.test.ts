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
      const createdUser = createMockUser({
        ...userData,
        password: hashedPassword,
        isVerified: false,
      });

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
      const existingUser = createMockUser();
      mockUserRepository.findByEmail.mockResolvedValue(existingUser);

      // Act & Assert
      await expect(userService.register({
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        phone: '+1234567890',
      })).rejects.toThrow(UserServiceError);
      
      await expect(userService.register({
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        phone: '+1234567890',
      })).rejects.toMatchObject({
        message: 'User with this email already exists',
      });
    });
  });

  describe('login', () => {
    const email = 'test@example.com';
    const password = 'password123';
    const hashedPassword = 'hashed_password123';
    
    const mockUser = createMockUser({
      email,
      password: hashedPassword,
      isVerified: true,
    });

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
        avatar: mockUser.avatar,
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
      const unverifiedUser = createMockUser({
        email,
        password: hashedPassword,
        isVerified: false,
      });
      
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
});

// Mock config
jest.mock('../../config/config', () => ({
  jwt: {
    secret: 'test-secret',
    expiresIn: '1h',
  },
}));
