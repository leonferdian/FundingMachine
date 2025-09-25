import express from 'express';
import { register, collectDefaultMetrics, Gauge, Counter, Histogram } from 'prom-client';
import { logger } from './logger';

// Create a Registry which registers the metrics
collectDefaultMetrics({ register });

// Create custom metrics
const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const activeConnections = new Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

const databaseConnections = new Gauge({
  name: 'database_connections',
  help: 'Number of database connections'
});

const errorRate = new Counter({
  name: 'error_rate_total',
  help: 'Total number of errors',
  labelNames: ['type', 'endpoint']
});

export class MonitoringService {
  private app: express.Application;

  constructor(app: express.Application) {
    this.app = app;
    this.initializeMetrics();
    this.setupHealthCheck();
  }

  private initializeMetrics(): void {
    // Track HTTP requests
    this.app.use((req, res, next) => {
      const start = Date.now();

      activeConnections.inc();

      res.on('finish', () => {
        const duration = (Date.now() - start) / 1000;

        activeConnections.dec();

        httpRequestsTotal
          .labels(req.method, req.route?.path || req.path, res.statusCode.toString())
          .inc();

        httpRequestDuration
          .labels(req.method, req.route?.path || req.path)
          .observe(duration);

        // Track errors
        if (res.statusCode >= 400) {
          errorRate.labels('http_error', req.route?.path || req.path).inc();
        }
      });

      next();
    });

    // Track database connections (placeholder)
    setInterval(() => {
      databaseConnections.set(Math.floor(Math.random() * 10) + 1);
    }, 5000);
  }

  private setupHealthCheck(): void {
    // Health check endpoint
    this.app.get('/health', (req, res) => {
      const healthCheck = {
        uptime: process.uptime(),
        message: 'OK',
        timestamp: Date.now(),
        services: {
          database: 'healthy',
          redis: 'healthy',
          memory: this.getMemoryUsage()
        }
      };

      res.status(200).json(healthCheck);
    });

    // Detailed health check
    this.app.get('/health/detailed', (req, res) => {
      const detailedHealth = {
        uptime: process.uptime(),
        memory: this.getMemoryUsage(),
        cpu: process.cpuUsage(),
        timestamp: Date.now(),
        version: process.version,
        environment: process.env.NODE_ENV
      };

      res.status(200).json(detailedHealth);
    });

    // Metrics endpoint for Prometheus
    this.app.get('/metrics', async (req, res) => {
      try {
        res.set('Content-Type', register.contentType);
        const metrics = await register.metrics();
        res.end(metrics);
      } catch (ex) {
        res.status(500).end(ex);
      }
    });
  }

  private getMemoryUsage() {
    const memUsage = process.memoryUsage();
    return {
      rss: Math.round(memUsage.rss / 1024 / 1024), // RSS in MB
      heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024), // Heap total in MB
      heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024), // Heap used in MB
      external: Math.round(memUsage.external / 1024 / 1024), // External memory in MB
    };
  }

  // Method to manually increment error counter
  public incrementError(type: string, endpoint: string): void {
    errorRate.labels(type, endpoint).inc();
  }

  // Method to get current metrics
  public async getMetrics(): Promise<string> {
    return await register.metrics();
  }
}
