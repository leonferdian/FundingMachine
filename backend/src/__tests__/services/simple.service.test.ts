import 'reflect-metadata';
import 'jest';

describe('Simple Service Test', () => {
  it('should pass a simple test', () => {
    expect(1 + 1).toBe(2);
  });

  it('should handle async code', async () => {
    const result = await Promise.resolve(42);
    expect(result).toBe(42);
  });
});
