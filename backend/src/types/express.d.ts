import { User, BankAccount, Funding, Transaction, Subscription } from '@prisma/client';

declare global {
  namespace Express {
    interface Request {
      user?: User & {
        bankAccounts?: BankAccount[];
        fundings?: Funding[];
        transactions?: Transaction[];
        subscriptions?: Subscription[];
      };
      // Add any other custom request properties here
    }

    interface Response {
      success: (data?: any, message?: string) => void;
      error: (message: string, statusCode?: number, errors?: any) => void;
      validationError: (errors: any) => void;
      notFound: (message?: string) => void;
      unauthorized: (message?: string) => void;
      forbidden: (message?: string) => void;
    }
  }
}

// Extend the Express Request type to include our custom properties
declare module 'express-serve-static-core' {
  interface Request {
    startTime?: number;
    requestId?: string;
    user?: any; // This should match your user type
  }
}
