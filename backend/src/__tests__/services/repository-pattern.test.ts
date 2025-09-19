// Test a simple repository and service pattern
interface User {
  id: string;
  name: string;
  email: string;
}

interface UserRepository {
  findById(id: string): Promise<User | null>;
  create(user: Omit<User, 'id'>): Promise<User>;
}

class UserService {
  constructor(private readonly userRepository: UserRepository) {}

  async getUser(id: string): Promise<User | null> {
    return this.userRepository.findById(id);
  }

  async createUser(userData: Omit<User, 'id'>): Promise<User> {
    // In a real app, we might validate the data here
    return this.userRepository.create(userData);
  }
}

describe('UserService with Repository', () => {
  let userService: UserService;
  let mockUserRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    // Create a mock repository
    mockUserRepository = {
      findById: jest.fn(),
      create: jest.fn(),
    };

    // Create the service with the mock repository
    userService = new UserService(mockUserRepository);
  });

  describe('getUser', () => {
    it('should return a user when found', async () => {
      // Arrange
      const mockUser: User = {
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
      };
      mockUserRepository.findById.mockResolvedValue(mockUser);

      // Act
      const result = await userService.getUser('1');

      // Assert
      expect(result).toEqual(mockUser);
      expect(mockUserRepository.findById).toHaveBeenCalledWith('1');
    });

    it('should return null when user is not found', async () => {
      // Arrange
      mockUserRepository.findById.mockResolvedValue(null);

      // Act
      const result = await userService.getUser('nonexistent');

      // Assert
      expect(result).toBeNull();
    });
  });

  describe('createUser', () => {
    it('should create and return a new user', async () => {
      // Arrange
      const userData = {
        name: 'New User',
        email: 'new@example.com',
      };
      const createdUser: User = {
        id: '2',
        ...userData,
      };
      mockUserRepository.create.mockResolvedValue(createdUser);

      // Act
      const result = await userService.createUser(userData);

      // Assert
      expect(result).toEqual(createdUser);
      expect(mockUserRepository.create).toHaveBeenCalledWith(userData);
    });
  });
});
