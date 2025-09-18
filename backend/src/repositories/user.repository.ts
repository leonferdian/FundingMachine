import { PrismaClient, User, Prisma } from '@prisma/client';
import { inject, injectable } from 'tsyringe';
import { BaseRepository } from './base.repository';

@injectable()
export class UserRepository extends BaseRepository<User> {
  constructor(@inject('PrismaClient') prisma: PrismaClient) {
    super(prisma);
  }

  get model() {
    return this.prisma.user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.findUnique({ email });
  }

  async findByPhone(phone: string): Promise<User | null> {
    return this.findUnique({ phone });
  }

  async updatePassword(userId: string, hashedPassword: string): Promise<User> {
    return this.update({ id: userId }, { password: hashedPassword });
  }

  async markAsVerified(userId: string): Promise<User> {
    return this.update({ id: userId }, { isVerified: true });
  }
}
