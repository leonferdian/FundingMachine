import { inject, injectable } from 'tsyringe';
import { User, Prisma } from '@prisma/client';
import { UserRepository } from '../repositories/user.repository';
import { BaseService } from './base.service';
import { compare, hash } from 'bcryptjs';
import { sign } from 'jsonwebtoken';
import config from '../config/config';

export interface IUserService {
  register(userData: Prisma.UserCreateInput): Promise<User>;
  login(email: string, password: string): Promise<{ user: Omit<User, 'password'>; token: string }>;
  verifyEmail(token: string): Promise<boolean>;
  requestPasswordReset(email: string): Promise<void>;
  resetPassword(token: string, newPassword: string): Promise<void>;
  updateProfile(userId: string, userData: Partial<User>): Promise<User>;
  changePassword(userId: string, currentPassword: string, newPassword: string): Promise<void>;
}

@injectable()
export class UserService extends BaseService<User, Prisma.UserCreateInput, Partial<User>> implements IUserService {
  constructor(
    @inject('UserRepository') private userRepository: UserRepository
  ) {
    super(userRepository);
  }

  async register(userData: Prisma.UserCreateInput): Promise<User> {
    // Check if user already exists
    const existingUser = await this.userRepository.findByEmail(userData.email);
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // Hash password
    const hashedPassword = await hash(userData.password, 10);
    
    // Create user
    return this.userRepository.create({
      ...userData,
      password: hashedPassword,
    });
  }

  async login(email: string, password: string) {
    // Find user by email
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new Error('Invalid credentials');
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
    // In a real app, verify the token and mark the user as verified
    // This is a simplified version
    return true;
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

  async updateProfile(userId: string, userData: Partial<User>): Promise<User> {
    // Don't allow updating sensitive fields this way
    const { password, email, ...safeData } = userData;
    return this.userRepository.update({ id: userId }, safeData);
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<void> {
    const user = await this.userRepository.findUnique({ id: userId });
    if (!user) {
      throw new Error('User not found');
    }

    const isPasswordValid = await compare(currentPassword, user.password);
    if (!isPasswordValid) {
      throw new Error('Current password is incorrect');
    }

    const hashedPassword = await hash(newPassword, 10);
    await this.userRepository.updatePassword(userId, hashedPassword);
  }
}
