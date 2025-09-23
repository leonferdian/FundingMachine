const { describe, it } = require('node:test');

describe('Basic Backend Tests', () => {
  it('should perform basic arithmetic', () => {
    const result = 2 + 2;
    if (result !== 4) {
      throw new Error('Expected 2 + 2 to equal 4');
    }
  });

  it('should handle string operations', () => {
    const result = 'hello' + ' ' + 'world';
    if (result !== 'hello world') {
      throw new Error('Expected string concatenation to work');
    }
  });
});
