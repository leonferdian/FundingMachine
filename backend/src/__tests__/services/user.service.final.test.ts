import 'reflect-metadata';
import { UserService, UserServiceError } from '../../services/user.service';
import { IUserRepository, IAuthService } from '../../interfaces/user-service.interface';
import { User, Role } from '@prisma/client';

describe('UserService', () => {
  let userService: UserService;
  let mockUserRepository: jest.Mocked<IUserRepository>;
  let mockAuthService: jest.Mocked<IAuthService>;

  // Helper function to create a test user
  const createTestUser = (overrides: Partial<User> = {}): User => ({
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    password: 'hashedpassword123',
    phone: '+1234567890',
    avatar: null,
    isVerified: true,
    role: Role.USER,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  });

  beforeEach(() => {
    // Create mock implementations
    mockUserRepository = {
      findByEmail: jest.fn(),
      create: jest.fn(),
      findById: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      updatePassword: jest.fn(),
      markAsVerified: jest.fn(),
      exists: jest.fn(),
    };

    mockAuthService = {
      hashPassword: jest.fn().mockResolvedValue('hashedpassword123'),
      comparePasswords: jest.fn().mockResolvedValue(true),
      generateToken: jest.fn().mockReturnValue('test-jwt-token'),
      verifyToken: jest.fn().mockImplementation((token) => ({
        userId: '1',
        email: 'test@example.com',
      })),
    };

    // Create an instance of the service with the mock dependencies
    userService = new UserService(mockUserRepository, mockAuthService);
  });

  afterEach(() => {
    jest.clearAllMocks();
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

      const createdUser = createTestUser({
        ...userData,
        password: 'hashedpassword123',
        isVerified: false,
      });

      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockUserRepository.create.mockResolvedValue(createdUser);

      // Act
      const result = await userService.register(userData);

      // Assert
      expect(result).toEqual(createdUser);
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(userData.email);
      expect(mockAuthService.hashPassword).toHaveBeenCalledWith(userData.password);
      expect(mockUserRepository.create).toHaveBeenCalledWith({
        ...userData,
        password: 'hashedpassword123',
        isVerified: false,
      });
    });

    it('should throw an error if user already exists', async () => {
      // Arrange
      const existingUser = createTestUser();
      mockUserRepository.findByEmail.mockResolvedValue(existingUser);

      // Act & Assert
      await expect(
        userService.register({
          name: 'Existing User',
          email: existingUser.email,
          password: 'password123',
          phone: '+1234567890',
        })
      ).rejects.toThrow(UserServiceError);
      
      await expect(
        userService.register({
          name: 'Existing User',
          email: existingUser.email,
          password: 'password123',
          phone: '+1234567890',
        })
      ).rejects.toMatchObject({
        message: 'User with this email already exists',
      });
    });
  });

  describe('login', () => {
    it('should login a user with valid credentials', async () => {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const user = createTestUser({ email, password: 'hashedpassword123' });
      const token = 'test-jwt-token';

      mockUserRepository.findByEmail.mockResolvedValue(user);
      mockAuthService.comparePasswords.mockResolvedValue(true);
      mockAuthService.generateToken.mockReturnValue(token);

      // Act
      const result = await userService.login(email, password);

      // Assert
      expect(result.token).toBe(token);
      expect(result.user.email).toBe(user.email);
      expect(result.user.name).toBe(user.name);
      expect('password' in result.user).toBe(false); // Password should be excluded
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(email);
      expect(mockAuthService.comparePasswords).toHaveBeenCalledWith(
        password,
        user.password
      );
    });

    it('should throw an error for invalid email', async () => {
      // Arrange
      mockUserRepository.findByEmail.mockResolvedValue(null);

      // Act & Assert
      await expect(
        userService.login('nonexistent@example.com', 'password123')
      ).rejects.toThrow(UserServiceError);
      
      await expect(
        userService.login('nonexistent@example.com', 'password123')
      ).rejects.toMatchObject({
        message: 'Invalid credentials',
        statusCode: 401,
      });
    });

    it('should throw an error for invalid password', async () => {
      // Arrange
      const user = createTestUser();
      mockUserRepository.findByEmail.mockResolvedValue(user);
      mockAuthService.comparePasswords.mockResolvedValue(false);

      // Act & Assert
      await expect(
        userService.login(user.email, 'wrongpassword')
      ).rejects.toThrow(UserServiceError);
      
      await expect(
        userService.login(user.email, 'wrongpassword')
      ).rejects.toMatchObject({
        message: 'Invalid credentials',
        statusCode: 401,
      });
    });
  });

  describe('verifyEmail', () => {
    it('should verify email with a valid token', async () => {
      // Arrange
      const token = 'valid-token';
      const userId = '1';
      
      mockUserRepository.markAsVerified.mockResolvedValue(undefined);

      // Act
      const result = await userService.verifyEmail(token);

      // Assert
      expect(result).toBe(true);
      expect(mockUserRepository.markAsVerified).toHaveBeenCalledWith(userId);
    });

    it('should throw an error for invalid token', async () => {
      // Arrange
      const token = 'invalid-token';
      
      mockAuthService.verifyToken.mockImplementation(() => {
        throw new Error('Invalid token');
      });

      // Act & Assert
      await expect(userService.verifyEmail(token)).rejects.toThrow(UserServiceError);
      
      await expect(userService.verifyEmail(token)).rejects.toMatchObject({
        message: 'Invalid or expired verification token',
        statusCode: 400,
      });
    });
  });

  describe('changePassword', () => {
    it('should change password with valid current password', async () => {
      // Arrange
      const userId = '1';
      const currentPassword = 'current-password';
      const newPassword = 'new-password';
      const user = createTestUser({ id: userId, password: 'hashed-current-password' });

      mockUserRepository.findById.mockResolvedValue(user);
      mockAuthService.hashPassword.mockResolvedValue('hashed-new-password');

      // Act
      await userService.changePassword(userId, currentPassword, newPassword);

      // Assert
      expect(mockUserRepository.findById).toHaveBeenCalledWith(userId);
      expect(mockAuthService.comparePasswords).toHaveBeenCalledWith(
        currentPassword,
        user.password
      );
      expect(mockAuthService.hashPassword).toHaveBeenCalledWith(newPassword);
      expect(mockUserRepository.updatePassword).toHaveBeenCalledWith(
        userId,
        'hashed-new-password'
      );
    });

    it('should throw an error if user not found', async () => {
      // Arrange
      mockUserRepository.findById.mockResolvedValue(null);

      // Act & Assert
      await expect(
        userService.changePassword('nonexistent-user', 'current', 'new')
      ).rejects.toThrow('User not found');
    });

    it('should throw an error for incorrect current password', async () => {
      // Arrange
      const user = createTestUser();
      mockUserRepository.findById.mockResolvedValue(user);
      mockAuthService.comparePasswords.mockResolvedValue(false);

      // Act & Assert
      await expect(
        userService.changePassword(user.id, 'wrong-password', 'new-password')
      ).rejects.toThrow('Current password is incorrect');
    });
  });
});
