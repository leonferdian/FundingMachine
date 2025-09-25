#!/bin/bash

# Funding Machine - One-Click Deployment Script
# This script handles the complete deployment process

set -e  # Exit on any error

# Configuration
APP_NAME="funding-machine"
ENVIRONMENT=${1:-production}
DOCKER_USERNAME=${DOCKER_USERNAME:-"fundingmachine"}
TAG=${2:-"latest"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pre-deployment checks
pre_deployment_checks() {
    log_info "Running pre-deployment checks..."

    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi

    # Check if required environment variables are set
    if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
        log_error "Docker credentials not set. Please set DOCKER_USERNAME and DOCKER_PASSWORD."
        exit 1
    fi

    # Check if .env file exists
    if [ ! -f "backend/.env" ]; then
        log_warning "Backend .env file not found. Creating from template..."
        cp backend/.env.example backend/.env
        log_warning "Please update backend/.env with your environment variables."
    fi

    log_success "Pre-deployment checks completed."
}

# Build and push Docker images
build_and_push_images() {
    log_info "Building and pushing Docker images..."

    # Login to Docker Hub
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

    # Build and push backend image
    log_info "Building backend image..."
    docker build -t "$DOCKER_USERNAME/backend:$TAG" ./backend
    docker push "$DOCKER_USERNAME/backend:$TAG"

    log_success "Backend image built and pushed."

    # Build and push frontend image
    log_info "Building frontend image..."
    docker build -t "$DOCKER_USERNAME/frontend:$TAG" ./app
    docker push "$DOCKER_USERNAME/frontend:$TAG"

    log_success "Frontend image built and pushed."

    # Build and push nginx image
    log_info "Building nginx image..."
    docker build -t "$DOCKER_USERNAME/nginx:$TAG" ./nginx
    docker push "$DOCKER_USERNAME/nginx:$TAG"

    log_success "All images built and pushed successfully."
}

# Deploy to environment
deploy_to_environment() {
    log_info "Deploying to $ENVIRONMENT environment..."

    # Create environment-specific docker-compose file
    create_env_compose_file

    # Pull latest images
    docker-compose -f "docker-compose.$ENVIRONMENT.yml" pull

    # Stop existing containers
    docker-compose -f "docker-compose.$ENVIRONMENT.yml" down || true

    # Start new containers
    docker-compose -f "docker-compose.$ENVIRONMENT.yml" up -d

    # Wait for services to be healthy
    wait_for_services

    # Run post-deployment tests
    run_post_deployment_tests

    log_success "Deployment to $ENVIRONMENT completed successfully."
}

# Create environment-specific docker-compose file
create_env_compose_file() {
    log_info "Creating environment-specific configuration..."

    # Copy base docker-compose file
    cp docker-compose.yml "docker-compose.$ENVIRONMENT.yml"

    # Update environment variables based on environment
    if [ "$ENVIRONMENT" = "production" ]; then
        sed -i 's|NODE_ENV=development|NODE_ENV=production|g' "docker-compose.$ENVIRONMENT.yml"
        sed -i 's|TAG=latest|TAG='$TAG'|g' "docker-compose.$ENVIRONMENT.yml"
    fi
}

# Wait for services to be healthy
wait_for_services() {
    log_info "Waiting for services to be healthy..."

    # Wait for backend health check
    max_attempts=30
    attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:3000/health > /dev/null 2>&1; then
            log_success "Backend is healthy."
            break
        fi

        log_info "Waiting for backend health check... (attempt $attempt/$max_attempts)"
        sleep 10
        attempt=$((attempt + 1))
    done

    if [ $attempt -gt $max_attempts ]; then
        log_error "Backend failed to become healthy within expected time."
        exit 1
    fi
}

# Run post-deployment tests
run_post_deployment_tests() {
    log_info "Running post-deployment tests..."

    # Test basic health endpoints
    curl -f http://localhost/health || {
        log_error "Health check failed."
        exit 1
    }

    curl -f http://localhost:3000/api/health || {
        log_error "API health check failed."
        exit 1
    }

    # Test database connectivity
    docker-compose -f "docker-compose.$ENVIRONMENT.yml" exec -T backend npm run test:health || {
        log_warning "Health tests failed, but deployment continues."
    }

    log_success "Post-deployment tests completed."
}

# Rollback function
rollback() {
    log_warning "Rolling back deployment..."

    if [ -f "docker-compose.$ENVIRONMENT.yml.backup" ]; then
        mv "docker-compose.$ENVIRONMENT.yml.backup" "docker-compose.$ENVIRONMENT.yml"
        docker-compose -f "docker-compose.$ENVIRONMENT.yml" up -d
        log_success "Rollback completed."
    else
        log_error "No backup file found for rollback."
        exit 1
    fi
}

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."

    # Remove environment-specific files
    rm -f "docker-compose.$ENVIRONMENT.yml"

    log_success "Cleanup completed."
}

# Main deployment function
main() {
    log_info "Starting deployment of $APP_NAME to $ENVIRONMENT environment..."

    # Trap to cleanup on exit
    trap cleanup EXIT

    # Run pre-deployment checks
    pre_deployment_checks

    # Build and push images
    build_and_push_images

    # Deploy to environment
    deploy_to_environment

    log_success "🎉 Deployment completed successfully!"
    log_info "Application is now running at http://localhost"
    log_info "API is available at http://localhost:3000/api"
    log_info "Health check available at http://localhost/health"
}

# Handle command line arguments
case "${1:-}" in
    "staging")
        ENVIRONMENT="staging"
        ;;
    "production")
        ENVIRONMENT="production"
        ;;
    "rollback")
        rollback
        exit 0
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [environment] [tag]"
        echo "Environments: staging, production (default: production)"
        echo "Tag: Docker image tag (default: latest)"
        echo "Commands: rollback, help"
        exit 0
        ;;
    *)
        ENVIRONMENT="production"
        ;;
esac

# Run main deployment
main "$@"
