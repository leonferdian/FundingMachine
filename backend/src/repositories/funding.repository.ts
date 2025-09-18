import { PrismaClient, Funding, FundingStatus, Prisma } from '@prisma/client';
import { inject, injectable } from 'tsyringe';
import { BaseRepository } from './base.repository';

@injectable()
export class FundingRepository extends BaseRepository<Funding> {
  constructor(@inject('PrismaClient') prisma: PrismaClient) {
    super(prisma);
  }

  get model() {
    return this.prisma.funding;
  }

  async getUserFundings(
    userId: string,
    status?: FundingStatus,
    skip = 0,
    take = 10
  ): Promise<{ fundings: Funding[]; total: number }> {
    const where: Prisma.FundingWhereInput = { userId };
    if (status) where.status = status;

    const [fundings, total] = await Promise.all([
      this.model.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: {
          platform: true,
          transactions: {
            orderBy: { createdAt: 'desc' },
            take: 5, // Last 5 transactions
          },
        },
      }),
      this.count(where),
    ]);

    return { fundings, total };
  }

  async getTotalInvested(userId: string): Promise<number> {
    const result = await this.model.aggregate({
      where: {
        userId,
        status: 'ACTIVE',
      },
      _sum: {
        amount: true,
      },
    });

    return result._sum.amount || 0;
  }
}
