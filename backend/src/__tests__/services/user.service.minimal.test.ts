import 'reflect-metadata';
import 'jest';
import { UserService } from '../../services/user.service';
import { UserRepository } from '../../repositories/user.repository';

// Mock the UserRepository
jest.mock('../../repositories/user.repository');

// Mock bcrypt
jest.mock('bcryptjs', () => ({
  hash: jest.fn().mockResolvedValue('hashedpassword123'),
  compare: jest.fn().mockResolvedValue(true),
}));

// Mock jsonwebtoken
const mockJwt = {
  sign: jest.fn().mockReturnValue('mocked-jwt-token'),
  verify: jest.fn().mockReturnValue({ userId: '1', email: 'test@example.com' }),
};

jest.mock('jsonwebtoken', () => mockJwt);

// Mock config
jest.mock('../../config/config', () => ({
  jwt: {
    secret: 'test-secret',
    expiresIn: '1h',
  },
}));

describe('UserService - Minimal Test', () => {
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

  it('should create a user', async () => {
    // Arrange
    const userData = {
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      phone: '+1234567890',
    };

    userRepository.create.mockResolvedValue({
      id: '1',
      ...userData,
      password: 'hashedpassword123',
      avatar: null,
      isVerified: false,
      role: 'USER',
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Act
    const result = await userService.register(userData);

    // Assert
    expect(result).toHaveProperty('id');
    expect(result).toHaveProperty('name', userData.name);
    expect(result).toHaveProperty('email', userData.email);
    expect(userRepository.create).toHaveBeenCalledWith({
      ...userData,
      password: 'hashedpassword123',
    });
  });
});
