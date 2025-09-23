describe('Simple Math Test', () => {
  it('should add numbers correctly', () => {
    expect(2 + 2).toBe(4);
  });

  it('should handle basic assertions', () => {
    expect(true).toBeTruthy();
    expect(null).toBeFalsy();
    expect('hello').toBe('hello');
  });
});
