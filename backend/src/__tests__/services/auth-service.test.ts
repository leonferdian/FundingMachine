/// <reference types="jest" />

import { describe, it, expect, jest, beforeEach } from '@jest/globals';
import { AuthService } from '../../services/auth.service';
import config from '../../config/config';

// Mock the config
jest.mock('../../config/config', () => ({
  jwt: {
    secret: 'test-jwt-secret-key',
    expiresIn: '24h',
  },
}));

// Mock bcryptjs
jest.mock('bcryptjs', () => ({
  hash: jest.fn(),
  compare: jest.fn(),
}));

// Mock jsonwebtoken
jest.mock('jsonwebtoken', () => ({
  sign: jest.fn(),
  verify: jest.fn(),
}));

describe('AuthService', () => {
  let authService: AuthService;

  beforeEach(() => {
    authService = new AuthService();
    jest.clearAllMocks();
  });

  describe('hashPassword', () => {
    it('should hash password successfully', async () => {
      const password = 'testPassword123';
      const hashedPassword = 'hashedPassword123';
      const hashMock = jest.mocked(require('bcryptjs').hash);
      hashMock.mockResolvedValue(hashedPassword);

      const result = await authService.hashPassword(password);

      expect(hashMock).toHaveBeenCalledWith(password, 10);
      expect(result).toBe(hashedPassword);
    });

    it('should handle bcrypt errors', async () => {
      const password = 'testPassword123';
      const hashMock = jest.mocked(require('bcryptjs').hash);
      hashMock.mockRejectedValue(new Error('Hashing failed'));

      await expect(authService.hashPassword(password)).rejects.toThrow('Hashing failed');
    });

    it('should hash different passwords with different salts', async () => {
      const password = 'samePassword';
      const hashMock = jest.mocked(require('bcryptjs').hash);

      hashMock.mockResolvedValueOnce('hash1');
      hashMock.mockResolvedValueOnce('hash2');

      const result1 = await authService.hashPassword(password);
      const result2 = await authService.hashPassword(password);

      expect(result1).toBe('hash1');
      expect(result2).toBe('hash2');
      expect(hashMock).toHaveBeenCalledTimes(2);
    });
  });

  describe('comparePasswords', () => {
    it('should return true for matching passwords', async () => {
      const plainPassword = 'testPassword123';
      const hashedPassword = 'hashedPassword123';
      const compareMock = jest.mocked(require('bcryptjs').compare);
      compareMock.mockResolvedValue(true);

      const result = await authService.comparePasswords(plainPassword, hashedPassword);

      expect(compareMock).toHaveBeenCalledWith(plainPassword, hashedPassword);
      expect(result).toBe(true);
    });

    it('should return false for non-matching passwords', async () => {
      const plainPassword = 'wrongPassword';
      const hashedPassword = 'hashedPassword123';
      const compareMock = jest.mocked(require('bcryptjs').compare);
      compareMock.mockResolvedValue(false);

      const result = await authService.comparePasswords(plainPassword, hashedPassword);

      expect(compareMock).toHaveBeenCalledWith(plainPassword, hashedPassword);
      expect(result).toBe(false);
    });

    it('should handle bcrypt comparison errors', async () => {
      const plainPassword = 'testPassword';
      const hashedPassword = 'hashedPassword';
      const compareMock = jest.mocked(require('bcryptjs').compare);
      compareMock.mockRejectedValue(new Error('Comparison failed'));

      await expect(authService.comparePasswords(plainPassword, hashedPassword)).rejects.toThrow('Comparison failed');
    });
  });

  describe('generateToken', () => {
    it('should generate JWT token successfully', () => {
      const payload = { userId: 'user123', email: 'test@example.com' };
      const expectedToken = 'jwt.token.here';
      const signMock = jest.mocked(require('jsonwebtoken').sign);
      signMock.mockReturnValue(expectedToken);

      const result = authService.generateToken(payload);

      expect(signMock).toHaveBeenCalledWith(payload, config.jwt.secret, { expiresIn: config.jwt.expiresIn });
      expect(result).toBe(expectedToken);
    });

    it('should include correct payload in token', () => {
      const payload = { userId: 'user456', email: 'user@example.com' };
      const signMock = jest.mocked(require('jsonwebtoken').sign);
      signMock.mockReturnValue('token');

      authService.generateToken(payload);

      expect(signMock).toHaveBeenCalledWith(
        { userId: 'user456', email: 'user@example.com' },
        'test-jwt-secret-key',
        { expiresIn: '24h' }
      );
    });

    it('should handle different payload structures', () => {
      const payload = {
        userId: 'user789',
        email: 'admin@example.com',
        role: 'admin',
        permissions: ['read', 'write']
      };
      const signMock = jest.mocked(require('jsonwebtoken').sign);
      signMock.mockReturnValue('token');

      authService.generateToken(payload);

      expect(signMock).toHaveBeenCalledWith(payload, 'test-jwt-secret-key', { expiresIn: '24h' });
    });
  });

  describe('verifyToken', () => {
    it('should verify valid JWT token successfully', () => {
      const token = 'valid.jwt.token';
      const decodedPayload = { userId: 'user123', email: 'test@example.com' };
      const verifyMock = jest.mocked(require('jsonwebtoken').verify);
      verifyMock.mockReturnValue(decodedPayload);

      const result = authService.verifyToken(token);

      expect(verifyMock).toHaveBeenCalledWith(token, config.jwt.secret);
      expect(result).toEqual(decodedPayload);
    });

    it('should handle invalid tokens', () => {
      const invalidToken = 'invalid.jwt.token';
      const verifyMock = jest.mocked(require('jsonwebtoken').verify);
      verifyMock.mockImplementation(() => {
        throw new Error('invalid token');
      });

      expect(() => authService.verifyToken(invalidToken)).toThrow('invalid token');
    });

    it('should handle expired tokens', () => {
      const expiredToken = 'expired.jwt.token';
      const verifyMock = jest.mocked(require('jsonwebtoken').verify);
      verifyMock.mockImplementation(() => {
        throw new Error('jwt expired');
      });

      expect(() => authService.verifyToken(expiredToken)).toThrow('jwt expired');
    });

    it('should handle malformed tokens', () => {
      const malformedToken = 'malformed.token';
      const verifyMock = jest.mocked(require('jsonwebtoken').verify);
      verifyMock.mockImplementation(() => {
        throw new Error('jwt malformed');
      });

      expect(() => authService.verifyToken(malformedToken)).toThrow('jwt malformed');
    });

    it('should return correct payload structure', () => {
      const token = 'valid.token';
      const decodedPayload = {
        userId: 'user456',
        email: 'user@example.com',
        iat: 1234567890,
        exp: 1234654290
      };
      const verifyMock = jest.mocked(require('jsonwebtoken').verify);
      verifyMock.mockReturnValue(decodedPayload);

      const result = authService.verifyToken(token);

      expect(result).toEqual(decodedPayload);
      expect(result.userId).toBe('user456');
      expect(result.email).toBe('user@example.com');
    });
  });

  describe('Integration Tests', () => {
    it('should complete full authentication flow', async () => {
      const password = 'testPassword123';
      const signMock = jest.mocked(require('jsonwebtoken').sign);
      const hashMock = jest.mocked(require('bcryptjs').hash);
      const compareMock = jest.mocked(require('bcryptjs').compare);
      const verifyMock = jest.mocked(require('jsonwebtoken').verify);

      // Mock successful hashing
      const hashedPassword = 'hashedPassword';
      hashMock.mockResolvedValue(hashedPassword);

      // Mock successful comparison
      compareMock.mockResolvedValue(true);

      // Mock token generation
      const token = 'jwt.token.here';
      signMock.mockReturnValue(token);

      // Mock token verification
      const decodedPayload = { userId: 'user123', email: 'test@example.com' };
      verifyMock.mockReturnValue(decodedPayload);

      // Test full flow
      const hashed = await authService.hashPassword(password);
      expect(hashed).toBe(hashedPassword);

      const isMatch = await authService.comparePasswords(password, hashed);
      expect(isMatch).toBe(true);

      const generatedToken = authService.generateToken(decodedPayload);
      expect(generatedToken).toBe(token);

      const verified = authService.verifyToken(token);
      expect(verified).toEqual(decodedPayload);
    });

    it('should handle incorrect password comparison', async () => {
      const correctPassword = 'correctPassword';
      const wrongPassword = 'wrongPassword';
      const hashedPassword = 'hashedPassword';

      const hashMock = jest.mocked(require('bcryptjs').hash);
      const compareMock = jest.mocked(require('bcryptjs').compare);

      hashMock.mockResolvedValue(hashedPassword);
      compareMock.mockResolvedValue(false);

      const hashed = await authService.hashPassword(correctPassword);
      const isMatch = await authService.comparePasswords(wrongPassword, hashed);

      expect(isMatch).toBe(false);
    });
  });

  describe('Error Handling', () => {
    it('should handle bcrypt module not available', async () => {
      const hashMock = jest.mocked(require('bcryptjs').hash);
      hashMock.mockImplementation(() => {
        throw new Error('bcrypt not available');
      });

      await expect(authService.hashPassword('password')).rejects.toThrow('bcrypt not available');
    });

    it('should handle jsonwebtoken module not available', () => {
      const signMock = jest.mocked(require('jsonwebtoken').sign);
      signMock.mockImplementation(() => {
        throw new Error('jsonwebtoken not available');
      });

      expect(() => authService.generateToken({ userId: '123', email: 'test@test.com' })).toThrow('jsonwebtoken not available');
    });

    it('should handle config not available', () => {
      // This would be tested by mocking config to throw an error
      const originalConfig = config.jwt.secret;
      delete (config as any).jwt;

      expect(() => authService.generateToken({ userId: '123', email: 'test@test.com' })).toThrow();
    });
  });
});
