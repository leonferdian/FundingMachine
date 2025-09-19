import 'reflect-metadata';
import { SimplifiedUserService } from '../../services/simplified-user.service';

describe('SimplifiedUserService', () => {
  let userService: SimplifiedUserService;
  let mockUserRepository: {
    findByEmail: jest.Mock;
    create: jest.Mock;
  };

  beforeEach(() => {
    // Create a mock user repository
    mockUserRepository = {
      findByEmail: jest.fn(),
      create: jest.fn(),
    };

    // Create an instance of the service with the mock repository
    userService = new SimplifiedUserService(mockUserRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should register a new user', async () => {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const createdUser = { id: '1', email };
      
      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockUserRepository.create.mockResolvedValue(createdUser);

      // Act
      const result = await userService.register(email, password);

      // Assert
      expect(result).toEqual(createdUser);
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(email);
      expect(mockUserRepository.create).toHaveBeenCalledWith({
        email,
        password: 'hashed_password123',
      });
    });

    it('should throw an error if user already exists', async () => {
      // Arrange
      const email = 'existing@example.com';
      const password = 'password123';
      const existingUser = { id: '1', email };
      
      mockUserRepository.findByEmail.mockResolvedValue(existingUser);

      // Act & Assert
      await expect(userService.register(email, password)).rejects.toThrow(
        'User with this email already exists'
      );
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(email);
      expect(mockUserRepository.create).not.toHaveBeenCalled();
    });
  });
});
