// A simplified version of UserService for testing purposes
import { injectable } from 'tsyringe';

export interface ISimplifiedUserService {
  register(email: string, password: string): Promise<{ id: string; email: string }>;
}

@injectable()
export class SimplifiedUserService implements ISimplifiedUserService {
  constructor(private readonly userRepository: {
    findByEmail: (email: string) => Promise<any>;
    create: (data: any) => Promise<{ id: string; email: string }>;
  }) {}

  async register(email: string, password: string): Promise<{ id: string; email: string }> {
    // Check if user already exists
    const existingUser = await this.userRepository.findByEmail(email);
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // In a real app, we would hash the password here
    const hashedPassword = `hashed_${password}`;
    
    // Create user
    return this.userRepository.create({ email, password: hashedPassword });
  }
}
