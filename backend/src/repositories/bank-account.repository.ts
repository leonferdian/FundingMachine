import { PrismaClient, BankAccount, Prisma } from '@prisma/client';
import { inject, injectable } from 'tsyringe';
import { BaseRepository } from './base.repository';

@injectable()
export class BankAccountRepository extends BaseRepository<BankAccount> {
  constructor(@inject('PrismaClient') prisma: PrismaClient) {
    super(prisma);
  }

  get model() {
    return this.prisma.bankAccount;
  }

  async getUserBankAccounts(userId: string): Promise<BankAccount[]> {
    return this.findMany({ userId });
  }

  async setDefaultAccount(userId: string, accountId: string): Promise<void> {
    // First, set all accounts to non-default
    await this.model.updateMany({
      where: { userId, isDefault: true },
      data: { isDefault: false },
    });

    // Then set the selected account as default
    await this.update({ id: accountId, userId }, { isDefault: true });
  }

  async findByAccountNumber(accountNumber: string, bankCode: string): Promise<BankAccount | null> {
    return this.findUnique({ 
      bankCode_accountNumber: {
        bankCode,
        accountNumber,
      } 
    });
  }
}
