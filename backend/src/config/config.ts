import dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env file
dotenv.config();

// Environment types
type Environment = 'development' | 'production' | 'test';

// Get current environment
const env = (process.env.NODE_ENV || 'development') as Environment;

// Common configuration
const common = {
  // Server configuration
  env,
  appUrl: process.env.APP_URL || 'http://localhost:5000',
  port: process.env.PORT ? parseInt(process.env.PORT, 10) : 5000,
  
  // JWT Authentication
  jwt: {
    secret: process.env.JWT_SECRET || 'your_jwt_secret_key_here',
    expiresIn: process.env.JWT_EXPIRE || '30d',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRE || '90d',
    cookieExpire: process.env.JWT_COOKIE_EXPIRE ? 
      parseInt(process.env.JWT_COOKIE_EXPIRE, 10) : 30
  },

  // CORS Configuration
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    allowedOrigins: [
      // Web development
      'http://localhost:3000',
      'http://127.0.0.1:3000',
      
      // Android emulator
      'http://10.0.2.2:3000',  // Android emulator to localhost
      'http://10.0.2.2:5000',  // Android emulator to API
      'http://localhost:19006', // Expo web
      
      // Production frontend URL if set
      ...(process.env.FRONTEND_URL ? [process.env.FRONTEND_URL] : [])
    ],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    exposedHeaders: ['Content-Range', 'X-Content-Range']
  },

  // Rate limiting
  rateLimit: {
    windowMs: process.env.RATE_LIMIT_WINDOW_MS ? 
      parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10) : 15 * 60 * 1000, // 15 minutes
    max: process.env.RATE_LIMIT_MAX ? 
      parseInt(process.env.RATE_LIMIT_MAX, 10) : 100
  },

  // Security
  security: {
    helmet: process.env.HELMET_ENABLED !== 'false',
    rateLimit: process.env.RATE_LIMIT_ENABLED !== 'false'
  },

  // Logging
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    toFile: process.env.LOG_TO_FILE === 'true'
  },

  // Firebase (for authentication)
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || '',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
    privateKey: (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n')
  },

  // AI Configuration
  openai: {
    apiKey: process.env.OPENAI_API_KEY || '',
    model: process.env.OPENAI_MODEL || 'gpt-4-turbo',
    temperature: process.env.OPENAI_TEMPERATURE ? 
      parseFloat(process.env.OPENAI_TEMPERATURE) : 0.7
  },

  // AI Service
  ai: {
    maxTokens: process.env.AI_MAX_TOKENS ? 
      parseInt(process.env.AI_MAX_TOKENS, 10) : 1000,
    maxRetries: process.env.AI_MAX_RETRIES ? 
      parseInt(process.env.AI_MAX_RETRIES, 10) : 3,
    timeout: process.env.AI_TIMEOUT_MS ? 
      parseInt(process.env.AI_TIMEOUT_MS, 10) : 30000
  },

  // Payment Gateways
  xendit: {
    secretKey: process.env.XENDIT_SECRET_KEY || '',
    callbackToken: process.env.XENDIT_CALLBACK_TOKEN || ''
  },

  midtrans: {
    serverKey: process.env.MIDTRANS_SERVER_KEY || '',
    clientKey: process.env.MIDTRANS_CLIENT_KEY || '',
    isProduction: process.env.MIDTRANS_IS_PRODUCTION === 'true' || false
  },

  // Email Service
  email: {
    host: process.env.SMTP_HOST || 'smtp.example.com',
    port: process.env.SMTP_PORT ? parseInt(process.env.SMTP_PORT, 10) : 587,
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER || '',
      pass: process.env.SMTP_PASS || ''
    },
    from: process.env.SMTP_FROM || 'no-reply@fundingmachine.com'
  }
};

// Environment specific configuration
const environmentConfigs = {
  development: {
    db: {
      url: process.env.DATABASE_URL || 'file:./dev.db',
      logging: ['error', 'warn']
    },
    logging: true,
    debug: true
  },
  production: {
    db: {
      url: process.env.DATABASE_URL || 'file:./prod.db'
    },
    logging: false
  },
  test: {
    db: {
      url: process.env.TEST_DATABASE_URL || 'file:./test.db'
    },
    logging: false
  }
};

// Merge common and environment specific config
const config = {
  ...common,
  ...(environmentConfigs[env] || environmentConfigs.development),
  // Add any other global config here
};

export default config;
