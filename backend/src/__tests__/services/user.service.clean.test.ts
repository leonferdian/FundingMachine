import 'reflect-metadata';
import { User, Role } from '@prisma/client';
import { UserService, UserServiceError } from '../../services/user.service';
import { IUserRepository, IAuthService } from '../../interfaces/user-service.interface';

// Extend the User type to make all fields required for testing
type TestUser = Required<User>;

// Helper function to create a mock user
const createMockUser = (overrides: Partial<TestUser> = {}): TestUser => ({
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
} as TestUser);

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
    jest.clearAllMocks();
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
      const hashedPassword = 'hashed_password123';
      const createdUser = createMockUser({
        ...userData,
        password: hashedPassword,
        isVerified: false,
      });

      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockAuthService.hashPassword.mockResolvedValue(hashedPassword);
      mockUserRepository.create.mockResolvedValue(createdUser);

      const result = await userService.register(userData);

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
      const existingUser = createMockUser();
      mockUserRepository.findByEmail.mockResolvedValue(existingUser);

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
      const token = 'test-jwt-token';
      
      mockUserRepository.findByEmail.mockResolvedValue(mockUser);
      mockAuthService.comparePasswords.mockResolvedValue(true);
      mockAuthService.generateToken.mockReturnValue(token);

      const result = await userService.login(email, password);

      // Use object destructuring to exclude password
      const { password: _, ...expectedUser } = mockUser;
      expect(result.user).toEqual(expectedUser);
      expect(result.token).toBe(token);
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(email);
      expect(mockAuthService.comparePasswords).toHaveBeenCalledWith(password, hashedPassword);
    });

    it('should throw an error for invalid email', async () => {
      mockUserRepository.findByEmail.mockResolvedValue(null);

      await expect(userService.login('nonexistent@example.com', password)).rejects.toThrow(
        UserServiceError
      );
      await expect(userService.login('nonexistent@example.com', password)).rejects.toMatchObject({
        message: 'Invalid credentials',
        statusCode: 401,
      });
    });

    it('should throw an error for invalid password', async () => {
      mockUserRepository.findByEmail.mockResolvedValue(mockUser);
      mockAuthService.comparePasswords.mockResolvedValue(false);

      await expect(userService.login(email, 'wrongpassword')).rejects.toThrow(
        UserServiceError
      );
      await expect(userService.login(email, 'wrongpassword')).rejects.toMatchObject({
        message: 'Invalid credentials',
        statusCode: 401,
      });
    });

    it('should throw an error for unverified email', async () => {
      const unverifiedUser = createMockUser({
        email,
        password: hashedPassword,
        isVerified: false,
      });
      
      mockUserRepository.findByEmail.mockResolvedValue(unverifiedUser);
      mockAuthService.comparePasswords.mockResolvedValue(true);

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
      const token = 'valid-token';
      const userId = '1';
      const email = 'test@example.com';
      
      mockAuthService.verifyToken.mockReturnValue({ userId, email });
      mockUserRepository.markAsVerified.mockResolvedValue(undefined);

      const result = await userService.verifyEmail(token);

      expect(result).toBe(true);
      expect(mockAuthService.verifyToken).toHaveBeenCalledWith(token);
      expect(mockUserRepository.markAsVerified).toHaveBeenCalledWith(userId);
    });

    it('should throw an error for invalid token', async () => {
      const token = 'invalid-token';
      
      mockAuthService.verifyToken.mockImplementation(() => {
        throw new Error('Invalid token');
      });

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
    
    const mockUser = createMockUser({
      id: userId,
      password: 'hashed-current-password',
    });

    it('should change the password with valid current password', async () => {
      mockUserRepository.findById.mockResolvedValue(mockUser);
      mockAuthService.comparePasswords.mockResolvedValue(true);
      mockAuthService.hashPassword.mockResolvedValue(hashedNewPassword);
      mockUserRepository.updatePassword.mockResolvedValue(undefined);

      await userService.changePassword(userId, currentPassword, newPassword);

      expect(mockUserRepository.findById).toHaveBeenCalledWith(userId);
      expect(mockAuthService.comparePasswords).toHaveBeenCalledWith(
        currentPassword,
        mockUser.password
      );
      expect(mockAuthService.hashPassword).toHaveBeenCalledWith(newPassword);
      expect(mockUserRepository.updatePassword).toHaveBeenCalledWith(
        userId,
        hashedNewPassword
      );
    });

    it('should throw an error if user not found', async () => {
      mockUserRepository.findById.mockResolvedValue(null);

      await expect(
        userService.changePassword('nonexistent-user', currentPassword, newPassword)
      ).rejects.toThrow('User not found');
    });

    it('should throw an error for incorrect current password', async () => {
      mockUserRepository.findById.mockResolvedValue(mockUser);
      mockAuthService.comparePasswords.mockResolvedValue(false);

      await expect(
        userService.changePassword(userId, 'wrong-password', newPassword)
      ).rejects.toThrow('Current password is incorrect');
    });
  });
});
