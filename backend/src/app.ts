import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import morgan from 'morgan';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { errorHandler, notFound } from './middleware/errorHandler';
import { connectDB } from './config/database';
import routes from './routes';
import config from './config/config';

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
let server: any;

// Connect to database and start server
const startServer = async () => {
  try {
    await connectDB();
    
    server = app.listen(config.port, '0.0.0.0', () => {
      console.log(`\n🚀 Server is running on port ${config.port}`);
      console.log(`🌍 Environment: ${config.env}`);
      console.log('📡 Allowed CORS origins:', config.cors.allowedOrigins);
      console.log(`🕒 Server started at: ${new Date().toISOString()}\n`);
    });
    
    // Handle server errors
    server.on('error', (error: NodeJS.ErrnoException) => {
      if (error.syscall !== 'listen') throw error;
      
      // Handle specific listen errors with friendly messages
      switch (error.code) {
        case 'EACCES':
          console.error(`Port ${config.port} requires elevated privileges`);
          process.exit(1);
          break;
        case 'EADDRINUSE':
          console.error(`Port ${config.port} is already in use`);
          process.exit(1);
          break;
        default:
          throw error;
      }
    });
    
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
