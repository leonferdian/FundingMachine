// Minimal test to verify Jest is working correctly with TypeScript
describe('Minimal Test', () => {
  it('should pass a simple assertion', () => {
    expect(1 + 1).toBe(2);
  });

  it('should handle async code', async () => {
    const result = await Promise.resolve(42);
    expect(result).toBe(42);
  });
});
