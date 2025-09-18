import { PrismaClient, Transaction, TransactionType, TransactionStatus, Prisma } from '@prisma/client';
import { inject, injectable } from 'tsyringe';
import { BaseRepository } from './base.repository';

@injectable()
export class TransactionRepository extends BaseRepository<Transaction> {
  constructor(@inject('PrismaClient') prisma: PrismaClient) {
    super(prisma);
  }

  get model() {
    return this.prisma.transaction;
  }

  async getUserTransactions(
    userId: string,
    type?: TransactionType,
    status?: TransactionStatus,
    skip = 0,
    take = 10
  ): Promise<{ transactions: Transaction[]; total: number }> {
    const where: Prisma.TransactionWhereInput = { userId };
    if (type) where.type = type;
    if (status) where.status = status;

    const [transactions, total] = await Promise.all([
      this.model.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: {
          funding: {
            include: {
              platform: true,
            },
          },
        },
      }),
      this.count(where),
    ]);

    return { transactions, total };
  }

  async getTotalAmount(
    userId: string,
    type?: TransactionType,
    status?: TransactionStatus
  ): Promise<number> {
    const where: Prisma.TransactionWhereInput = { userId };
    if (type) where.type = type;
    if (status) where.status = status;

    const result = await this.model.aggregate({
      where,
      _sum: {
        amount: true,
      },
    });

    return result._sum.amount || 0;
  }
}
