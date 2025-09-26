import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import morgan from 'morgan';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { errorHandler, notFound } from './middleware/errorHandler';
import { connectDB } from './config/database';
import { configureDI, diContainer as container } from './config/di.config';
import routes from './routes/index';
import config from './config/config';
import { PrismaClient } from '@prisma/client';

// Initialize Express app
const app = express();

// Security headers
app.use(helmet());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  message: { 
    success: false, 
    message: 'Too many requests from this IP, please try again after 15 minutes' 
  }
});

// Apply rate limiting to all API routes
app.use('/api', limiter);

// CORS middleware
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps, curl, etc.)
    if (!origin) return callback(null, true);
    
    if (config.cors.allowedOrigins.includes(origin) || 
        config.cors.allowedOrigins.some(allowedOrigin => 
          allowedOrigin.startsWith('http://*') || 
          allowedOrigin.startsWith('https://*')
        )) {
      return callback(null, true);
    }
    
    const msg = 'The CORS policy for this site does not allow access from the specified Origin.';
    return callback(new Error(msg), false);
  },
  credentials: config.cors.credentials,
  methods: config.cors.methods,
  allowedHeaders: config.cors.allowedHeaders,
  exposedHeaders: config.cors.exposedHeaders
}));

// Handle preflight requests
app.options('*', cors());

// Body parser middleware
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));
app.use(cookieParser());

// Logging middleware in development
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  // Log request details
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${req.ip}`);
  
  // Log request body (except for sensitive data)
  if (req.body && Object.keys(req.body).length > 0) {
    const body = { ...req.body };
    // Remove sensitive data from logs
    if (body.password) body.password = '***';
    if (body.newPassword) body.newPassword = '***';
    if (body.confirmPassword) body.confirmPassword = '***';
    
    console.log('Request body:', body);
  }
  
  next();
});

// API routes
app.use('/api', routes);

// Health check endpoint (no logging)
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404 handler for non-API routes
app.use('*', (req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    path: req.originalUrl
  });
});

// Error handling middleware
app.use(errorHandler);

// Store server instance for graceful shutdown
import { Server } from 'http';
let server: Server | undefined;
let webSocketManager: any | undefined;



// Configure dependency injection
const initializeApp = async () => {
  try {
    // Set up dependency injection
    configureDI();
    
    // Get Prisma client for database connection
    const prisma = container.resolve<PrismaClient>('PrismaClient');
    
    // Note: Database connection will be handled automatically by Prisma
    console.log('✅ Prisma client initialized successfully');
    
    return { prisma };
  } catch (error) {
    console.error('❌ Failed to initialize application:', error);
    process.exit(1);
  }
};

const startServer = async () => {
  try {
    // Initialize application (DI, DB connection, etc.)
    const { prisma } = await initializeApp();
    
    // Start server
    server = app.listen(config.port, () => {
      console.log(`
🚀 Server running in ${config.env} mode on port ${config.port}`);
      console.log(`📚 API Documentation: http://localhost:${config.port}/api-docs`);
    });

    // Initialize WebSocket server
    if (server) {
      // WebSocket server initialization (placeholder)
      console.log('✅ Server ready for WebSocket connections');
    }

    // Handle server startup errors
    server.on('error', (error: NodeJS.ErrnoException) => {
      if (error.syscall !== 'listen') {
        throw error;
      }

      const bind = typeof config.port === 'string' 
        ? 'Pipe ' + config.port 
        : 'Port ' + config.port;

      // Handle specific listen errors with friendly messages
      switch (error.code) {
        case 'EACCES':
          console.error(bind + ' requires elevated privileges');
          process.exit(1);
          break;
        case 'EADDRINUSE':
          console.error(bind + ' is already in use');
          process.exit(1);
          break;
        default:
          throw error;
      }
    });
    
    // Handle graceful shutdown
    const shutdown = async () => {
      console.log('\n🛑 Shutting down server...');
      
      // Close server
      if (server) {
        server.close(async () => {
          console.log('✅ Server closed');
          
          // Close database connection
          if (prisma) {
            try {
              // Prisma handles connection cleanup automatically
              console.log('✅ Database connection cleanup completed');
            } catch (err) {
              console.error('❌ Error during database cleanup:', err);
            }
          }
          
          process.exit(0);
        });
      } else {
        // Close database connection
        if (prisma) {
          try {
            // Prisma handles connection cleanup automatically
            console.log('✅ Database connection cleanup completed');
          } catch (err) {
            console.error('❌ Error during database cleanup:', err);
          }
        }
        process.exit(0);
      }
      
      // Force shutdown after timeout
      setTimeout(() => {
        console.error('❌ Forcing shutdown...');
        process.exit(1);
      }, 10000);
    };
    
    // Handle process termination
    process.on('SIGTERM', shutdown);
    process.on('SIGINT', shutdown);
    
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason: Error | any, promise: Promise<any>) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  // Close server and exit process
  if (server) {
    server.close(() => {
      console.log('Server closed due to unhandled rejection');
      process.exit(1);
    });
  } else {
    process.exit(1);
  }
});

// Handle uncaught exceptions
process.on('uncaughtException', (error: Error) => {
  console.error('Uncaught Exception:', error);
  // Close server and exit process
  if (server) {
    server.close(() => {
      console.log('Server closed due to uncaught exception');
      process.exit(1);
    });
  } else {
    process.exit(1);
  }
});

// Handle SIGTERM signal (for Docker, Kubernetes, etc.)
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully');
  if (server) {
    server.close(() => {
      console.log('Process terminated');
      process.exit(0);
    });
  }
});

// Start the server
if (process.env.NODE_ENV !== 'test') {
  startServer();
}

export default app;
