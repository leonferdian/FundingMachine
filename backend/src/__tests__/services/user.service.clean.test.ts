import 'reflect-metadata';
import { UserService, UserServiceError } from '../../services/user.service';
import { IUserRepository, IAuthService } from '../../interfaces/user-service.interface';

// Import the Role enum from Prisma client
import { Role, User } from '@prisma/client';

// Import the RegisterUserData type from the service
import type { RegisterUserData } from '../../services/user.service';

// Define a test user type that matches the Prisma model
type TestUser = Omit<User, 'bankAccounts' | 'fundings' | 'transactions' | 'subscriptions'>;

// Helper function to create a mock user
const createMockUser = (overrides: Partial<TestUser> = {}): TestUser => {
  const now = new Date();
  return {
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    phone: '+1234567890',
    password: 'hashedpassword123',
    avatar: null,
    isVerified: true,
    role: Role.USER,
    createdAt: now,
    updatedAt: now,
    ...overrides,
  };
};

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
    // Create test data that matches RegisterUserData (Omit<User, 'id' | 'createdAt' | 'updatedAt' | 'isVerified'>)
    const userData = {
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      phone: '+1234567890',
      avatar: null,
      role: Role.USER,
      // These are relations and should not be included in RegisterUserData
      // bankAccounts: [],
      // fundings: [],
      // transactions: [],
      // subscriptions: []
    } as const;

    it('should register a new user', async () => {
      // Arrange
      const hashedPassword = 'hashed_password123';
// Create a full user object with all required fields
      const createdUser: User = {
        id: '1',
        ...userData,
        password: hashedPassword,
        isVerified: false,
        bankAccounts: [],
        fundings: [],
        transactions: [],
        subscriptions: [],
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

    it('should throw an error if email is already registered', async () => {
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
    });
  });

  describe('login', () => {
    const email = 'test@example.com';
    const password = 'password123';
    const hashedPassword = 'hashed_password123';
    
    it('should login with valid credentials', async () => {
      // Arrange
      const user = createMockUser({
        id: '1',
        email,
        password: hashedPassword,
        isVerified: true,
        role: Role.USER,
        avatar: null,
        phone: '+1234567890',
        name: 'Test User',
        createdAt: new Date(),
        updatedAt: new Date(),
      });
      
      mockUserRepository.findByEmail.mockResolvedValue(user);
      mockAuthService.comparePasswords.mockResolvedValue(true);
      mockAuthService.generateToken.mockReturnValue('test-token');

      // Act
      const result = await userService.login(email, password);

      // Assert
      expect(result).toHaveProperty('token', 'test-token');
      expect(result.user.email).toBe(email);
      expect(result.user).not.toHaveProperty('password');
      expect(mockAuthService.comparePasswords).toHaveBeenCalledWith(password, hashedPassword);
      expect(mockAuthService.generateToken).toHaveBeenCalledWith({
        userId: user.id,
        email: user.email,
      });
    });

    it('should throw an error for non-existent user', async () => {
      // Arrange
      mockUserRepository.findByEmail.mockResolvedValue(null);

      // Act & Assert
      await expect(userService.login('nonexistent@example.com', 'password123'))
        .rejects.toThrow(UserServiceError);
    });

    it('should throw an error for incorrect password', async () => {
      // Arrange
      const user = createMockUser({ email, password: hashedPassword });
      mockUserRepository.findByEmail.mockResolvedValue(user);
      mockAuthService.comparePasswords.mockResolvedValue(false);

      // Act & Assert
      await expect(userService.login(email, 'wrong-password'))
        .rejects.toThrow(UserServiceError);
    });

    it('should throw an error for unverified account', async () => {
      // Arrange
      const user = createMockUser({
        email,
        password: hashedPassword,
        isVerified: false,
      });
      mockUserRepository.findByEmail.mockResolvedValue(user);
      mockAuthService.comparePasswords.mockResolvedValue(true);

      // Act & Assert
      await expect(userService.login(email, password))
        .rejects.toThrow(UserServiceError);
    });
  });

  describe('changePassword', () => {
    const userId = '1';
    const currentPassword = 'current-password';
    const newPassword = 'new-password';
    const hashedNewPassword = 'hashed-new-password';

    it('should change the password with valid current password', async () => {
      // Arrange
      const user = createMockUser({ 
        id: userId, 
        password: 'current-hashed-password',
        role: Role.USER,
        isVerified: true,
        name: 'Test User',
        email: 'test@example.com',
        phone: '+1234567890',
        avatar: null
      });
      mockUserRepository.findById.mockResolvedValue(user);
      mockAuthService.comparePasswords.mockResolvedValue(true);
      mockAuthService.hashPassword.mockResolvedValue(hashedNewPassword);
      mockUserRepository.updatePassword.mockResolvedValue(undefined);

      // Act
      await userService.changePassword(userId, currentPassword, newPassword);

      // Assert
      expect(mockUserRepository.findById).toHaveBeenCalledWith(userId);
      expect(mockAuthService.comparePasswords).toHaveBeenCalledWith(currentPassword, user.password);
      expect(mockAuthService.hashPassword).toHaveBeenCalledWith(newPassword);
      expect(mockUserRepository.updatePassword).toHaveBeenCalledWith(userId, hashedNewPassword);
    });

    it('should throw an error for non-existent user', async () => {
      // Arrange
      mockUserRepository.findById.mockResolvedValue(null);

      // Act & Assert
      await expect(
        userService.changePassword('nonexistent-user', currentPassword, newPassword)
      ).rejects.toThrow(UserServiceError);
    });

    it('should throw an error for incorrect current password', async () => {
      // Arrange
      const user = createMockUser({ id: userId });
      mockUserRepository.findById.mockResolvedValue(user);
      mockAuthService.comparePasswords.mockResolvedValue(false);

      // Act & Assert
      await expect(
        userService.changePassword(userId, 'wrong-password', newPassword)
      ).rejects.toThrow(UserServiceError);
    });
  });
});
