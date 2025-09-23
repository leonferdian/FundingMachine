declare module '@prisma/client' {
  namespace Prisma {
    interface PrismaClient {
      paymentMethod: {
        findMany(args?: any): Promise<any[]>;
        findFirst(args?: any): Promise<any | null>;
        findUnique(args?: any): Promise<any | null>;
        create(args: any): Promise<any>;
        update(args: any): Promise<any>;
        updateMany(args: any): Promise<any>;
        delete(args: any): Promise<any>;
        deleteMany(args: any): Promise<any>;
        upsert(args: any): Promise<any>;
        count(args?: any): Promise<number>;
      };
    }
  }
}
