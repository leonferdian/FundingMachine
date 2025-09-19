import 'reflect-metadata';
import { UserService } from '../../services/user.service';
import { container } from 'tsyringe';

// Simple mock for UserRepository
const mockUserRepository = {
  findByEmail: jest.fn(),
  create: jest.fn(),
};

// Register the mock with the container
container.register('UserRepository', {
  useValue: mockUserRepository,
});

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

describe('UserService - Focused Test', () => {
  let userService: UserService;

  beforeEach(() => {
    jest.clearAllMocks();
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
      };

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
