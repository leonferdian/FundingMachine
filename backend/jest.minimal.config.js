module.exports = {
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.test.ts'],
  transform: {
    '^.+\\.ts$': ['ts-jest', {
      tsconfig: '<rootDir>/jest-tsconfig.json'
    }]
  },
  moduleFileExtensions: ['ts', 'js'],
  verbose: true,
  testTimeout: 5000,
};
