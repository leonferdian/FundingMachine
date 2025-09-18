import { User, BankAccount, Funding } from '@prisma/client';

declare global {
  namespace Express {
    // Extend the Express Request type to include our custom properties
    interface Request {
      user?: User & {
        bankAccounts?: BankAccount[];
        fundings?: Funding[];
        // Add other related models as needed
      };
      startTime?: number;
      requestId?: string;
    }
  }
}

export type AuthUser = {
  id: string;
  email: string;
  role: string;
  // Add other user properties as needed
};
