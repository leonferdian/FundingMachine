import { PrismaClient } from '@prisma/client';
import { container } from 'tsyringe';
import { UserRepository } from './user.repository';
import { TransactionRepository } from './transaction.repository';
import { FundingRepository } from './funding.repository';
import { BankAccountRepository } from './bank-account.repository';
import { FundingPlatformRepository } from './funding-platform.repository';
import { SubscriptionRepository } from './subscription.repository';
import { SubscriptionPlanRepository } from './subscription-plan.repository';

// Register repositories with dependency injection
export const registerRepositories = () => {
  const prisma = new PrismaClient();
  
  container.register('PrismaClient', { useValue: prisma });
  container.register('UserRepository', { useClass: UserRepository });
  container.register('TransactionRepository', { useClass: TransactionRepository });
  container.register('FundingRepository', { useClass: FundingRepository });
  container.register('BankAccountRepository', { useClass: BankAccountRepository });
  container.register('FundingPlatformRepository', { useClass: FundingPlatformRepository });
  container.register('SubscriptionRepository', { useClass: SubscriptionRepository });
  container.register('SubscriptionPlanRepository', { useClass: SubscriptionPlanRepository });

  return { prisma };
};

// Export repository types for injection
export * from './user.repository';
export * from './transaction.repository';
export * from './funding.repository';
export * from './bank-account.repository';
export * from './funding-platform.repository';
export * from './subscription.repository';
export * from './subscription-plan.repository';
