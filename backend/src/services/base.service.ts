import { injectable } from 'tsyringe';
import { BaseRepository } from '../repositories/base.repository';

export interface IBaseService<T, CreateDto, UpdateDto> {
  create(data: CreateDto): Promise<T>;
  findById(id: string): Promise<T | null>;
  findAll(where?: any, include?: any, skip?: number, take?: number): Promise<T[]>;
  update(id: string, data: UpdateDto): Promise<T>;
  delete(id: string): Promise<T>;
  count(where?: any): Promise<number>;
}

@injectable()
export abstract class BaseService<T, CreateDto, UpdateDto> implements IBaseService<T, CreateDto, UpdateDto> {
  constructor(protected repository: BaseRepository<T>) {}

  async create(data: CreateDto): Promise<T> {
    return this.repository.create(data);
  }

  async findById(id: string): Promise<T | null> {
    return this.repository.findUnique({ id });
  }

  async findAll(where: any = {}, include?: any, skip?: number, take?: number): Promise<T[]> {
    return this.repository.findMany(where, include, skip, take);
  }

  async update(id: string, data: UpdateDto): Promise<T> {
    return this.repository.update({ id }, data);
  }

  async delete(id: string): Promise<T> {
    return this.repository.delete({ id });
  }

  async count(where: any = {}): Promise<number> {
    return this.repository.count(where);
  }
}
