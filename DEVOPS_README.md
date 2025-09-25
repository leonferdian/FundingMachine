# 🚀 DevOps & Deployment Pipeline - Complete Setup

## Overview

This comprehensive DevOps setup provides automated build, testing, deployment, and monitoring capabilities for the Funding Machine platform.

## 📋 Components

### 1. **CI/CD Pipeline** (GitHub Actions)
- **Location**: `.github/workflows/ci-cd.yml`
- **Features**:
  - Automated testing on every push/PR
  - Multi-stage Docker builds
  - Security scanning with Snyk and Trivy
  - Automated deployment to staging/production
  - Code coverage reporting

### 2. **Containerization** (Docker)
- **Backend Dockerfile**: `backend/Dockerfile`
- **Docker Compose**: `docker-compose.yml`
- **Nginx Config**: `nginx/nginx.conf`
- **Features**:
  - Multi-stage builds for optimization
  - Health checks and monitoring
  - Load balancing with Nginx
  - Environment-specific configurations

### 3. **Monitoring & Logging**
- **Winston Logger**: `backend/src/utils/logger.ts`
- **Prometheus Metrics**: `backend/src/services/monitoring.service.ts`
- **Prometheus Config**: `monitoring/prometheus.yml`
- **Features**:
  - Structured logging with multiple levels
  - Real-time metrics collection
  - Performance monitoring
  - Error tracking and alerting

### 4. **Deployment Automation**
- **One-Click Deploy**: `deploy.sh`
- **Test Automation**: `test-automation.sh`
- **Features**:
  - Environment-specific deployments
  - Rollback capabilities
  - Health checks and validation
  - Comprehensive testing pipeline

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Node.js 18+ for local development
- Git repository access
- Docker Hub account (for image registry)

### Local Development Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd funding-machine
   ```

2. **Start local development environment**:
   ```bash
   # Start all services
   npm run docker:up

   # View logs
   npm run docker:logs

   # Stop services
   npm run docker:down
   ```

3. **Run tests**:
   ```bash
   # Run all tests
   npm run test:all

   # Run specific test types
   npm run test:unit
   npm run test:integration
   npm run test:e2e
   ```

## 🔧 Deployment Commands

### Staging Deployment
```bash
npm run deploy:staging
# or
./deploy.sh staging
```

### Production Deployment
```bash
npm run deploy:production
# or
./deploy.sh production
```

### Custom Tag Deployment
```bash
./deploy.sh production v1.2.3
```

### Rollback
```bash
./deploy.sh rollback
```

## 📊 Monitoring & Health Checks

### Health Endpoints
- **Application Health**: `http://localhost/health`
- **API Health**: `http://localhost:3000/api/health`
- **Detailed Health**: `http://localhost:3000/health/detailed`
- **Metrics**: `http://localhost:3000/metrics`

### Monitoring Access
- **Prometheus Dashboard**: `http://localhost:9090`
- **Grafana Dashboard**: `http://localhost:3001` (if configured)

### Log Files
- **Application Logs**: `backend/logs/`
- **Error Logs**: `backend/logs/error.log`
- **All Logs**: `backend/logs/all.log`

## 🧪 Testing Pipeline

### Automated Testing
```bash
# Run all tests
./test-automation.sh

# Run specific test types
./test-automation.sh backend
./test-automation.sh frontend
./test-automation.sh e2e
./test-automation.sh performance
./test-automation.sh security

# Generate test report
./test-automation.sh report
```

### Test Results
- **Test Logs**: `test-results/`
- **Coverage Reports**: `coverage/`
- **Test Report**: `test-results/test-report.html`

## 🏗️ CI/CD Pipeline Features

### Automated Workflows
1. **Backend Testing**: Unit, integration, API tests
2. **Frontend Testing**: Flutter tests, formatting, analysis
3. **Security Scanning**: Vulnerability detection and reporting
4. **Docker Builds**: Multi-stage optimized builds
5. **Deployment**: Automated deployment to staging/production

### Trigger Conditions
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Manual workflow dispatch

## 🔒 Security Features

### Security Scanning
- **Snyk**: Dependency vulnerability scanning
- **Trivy**: Container image security scanning
- **npm audit**: Package vulnerability detection
- **Rate Limiting**: API endpoint protection

### Security Headers
- Content Security Policy (CSP)
- XSS Protection
- Frame Options
- HTTPS enforcement

## 📈 Performance Monitoring

### Metrics Collected
- HTTP request duration and count
- Active connections
- Database connections
- Error rates
- Memory usage
- CPU usage

### Alerting Rules
- High error rates
- Slow response times
- Memory usage thresholds
- Database connection issues

## 🛠️ Development Scripts

### Backend Scripts
```bash
npm run dev              # Start development server
npm run build            # Build for production
npm run test             # Run tests
npm run test:coverage    # Generate coverage report
npm run lint             # Lint code
npm run lint:fix         # Fix linting issues
```

### Docker Scripts
```bash
npm run docker:build     # Build Docker image
npm run docker:run       # Run Docker container
npm run docker:up        # Start all services
npm run docker:down      # Stop all services
npm run docker:logs      # View container logs
```

### Deployment Scripts
```bash
npm run deploy           # Deploy to production
npm run deploy:staging   # Deploy to staging
```

## 🔄 Environment Configuration

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/funding_machine

# JWT
JWT_SECRET=your-super-secret-jwt-key

# Redis
REDIS_URL=redis://localhost:6379

# Docker
DOCKER_USERNAME=your-docker-username
DOCKER_PASSWORD=your-docker-password

# Node Environment
NODE_ENV=production
```

### Environment Files
- `.env.example` - Template for environment variables
- `.env` - Local development environment
- `.env.production` - Production environment variables

## 🚨 Troubleshooting

### Common Issues

1. **Port Conflicts**
   ```bash
   # Check what's using the ports
   lsof -i :3000
   lsof -i :5432
   lsof -i :6379

   # Kill conflicting processes
   kill -9 <PID>
   ```

2. **Permission Issues**
   ```bash
   # Fix script permissions
   chmod +x deploy.sh
   chmod +x test-automation.sh
   ```

3. **Docker Issues**
   ```bash
   # Clean up Docker
   docker system prune -a
   docker volume prune

   # Rebuild containers
   docker-compose down
   docker-compose up --build
   ```

4. **Database Issues**
   ```bash
   # Reset database
   docker-compose down
   docker volume rm funding-machine_postgres_data
   docker-compose up -d postgres
   ```

## 📞 Support

For issues with the DevOps setup:
1. Check the logs: `npm run docker:logs`
2. Review the health endpoints
3. Check the CI/CD pipeline logs in GitHub Actions
4. Verify environment variables are set correctly

## 🎯 Next Steps

1. **Configure External Monitoring**: Set up Grafana dashboards
2. **Alerting Setup**: Configure email/Slack notifications
3. **Backup Strategy**: Implement automated backups
4. **Scaling**: Configure horizontal scaling with load balancers
5. **CDN Integration**: Set up content delivery network

---

**🎉 DevOps Setup Complete!** The Funding Machine platform now has enterprise-grade deployment, monitoring, and testing capabilities.
