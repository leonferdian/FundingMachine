import { inject, injectable } from 'tsyringe';
import { User, Role } from '@prisma/client';
import { IUserService, IUserRepository, IAuthService } from '../interfaces/user-service.interface';
import { AppError } from '../utils/error-handler';

// Type definitions for better type safety
type UserWithoutPassword = Omit<User, 'password'>;
type LoginResponse = { user: UserWithoutPassword; token: string };
type RegisterUserData = Omit<User, 'id' | 'createdAt' | 'updatedAt' | 'isVerified'>;
type UpdateUserData = Partial<Omit<User, 'id' | 'password' | 'isVerified'>>;

export class UserServiceError extends AppError {
  constructor(message: string, statusCode = 400) {
    super(message, statusCode);
  }
}

@injectable()
export class UserService implements IUserService {
  constructor(
    @inject('UserRepository') private readonly userRepository: IUserRepository,
    @inject('AuthService') private readonly authService: IAuthService
  ) {}

  async register(userData: RegisterUserData): Promise<User> {
    // Check if user already exists
    const existingUser = await this.userRepository.findByEmail(userData.email);
    if (existingUser) {
      throw new UserServiceError('User with this email already exists');
    }

    // Hash password
    const hashedPassword = await this.authService.hashPassword(userData.password);
    
    // Create user
    return this.userRepository.create({
      ...userData,
      password: hashedPassword,
      isVerified: false, // Default to false, email verification required
    });
  }

  async login(email: string, password: string): Promise<LoginResponse> {
    // Find user by email
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new UserServiceError('Invalid credentials', 401);
    }

    // Verify password
    const isPasswordValid = await this.authService.comparePasswords(password, user.password);
    if (!isPasswordValid) {
      throw new UserServiceError('Invalid credentials', 401);
    }

    // Check if email is verified
    if (!user.isVerified) {
      throw new UserServiceError('Please verify your email address', 403);
    }

    // Generate JWT token
    const token = this.authService.generateToken({
      userId: user.id,
      email: user.email,
    });

    // Omit password from the returned user object
    const { password: _, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      token,
    };
  }

  async verifyEmail(token: string): Promise<boolean> {
    try {
      const { userId } = this.authService.verifyToken(token);
      await this.userRepository.markAsVerified(userId);
      return true;
    } catch (error) {
      throw new UserServiceError('Invalid or expired verification token', 400);
    }
  }

  async requestPasswordReset(email: string): Promise<void> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      // Don't reveal that the email doesn't exist
      return;
    }

    // In a real app, you would generate a reset token and send an email
    // For now, we'll just simulate this
    const resetToken = this.authService.generateToken(
      { userId: user.id, email: user.email }
    );
    
    // Here you would send an email with the reset token
    console.log(`Password reset token for ${email}: ${resetToken}`);
  }

  async resetPassword(token: string, newPassword: string): Promise<void> {
    try {
      // Verify the token
      const payload = this.authService.verifyToken(token);
      const userId = payload.userId;
      
      // Hash the new password
      const hashedPassword = await this.authService.hashPassword(newPassword);
      
      // Update the user's password
      await this.userRepository.updatePassword(userId, hashedPassword);
    } catch (error) {
      throw new UserServiceError('Invalid or expired reset token', 400);
    }
  }

  async updateProfile(
    userId: string,
    userData: UpdateUserData
  ): Promise<User> {
    // Don't allow updating sensitive fields this way
    const { email, ...safeData } = userData;
    return this.userRepository.update(userId, safeData);
  }

  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string
  ): Promise<void> {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new UserServiceError('User not found', 404);
    }

    const isPasswordValid = await this.authService.comparePasswords(
      currentPassword,
      user.password
    );
    
    if (!isPasswordValid) {
      throw new UserServiceError('Current password is incorrect', 400);
    }

    const hashedPassword = await this.authService.hashPassword(newPassword);
    await this.userRepository.updatePassword(userId, hashedPassword);
  }
}
