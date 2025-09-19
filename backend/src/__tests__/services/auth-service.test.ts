// A simple authentication service test that doesn't depend on the actual UserService
class AuthService {
  constructor(private readonly userRepository: any) {}

  async register(email: string, password: string) {
    const existingUser = await this.userRepository.findByEmail(email);
    if (existingUser) {
      throw new Error('User already exists');
    }
    
    const hashedPassword = await this.hashPassword(password);
    return this.userRepository.create({ email, password: hashedPassword });
  }

  private async hashPassword(password: string): Promise<string> {
    // In a real app, this would use bcrypt
    return `hashed_${password}`;
  }
}

describe('AuthService', () => {
  let authService: AuthService;
  let mockUserRepository: any;

  beforeEach(() => {
    mockUserRepository = {
      findByEmail: jest.fn(),
      create: jest.fn(),
    };
    
    authService = new AuthService(mockUserRepository);
  });

  describe('register', () => {
    it('should register a new user', async () => {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      
      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockUserRepository.create.mockResolvedValue({ id: '1', email, password: 'hashed_password123' });

      // Act
      const result = await authService.register(email, password);

      // Assert
      expect(result).toBeDefined();
      expect(result.id).toBe('1');
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
      
      mockUserRepository.findByEmail.mockResolvedValue({ id: '1', email });

      // Act & Assert
      await expect(authService.register(email, password)).rejects.toThrow('User already exists');
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(email);
      expect(mockUserRepository.create).not.toHaveBeenCalled();
    });
  });
});
