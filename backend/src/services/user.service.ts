import { inject, injectable } from 'tsyringe';
import { User } from '@prisma/client';
import { IUserService, IUserRepository, IAuthService } from '../interfaces/user-service.interface';
import { AppError } from '../utils/error-handler';

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

  async register(userData: Omit<User, 'id' | 'createdAt' | 'updatedAt' | 'isVerified'>): Promise<User> {
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

  async login(email: string, password: string) {
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
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
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
      { userId: user.id, email: user.email },
      { expiresIn: '1h' }
    );
    
    // Here you would send an email with the reset token
    console.log(`Password reset token for ${email}: ${resetToken}`);
  }

  async resetPassword(token: string, newPassword: string): Promise<void> {
    try {
      const { userId } = this.authService.verifyToken(token);
      const hashedPassword = await this.authService.hashPassword(newPassword);
      await this.userRepository.updatePassword(userId, hashedPassword);
    } catch (error) {
      throw new UserServiceError('Invalid or expired reset token', 400);
    }
  }

  async updateProfile(
    userId: string,
    userData: Partial<Omit<User, 'id' | 'password' | 'isVerified'>>
  ): Promise<User> {
    // In a real app, you might want to validate the input data here
    return this.userRepository.update(userId, userData);
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<void> {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new UserServiceError('User not found', 404);
    }

    const isPasswordValid = await this.authService.comparePasswords(currentPassword, user.password);
    if (!isPasswordValid) {
      throw new UserServiceError('Current password is incorrect', 400);
    }

    const hashedPassword = await this.authService.hashPassword(newPassword);
    await this.userRepository.updatePassword(userId, hashedPassword);
  }

    // Verify password
    const isPasswordValid = await compare(password, user.password);
    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    // Generate JWT token
    const token = sign(
      { userId: user.id, email: user.email },
      config.jwt.secret,
      { expiresIn: config.jwt.expiresIn }
    );

    // Remove password from user object
    const { password: _, ...userWithoutPassword } = user;

    return { user: userWithoutPassword, token };
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
    // In a real app, generate a reset token and send an email
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      // Don't reveal that the user doesn't exist
      return;
    }
    
    // Generate reset token and save it to the user
    const resetToken = 'generated-reset-token'; // In a real app, generate a secure token
    // await this.userRepository.update({ id: user.id }, { resetToken });
    
    // Send email with reset link
    // await sendPasswordResetEmail(user.email, resetToken);
  }

  async resetPassword(token: string, newPassword: string): Promise<void> {
    // In a real app, verify the token and update the password
    // This is a simplified version
    const hashedPassword = await hash(newPassword, 10);
    // await this.userRepository.update(
    //   { resetToken: token },
    //   { password: hashedPassword, resetToken: null }
    // );
  }

  async updateProfile(
    userId: string,
    userData: Partial<Omit<User, 'id' | 'password' | 'isVerified'>>
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
