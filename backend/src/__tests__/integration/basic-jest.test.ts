/// <reference types="jest" />

import { describe, test, expect } from '@jest/globals';

describe('Basic Jest Functionality Test', () => {
  test('should run basic Jest test', () => {
    expect(1 + 1).toBe(2);
    expect('hello').toBe('hello');
    expect(true).toBeTruthy();
  });

  test('should have Jest globals working', () => {
    expect(typeof describe).toBe('function');
    expect(typeof test).toBe('function');
    expect(typeof expect).toBe('function');
  });
});
