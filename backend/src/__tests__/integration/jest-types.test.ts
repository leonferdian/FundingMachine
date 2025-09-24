/// <reference types="jest" />

import { describe, test, expect, beforeAll, afterAll } from '@jest/globals';
import request from 'supertest';
import app from '../../app';

describe('Simple Jest Types Test', () => {
  test('should have Jest globals available', () => {
    expect(describe).toBeDefined();
    expect(test).toBeDefined();
    expect(expect).toBeDefined();
    expect(beforeAll).toBeDefined();
    expect(afterAll).toBeDefined();
  });

  test('should make basic HTTP request', async () => {
    const response = await request(app)
      .get('/api/health')
      .expect(200);

    expect(response.body.success).toBe(true);
  });
});
