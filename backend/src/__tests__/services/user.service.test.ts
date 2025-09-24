/// <reference types="jest" />

import { describe, it, expect, jest } from '@jest/globals';

// Simple test to verify Jest is working with our setup
describe('UserService Basic Test', () => {
  it('should run a basic test', () => {
    expect(1 + 1).toBe(2);
  });
});

// Mock config
jest.mock('../../config/config', () => ({
  jwt: {
    secret: 'test-secret',
    expiresIn: '1h',
  },
}));
