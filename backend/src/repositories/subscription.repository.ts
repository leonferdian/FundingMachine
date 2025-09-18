import { PrismaClient, Subscription, SubscriptionStatus, Prisma } from '@prisma/client';
import { inject, injectable } from 'tsyringe';
import { BaseRepository } from './base.repository';

@injectable()
export class SubscriptionRepository extends BaseRepository<Subscription> {
  constructor(@inject('PrismaClient') prisma: PrismaClient) {
    super(prisma);
  }

  get model() {
    return this.prisma.subscription;
  }

  async getUserActiveSubscription(userId: string): Promise<Subscription | null> {
    return this.findUnique({
      userId,
      status: 'ACTIVE',
    });
  }

  async createSubscription(
    userId: string,
    planId: string,
    amount: number,
    startDate: Date,
    endDate: Date
  ): Promise<Subscription> {
    return this.create({
      user: { connect: { id: userId } },
      plan: { connect: { id: planId } },
      amount,
      startDate,
      endDate,
      status: 'ACTIVE',
      autoRenew: true,
    });
  }

  async cancelSubscription(subscriptionId: string): Promise<Subscription> {
    return this.update(
      { id: subscriptionId },
      { 
        status: 'CANCELLED',
        cancelledAt: new Date(),
        autoRenew: false,
      }
    );
  }

  async getExpiredSubscriptions(): Promise<Subscription[]> {
    const now = new Date();
    return this.findMany({
      status: 'ACTIVE',
      endDate: { lte: now },
    });
  }
}
