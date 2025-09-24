#!/bin/bash

echo "🚀 Starting Comprehensive Integration Testing Suite"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo ""
    echo "📋 $1"
    echo "=================================================="
}

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "src" ]; then
    print_error "Please run this script from the backend directory"
    exit 1
fi

echo "Current directory: $(pwd)"

# Backend Integration Tests
print_header "Backend Integration Tests"

echo "Running API Integration Tests..."
if npm test -- --testPathPattern="integration/api" --verbose; then
    print_status "API Integration Tests PASSED"
else
    print_error "API Integration Tests FAILED"
    exit 1
fi

echo ""
echo "Running Performance Integration Tests..."
if npm test -- --testPathPattern="integration/performance" --verbose; then
    print_status "Performance Integration Tests PASSED"
else
    print_error "Performance Integration Tests FAILED"
    exit 1
fi

echo ""
echo "Running End-to-End Workflow Tests..."
if npm test -- --testPathPattern="integration/e2e-workflow" --verbose; then
    print_status "E2E Workflow Integration Tests PASSED"
else
    print_error "E2E Workflow Integration Tests FAILED"
    exit 1
fi

# Frontend Integration Tests (if app directory exists)
if [ -d "../app" ]; then
    print_header "Frontend Integration Tests"

    cd ../app
    echo "Current directory: $(pwd)"

    echo "Running Flutter Integration Tests..."
    if flutter test integration/ --verbose; then
        print_status "Flutter Integration Tests PASSED"
    else
        print_error "Flutter Integration Tests FAILED"
        cd ../backend
        exit 1
    fi

    cd ../backend
else
    print_warning "Frontend directory not found, skipping Flutter tests"
fi

# Cross-Platform Integration Tests
print_header "Cross-Platform Integration Tests"

echo "Testing API endpoints from external requests..."
if npm test -- --testPathPattern="integration/cross-platform" --verbose 2>/dev/null; then
    print_status "Cross-Platform Integration Tests PASSED"
elif [ ! -f "src/__tests__/integration/cross-platform.integration.test.ts" ]; then
    print_warning "Cross-platform tests not found, skipping"
else
    print_error "Cross-Platform Integration Tests FAILED"
    exit 1
fi

# Database Integration Tests
print_header "Database Integration Tests"

echo "Testing database connections and migrations..."
if npm test -- --testPathPattern="integration/database" --verbose 2>/dev/null; then
    print_status "Database Integration Tests PASSED"
elif [ ! -f "src/__tests__/integration/database.integration.test.ts" ]; then
    print_warning "Database integration tests not found, skipping"
else
    print_error "Database Integration Tests FAILED"
    exit 1
fi

# Security Integration Tests
print_header "Security Integration Tests"

echo "Testing authentication and authorization..."
if npm test -- --testPathPattern="integration/security" --verbose 2>/dev/null; then
    print_status "Security Integration Tests PASSED"
elif [ ! -f "src/__tests__/integration/security.integration.test.ts" ]; then
    print_warning "Security integration tests not found, skipping"
else
    print_error "Security Integration Tests FAILED"
    exit 1
fi

# Load Testing
print_header "Load Testing"

echo "Running load tests..."
if npm test -- --testPathPattern="integration/load" --verbose 2>/dev/null; then
    print_status "Load Testing PASSED"
elif [ ! -f "src/__tests__/integration/load.integration.test.ts" ]; then
    print_warning "Load tests not found, skipping"
else
    print_error "Load Testing FAILED"
    exit 1
fi

# Final Summary
print_header "Integration Testing Summary"

echo "🎯 Integration Testing Results:"
echo "================================"

# Count total tests run
TOTAL_TESTS=$(npm test -- --testPathPattern="integration" --json 2>/dev/null | jq '.numTotalTests' 2>/dev/null || echo "0")
PASSED_TESTS=$(npm test -- --testPathPattern="integration" --json 2>/dev/null | jq '.numPassedTests' 2>/dev/null || echo "0")
FAILED_TESTS=$(npm test -- --testPathPattern="integration" --json 2>/dev/null | jq '.numFailedTests' 2>/dev/null || echo "0")

echo "📊 Backend Integration Tests:"
echo "   Total: $TOTAL_TESTS"
echo "   Passed: $PASSED_TESTS"
echo "   Failed: $FAILED_TESTS"

if [ "$FAILED_TESTS" -eq "0" ]; then
    print_status "✅ All Backend Integration Tests PASSED"
else
    print_error "❌ $FAILED_TESTS Backend Integration Tests FAILED"
fi

# Frontend test results (if available)
if [ -d "../app" ]; then
    cd ../app
    FRONTEND_TESTS=$(flutter test integration/ --json 2>/dev/null | jq '.numTotalTests' 2>/dev/null || echo "0")
    FRONTEND_PASSED=$(flutter test integration/ --json 2>/dev/null | jq '.numPassedTests' 2>/dev/null || echo "0")
    FRONTEND_FAILED=$(flutter test integration/ --json 2>/dev/null | jq '.numFailedTests' 2>/dev/null || echo "0")
    cd ../backend

    echo ""
    echo "📱 Frontend Integration Tests:"
    echo "   Total: $FRONTEND_TESTS"
    echo "   Passed: $FRONTEND_PASSED"
    echo "   Failed: $FRONTEND_FAILED"

    if [ "$FRONTEND_FAILED" -eq "0" ]; then
        print_status "✅ All Frontend Integration Tests PASSED"
    else
        print_error "❌ $FRONTEND_FAILED Frontend Integration Tests FAILED"
    fi
fi

echo ""
echo "🎉 Integration Testing Complete!"
echo "================================"

if [ "$FAILED_TESTS" -eq "0" ] && [ "$FRONTEND_FAILED" -eq "0" ]; then
    print_status "🎊 ALL INTEGRATION TESTS PASSED!"
    echo ""
    echo "🚀 The Funding Machine is ready for production deployment!"
    echo "📋 Next steps:"
    echo "   1. Performance optimization"
    echo "   2. Security audit"
    echo "   3. Production environment setup"
    echo "   4. Deployment preparation"
else
    print_error "❌ Some integration tests failed. Please review and fix the issues."
    echo ""
    echo "🔧 Troubleshooting steps:"
    echo "   1. Check test output for specific error messages"
    echo "   2. Verify database connections"
    echo "   3. Check API endpoints are responding correctly"
    echo "   4. Validate authentication flows"
    exit 1
fi
