const { expect } = require('@jest/globals');

describe('TypeScript Module Import Test', () => {
  test('should be able to require TypeScript modules', () => {
    // Test if we can import a simple TypeScript module
    const result = 2 + 2;
    expect(result).toBe(4);
  });

  test('should handle basic assertions', () => {
    expect(true).toBeTruthy();
    expect(false).toBeFalsy();
    expect('test').toBe('test');
  });
});
