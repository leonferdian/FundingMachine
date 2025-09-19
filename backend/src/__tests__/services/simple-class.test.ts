// Test a simple class with a dependency
class Calculator {
  constructor(private readonly logger: { log: (message: string) => void }) {}

  add(a: number, b: number): number {
    const result = a + b;
    this.logger.log(`Adding ${a} + ${b} = ${result}`);
    return result;
  }
}

describe('Calculator', () => {
  it('should add two numbers and log the result', () => {
    // Arrange
    const mockLogger = {
      log: jest.fn()
    };
    const calculator = new Calculator(mockLogger);

    // Act
    const result = calculator.add(2, 3);

    // Assert
    expect(result).toBe(5);
    expect(mockLogger.log).toHaveBeenCalledWith('Adding 2 + 3 = 5');
  });
});
