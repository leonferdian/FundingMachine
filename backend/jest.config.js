/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  // Basic configuration
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  
  // Transform settings
  transform: {
    '^.+\\.tsx?$': ['ts-jest', {
      tsconfig: 'tsconfig.test.json'
    }],
  },
  
  // Module name mapper
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@test/(.*)$': '<rootDir>/src/__tests__/$1',
  },
  
  // Setup files
  setupFilesAfterEnv: ['<rootDir>/src/__tests__/jest.setup.ts'],
  
  // Coverage settings
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/app.ts',
    '!src/server.ts',
    '!src/config/**',
    '!src/**/index.ts',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov'],
  
  // Extensions
  moduleFileExtensions: ['ts', 'js', 'json', 'node'],
  
  // Ignore patterns
  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/coverage/',
  ],
  
  // Other settings
  verbose: true,
  testTimeout: 10000,
  clearMocks: true,
  resetMocks: true,
  resetModules: true,
  detectOpenHandles: true,
  forceExit: true,
};
