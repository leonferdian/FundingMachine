import { PrismaClient, Prisma } from '@prisma/client';

export abstract class BaseRepository<T> {
  constructor(protected prisma: PrismaClient) {}

  abstract get model(): any;

  async create(data: any): Promise<T> {
    return this.model.create({ data });
  }

  async findUnique(where: any, include?: any): Promise<T | null> {
    return this.model.findUnique({ where, include });
  }

  async findMany(where?: any, include?: any, skip?: number, take?: number): Promise<T[]> {
    return this.model.findMany({ where, include, skip, take });
  }

  async update(where: any, data: any): Promise<T> {
    return this.model.update({ where, data });
  }

  async delete(where: any): Promise<T> {
    return this.model.delete({ where });
  }

  async count(where?: any): Promise<number> {
    return this.model.count({ where });
  }

  async exists(where: any): Promise<boolean> {
    const count = await this.count(where);
    return count > 0;
  }
}
