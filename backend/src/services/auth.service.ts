import { sign, verify } from 'jsonwebtoken';
import { compare, hash } from 'bcryptjs';
import config from '../config/config';
import { injectable } from 'tsyringe';
import { IAuthService } from '../interfaces/user-service.interface';

@injectable()
export class AuthService implements IAuthService {
  async hashPassword(password: string): Promise<string> {
    return hash(password, 10);
  }

  async comparePasswords(plainPassword: string, hashedPassword: string): Promise<boolean> {
    return compare(plainPassword, hashedPassword);
  }

  generateToken(payload: { userId: string; email: string }): string {
    return sign(payload, config.jwt.secret, { expiresIn: config.jwt.expiresIn });
  }

  verifyToken(token: string): { userId: string; email: string } {
    return verify(token, config.jwt.secret) as { userId: string; email: string };
  }
}
