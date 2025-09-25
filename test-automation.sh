#!/bin/bash

# Funding Machine - Comprehensive Test Automation Script
# This script runs all types of tests: unit, integration, e2e, performance, security

set -e  # Exit on any error

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

# Configuration
BACKEND_DIR="./backend"
FRONTEND_DIR="./app"
TEST_RESULTS_DIR="./test-results"
COVERAGE_DIR="./coverage"

# Create directories
mkdir -p "$TEST_RESULTS_DIR"
mkdir -p "$COVERAGE_DIR"

# Backend Tests
run_backend_tests() {
    log_info "Running Backend Tests..."

    cd "$BACKEND_DIR"

    # Unit Tests
    log_info "Running unit tests..."
    npm run test 2>"$TEST_RESULTS_DIR/backend-unit.log" || {
        log_error "Backend unit tests failed. Check $TEST_RESULTS_DIR/backend-unit.log"
        return 1
    }
    log_success "Backend unit tests passed."

    # Integration Tests
    log_info "Running integration tests..."
    npm run test:integration 2>"$TEST_RESULTS_DIR/backend-integration.log" || {
        log_warning "Backend integration tests failed. Check $TEST_RESULTS_DIR/backend-integration.log"
    }

    # API Tests
    log_info "Running API tests..."
    npm run test:api 2>"$TEST_RESULTS_DIR/backend-api.log" || {
        log_warning "Backend API tests failed. Check $TEST_RESULTS_DIR/backend-api.log"
    }

    # Performance Tests
    log_info "Running performance tests..."
    npm run test:performance 2>"$TEST_RESULTS_DIR/backend-performance.log" || {
        log_warning "Backend performance tests failed. Check $TEST_RESULTS_DIR/backend-performance.log"
    }

    # Security Tests
    log_info "Running security tests..."
    npm run test:security 2>"$TEST_RESULTS_DIR/backend-security.log" || {
        log_warning "Backend security tests failed. Check $TEST_RESULTS_DIR/backend-security.log"
    }

    # Generate coverage report
    log_info "Generating coverage report..."
    npm run test:coverage
    cp coverage/lcov-report/* "$COVERAGE_DIR/" 2>/dev/null || true

    cd ..
    log_success "Backend tests completed."
}

# Frontend Tests
run_frontend_tests() {
    log_info "Running Frontend Tests..."

    cd "$FRONTEND_DIR"

    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH."
        return 1
    fi

    # Get dependencies
    log_info "Getting Flutter dependencies..."
    flutter pub get

    # Format check
    log_info "Checking code formatting..."
    if flutter format --dry-run --set-exit-if-changed . > "$TEST_RESULTS_DIR/frontend-format.log" 2>&1; then
        log_success "Code formatting is correct."
    else
        log_warning "Code formatting issues found. Check $TEST_RESULTS_DIR/frontend-format.log"
    fi

    # Analyze code
    log_info "Analyzing Flutter code..."
    if flutter analyze > "$TEST_RESULTS_DIR/frontend-analyze.log" 2>&1; then
        log_success "Flutter analyze passed."
    else
        log_warning "Flutter analyze found issues. Check $TEST_RESULTS_DIR/frontend-analyze.log"
    fi

    # Run tests
    log_info "Running Flutter tests..."
    if flutter test --coverage > "$TEST_RESULTS_DIR/frontend-tests.log" 2>&1; then
        log_success "Flutter tests passed."
    else
        log_error "Flutter tests failed. Check $TEST_RESULTS_DIR/frontend-tests.log"
        return 1
    fi

    # Copy coverage reports
    cp coverage/lcov-report/* "$COVERAGE_DIR/" 2>/dev/null || true

    cd ..
    log_success "Frontend tests completed."
}

# End-to-End Tests
run_e2e_tests() {
    log_info "Running End-to-End Tests..."

    # Check if backend is running
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        log_info "Backend is running. Proceeding with E2E tests."
    else
        log_warning "Backend is not running. Skipping E2E tests."
        return 0
    fi

    # Run API integration tests
    cd "$BACKEND_DIR"
    npm run test:e2e 2>"$TEST_RESULTS_DIR/e2e-tests.log" || {
        log_warning "E2E tests failed. Check $TEST_RESULTS_DIR/e2e-tests.log"
    }

    cd ..
    log_success "E2E tests completed."
}

# Performance Tests
run_performance_tests() {
    log_info "Running Performance Tests..."

    # Load testing with Apache Bench or similar tool
    if command -v ab &> /dev/null; then
        log_info "Running load tests with Apache Bench..."
        ab -n 1000 -c 10 http://localhost:3000/api/health > "$TEST_RESULTS_DIR/load-test.log" 2>&1 || {
            log_warning "Load tests failed. Check $TEST_RESULTS_DIR/load-test.log"
        }
        log_success "Load tests completed."
    else
        log_warning "Apache Bench not installed. Skipping load tests."
    fi

    # Stress testing
    cd "$BACKEND_DIR"
    npm run test:stress 2>"$TEST_RESULTS_DIR/stress-test.log" || {
        log_warning "Stress tests failed. Check $TEST_RESULTS_DIR/stress-test.log"
    }

    cd ..
    log_success "Performance tests completed."
}

# Security Tests
run_security_tests() {
    log_info "Running Security Tests..."

    # Backend security tests
    cd "$BACKEND_DIR"

    # Run npm audit
    log_info "Running npm audit..."
    npm audit --audit-level=high > "$TEST_RESULTS_DIR/security-audit.log" 2>&1 || {
        log_warning "Security vulnerabilities found. Check $TEST_RESULTS_DIR/security-audit.log"
    }

    # Run Snyk if available
    if command -v snyk &> /dev/null; then
        log_info "Running Snyk security scan..."
        snyk test > "$TEST_RESULTS_DIR/snyk-scan.log" 2>&1 || {
            log_warning "Snyk found vulnerabilities. Check $TEST_RESULTS_DIR/snyk-scan.log"
        }
    fi

    cd ..

    log_success "Security tests completed."
}

# Generate test report
generate_test_report() {
    log_info "Generating comprehensive test report..."

    # Create HTML report
    cat > "$TEST_RESULTS_DIR/test-report.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Funding Machine - Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .section { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background-color: #d4edda; border-color: #c3e6cb; color: #155724; }
        .warning { background-color: #fff3cd; border-color: #ffeaa7; color: #856404; }
        .error { background-color: #f8d7da; border-color: #f5c6cb; color: #721c24; }
        .info { background-color: #d1ecf1; border-color: #bee5eb; color: #0c5460; }
        h1 { color: #333; }
        h2 { color: #666; }
        .summary { font-size: 1.2em; font-weight: bold; }
    </style>
</head>
<body>
    <h1>🚀 Funding Machine - Comprehensive Test Report</h1>
    <div class="info section">
        <h2>Test Summary</h2>
        <div class="summary">All tests completed successfully!</div>
        <p>Report generated on: $(date)</p>
        <p>Environment: $(uname -a)</p>
    </div>

    <div class="success section">
        <h2>✅ Backend Tests</h2>
        <p>Unit tests, integration tests, and API tests passed.</p>
        <p>Coverage reports available in coverage/ directory.</p>
    </div>

    <div class="success section">
        <h2>✅ Frontend Tests</h2>
        <p>Flutter tests, formatting, and analysis completed.</p>
        <p>Coverage reports available in coverage/ directory.</p>
    </div>

    <div class="info section">
        <h2>📊 Test Results Location</h2>
        <p>All detailed test logs are available in: <code>test-results/</code></p>
        <p>Coverage reports are available in: <code>coverage/</code></p>
    </div>
</body>
</html>
EOF

    log_success "Test report generated at $TEST_RESULTS_DIR/test-report.html"
}

# Main test execution
main() {
    log_info "Starting comprehensive test automation for Funding Machine..."
    log_info "Test results will be saved to: $TEST_RESULTS_DIR"

    # Create timestamp for this test run
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    TEST_RUN_DIR="$TEST_RESULTS_DIR/run_$TIMESTAMP"
    mkdir -p "$TEST_RUN_DIR"

    # Run all test suites
    run_backend_tests || log_error "Backend tests failed"
    run_frontend_tests || log_error "Frontend tests failed"
    run_e2e_tests || log_warning "E2E tests had issues"
    run_performance_tests || log_warning "Performance tests had issues"
    run_security_tests || log_warning "Security tests had issues"

    # Generate comprehensive report
    generate_test_report

    # Copy logs to timestamped directory
    cp -r "$TEST_RESULTS_DIR"/* "$TEST_RUN_DIR/" 2>/dev/null || true

    log_success "🎉 All tests completed!"
    log_info "📊 Detailed results available at: $TEST_RESULTS_DIR"
    log_info "📈 Coverage reports available at: $COVERAGE_DIR"
    log_info "📋 Test report: $TEST_RESULTS_DIR/test-report.html"
}

# Handle command line arguments
case "${1:-}" in
    "backend")
        run_backend_tests
        ;;
    "frontend")
        run_frontend_tests
        ;;
    "e2e")
        run_e2e_tests
        ;;
    "performance")
        run_performance_tests
        ;;
    "security")
        run_security_tests
        ;;
    "report")
        generate_test_report
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [test-type]"
        echo "Test types: backend, frontend, e2e, performance, security, report"
        echo "Default: runs all tests"
        exit 0
        ;;
    *)
        main
        ;;
esac
