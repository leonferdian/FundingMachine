import { Request, Response } from 'express';
import prisma from '../config/database';
import config from '../config/config';

/**
 * @desc    Health check endpoint
 * @route   GET /api/health
 * @access  Public
 */
export const healthCheck = async (req: Request, res: Response) => {
  try {
    // Check database connection
    await prisma.$queryRaw`SELECT 1`;
    
    res.status(200).json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      environment: config.env,
      database: 'connected',
      version: process.env.npm_package_version || '1.0.0',
    });
  } catch (error) {
    console.error('Health check failed:', error);
    res.status(503).json({
      status: 'error',
      message: 'Service Unavailable',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
};

/**
 * @desc    API information
 * @route   GET /api
 * @access  Public
 */
export const apiInfo = (req: Request, res: Response) => {
  res.json({
    name: 'Funding Machine API',
    version: process.env.npm_package_version || '1.0.0',
    environment: config.env,
    documentation: '/api-docs',
    status: 'operational',
    timestamp: new Date().toISOString(),
  });
};
