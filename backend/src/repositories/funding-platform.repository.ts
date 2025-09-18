import { PrismaClient, FundingPlatform, PlatformType, Prisma } from '@prisma/client';
import { inject, injectable } from 'tsyringe';
import { BaseRepository } from './base.repository';

@injectable()
export class FundingPlatformRepository extends BaseRepository<FundingPlatform> {
  constructor(@inject('PrismaClient') prisma: PrismaClient) {
    super(prisma);
  }

  get model() {
    return this.prisma.fundingPlatform;
  }

  async getActivePlatforms(type?: PlatformType): Promise<FundingPlatform[]> {
    const where: Prisma.FundingPlatformWhereInput = { isActive: true };
    if (type) where.type = type;
    
    return this.findMany(where);
  }

  async getPlatformStats(platformId: string) {
    const [totalFundings, activeFundings, totalAmount] = await Promise.all([
      this.prisma.funding.count({ where: { platformId } }),
      this.prisma.funding.count({ where: { platformId, status: 'ACTIVE' } }),
      this.prisma.funding.aggregate({
        where: { platformId },
        _sum: { amount: true },
      }),
    ]);

    return {
      totalFundings,
      activeFundings,
      totalAmount: totalAmount._sum.amount || 0,
    };
  }
}
