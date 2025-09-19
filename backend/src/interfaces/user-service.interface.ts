import { User } from '@prisma/client';

export interface IUserRepository {
  findByEmail(email: string): Promise<User | null>;
  create(data: Omit<User, 'id' | 'createdAt' | 'updatedAt'>): Promise<User>;
  findById(id: string): Promise<User | null>;
  update(id: string, data: Partial<Omit<User, 'id' | 'createdAt' | 'updatedAt'>>): Promise<User>;
  delete(id: string): Promise<User>;
  updatePassword(id: string, newPassword: string): Promise<void>;
  markAsVerified(id: string): Promise<void>;
  exists(where: any): Promise<boolean>;
}

export interface IAuthService {
  hashPassword(password: string): Promise<string>;
  comparePasswords(plainPassword: string, hashedPassword: string): Promise<boolean>;
  generateToken(payload: { userId: string; email: string }): string;
  verifyToken(token: string): { userId: string; email: string };
}

export interface IUserService {
  register(userData: Omit<User, 'id' | 'createdAt' | 'updatedAt' | 'isVerified'>): Promise<User>;
  login(email: string, password: string): Promise<{ user: Omit<User, 'password'>; token: string }>;
  verifyEmail(token: string): Promise<boolean>;
  requestPasswordReset(email: string): Promise<void>;
  resetPassword(token: string, newPassword: string): Promise<void>;
  updateProfile(userId: string, userData: Partial<Omit<User, 'id' | 'password' | 'isVerified'>>): Promise<User>;
  changePassword(userId: string, currentPassword: string, newPassword: string): Promise<void>;
}
