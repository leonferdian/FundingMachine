import { PrismaClient, SubscriptionPlan, Prisma } from '@prisma/client';
import { inject, injectable } from 'tsyringe';
import { BaseRepository } from './base.repository';

@injectable()
export class SubscriptionPlanRepository extends BaseRepository<SubscriptionPlan> {
  constructor(@inject('PrismaClient') prisma: PrismaClient) {
    super(prisma);
  }

  get model() {
    return this.prisma.subscriptionPlan;
  }

  async getActivePlans(): Promise<SubscriptionPlan[]> {
    return this.findMany({ isActive: true });
  }

  async getPlanFeatures(planId: string): Promise<string[]> {
    const plan = await this.findUnique({ id: planId });
    return plan?.features as string[] || [];
  }

  async updatePlanFeatures(planId: string, features: string[]): Promise<SubscriptionPlan> {
    return this.update(
      { id: planId },
      { features: features as Prisma.JsonArray }
    );
  }
}
