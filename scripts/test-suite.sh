#!/bin/bash

# MOITM Comprehensive Test Suite
# Tests all server functionality including cross-play features

set -e

# Configuration
TEST_HOST=${TEST_HOST:-localhost}
JAVA_PORT=${JAVA_PORT:-25565}
BEDROCK_PORT=${BEDROCK_PORT:-19132}
WEB_PORT=${WEB_PORT:-8080}
TIMEOUT=${TIMEOUT:-30}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

print_test_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_TOTAL++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
    ((TESTS_TOTAL++))
}

print_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Test server connectivity
test_server_connectivity() {
    print_test_header "Server Connectivity Tests"
    
    # Test Java Edition port
    if nc -z -w5 $TEST_HOST $JAVA_PORT 2>/dev/null; then
        print_pass "Java Edition port ($JAVA_PORT) is accessible"
    else
        print_fail "Java Edition port ($JAVA_PORT) is not accessible"
    fi
    
    # Test Bedrock port (UDP is harder to test)
    if nc -u -z -w5 $TEST_HOST $BEDROCK_PORT 2>/dev/null; then
        print_pass "Bedrock Edition port ($BEDROCK_PORT) appears accessible"
    else
        print_skip "Bedrock Edition port ($BEDROCK_PORT) status unknown (UDP)"
    fi
    
    # Test web client port
    if nc -z -w5 $TEST_HOST $WEB_PORT 2>/dev/null; then
        print_pass "Web client port ($WEB_PORT) is accessible"
    else
        print_fail "Web client port ($WEB_PORT) is not accessible"
    fi
}

# Test server status
test_server_status() {
    print_test_header "Server Status Tests"
    
    # Test if Minecraft server is responding
    if command -v mcstatus &> /dev/null; then
        if mcstatus $TEST_HOST:$JAVA_PORT status &>/dev/null; then
            print_pass "Minecraft server is responding to status queries"
            
            # Get detailed status
            STATUS=$(mcstatus $TEST_HOST:$JAVA_PORT status 2>/dev/null)
            if echo "$STATUS" | grep -q "players online"; then
                PLAYER_COUNT=$(echo "$STATUS" | grep -oP '\d+(?= of \d+ players online)')
                print_info "Players online: $PLAYER_COUNT"
            fi
        else
            print_fail "Minecraft server is not responding to status queries"
        fi
    else
        print_skip "mcstatus not installed - cannot test server status"
        print_info "Install with: pip install mcstatus"
    fi
}

# Test web client functionality
test_web_client() {
    print_test_header "Web Client Tests"
    
    # Test HTTP response
    if command -v curl &> /dev/null; then
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$TEST_HOST:$WEB_PORT 2>/dev/null || echo "000")
        if [ "$HTTP_CODE" = "200" ]; then
            print_pass "Web client returns HTTP 200"
        else
            print_fail "Web client returns HTTP $HTTP_CODE (expected 200)"
        fi
        
        # Test if HTML contains expected content
        if curl -s http://$TEST_HOST:$WEB_PORT 2>/dev/null | grep -q "MOITM"; then
            print_pass "Web client serves MOITM content"
        else
            print_fail "Web client does not serve expected MOITM content"
        fi
    else
        print_skip "curl not available - cannot test web client"
    fi
}

# Test mod loading
test_mod_loading() {
    print_test_header "Mod Loading Tests"
    
    # Check if mod directory exists and has mods
    if [ -d "server/mods" ]; then
        MOD_COUNT=$(find server/mods -name "*.jar" | wc -l)
        if [ "$MOD_COUNT" -gt 0 ]; then
            print_pass "Found $MOD_COUNT mod(s) in server/mods directory"
        else
            print_fail "No mods found in server/mods directory"
        fi
    else
        print_fail "server/mods directory does not exist"
    fi
    
    # Check for required cross-play mods
    REQUIRED_MODS=("geyser" "floodgate" "viafabric")
    for mod in "${REQUIRED_MODS[@]}"; do
        if find server/mods -name "*${mod}*" -type f | grep -q .; then
            print_pass "Required mod found: $mod"
        else
            print_fail "Required mod missing: $mod"
        fi
    done
}

# Test configuration files
test_configuration() {
    print_test_header "Configuration Tests"
    
    ENVIRONMENT=${ENVIRONMENT:-development}
    
    # Test server properties
    if [ -f "config/$ENVIRONMENT/server/server.properties" ]; then
        print_pass "Server properties configuration exists"
        
        # Check important settings
        if grep -q "online-mode=false" "config/$ENVIRONMENT/server/server.properties"; then
            print_pass "Online mode disabled (required for cross-play)"
        else
            print_fail "Online mode not disabled in server.properties"
        fi
    else
        print_fail "Server properties configuration missing"
    fi
    
    # Test Geyser config
    if [ -f "config/$ENVIRONMENT/geyser/config.yml" ]; then
        print_pass "Geyser configuration exists"
        
        if grep -q "auth-type: floodgate" "config/$ENVIRONMENT/geyser/config.yml"; then
            print_pass "Geyser configured for Floodgate authentication"
        else
            print_fail "Geyser not configured for Floodgate authentication"
        fi
    else
        print_fail "Geyser configuration missing"
    fi
    
    # Test Floodgate config
    if [ -f "config/$ENVIRONMENT/floodgate/config.yml" ]; then
        print_pass "Floodgate configuration exists"
    else
        print_fail "Floodgate configuration missing"
    fi
    
    # Test ViaFabric config
    if [ -f "config/$ENVIRONMENT/viafabric/viafabric.yml" ]; then
        print_pass "ViaFabric configuration exists"
    else
        print_fail "ViaFabric configuration missing"
    fi
}

# Test Java environment
test_java_environment() {
    print_test_header "Java Environment Tests"
    
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | sed 's/\..*//')
        if [ "$JAVA_VERSION" -ge 17 ]; then
            print_pass "Java $JAVA_VERSION is installed (minimum 17 required)"
        else
            print_fail "Java $JAVA_VERSION is too old (minimum 17 required)"
        fi
    else
        print_fail "Java is not installed"
    fi
    
    # Test memory settings
    if [ -n "$JAVA_OPTS" ]; then
        print_pass "JAVA_OPTS environment variable is set: $JAVA_OPTS"
    else
        print_info "JAVA_OPTS not set - using defaults"
    fi
}

# Test system resources
test_system_resources() {
    print_test_header "System Resource Tests"
    
    # Test available memory
    if command -v free &> /dev/null; then
        AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%.0f", $7/1024}')
        if [ "$AVAILABLE_MEM" -ge 4 ]; then
            print_pass "Available memory: ${AVAILABLE_MEM}GB (minimum 4GB recommended)"
        else
            print_fail "Available memory: ${AVAILABLE_MEM}GB (less than 4GB recommended)"
        fi
    else
        print_skip "Cannot check memory (free command not available)"
    fi
    
    # Test disk space
    if command -v df &> /dev/null; then
        AVAILABLE_DISK=$(df -h . | awk 'NR==2{print $4}' | sed 's/G//')
        if [ "${AVAILABLE_DISK%.*}" -ge 10 ]; then
            print_pass "Available disk space: ${AVAILABLE_DISK}GB"
        else
            print_fail "Available disk space: ${AVAILABLE_DISK}GB (less than 10GB recommended)"
        fi
    else
        print_skip "Cannot check disk space (df command not available)"
    fi
}

# Test Docker setup (if applicable)
test_docker_setup() {
    print_test_header "Docker Setup Tests"
    
    if command -v docker &> /dev/null; then
        print_pass "Docker is installed"
        
        if [ -f "docker-compose.yml" ]; then
            print_pass "docker-compose.yml exists"
            
            # Validate docker-compose file
            if command -v docker-compose &> /dev/null; then
                if docker-compose config &>/dev/null; then
                    print_pass "docker-compose.yml is valid"
                else
                    print_fail "docker-compose.yml is invalid"
                fi
            else
                print_skip "docker-compose not installed - cannot validate compose file"
            fi
        else
            print_fail "docker-compose.yml missing"
        fi
    else
        print_skip "Docker not installed - skipping Docker tests"
    fi
}

# Test security settings
test_security() {
    print_test_header "Security Tests"
    
    # Check for secure file permissions
    if [ -f "start.sh" ]; then
        if [ -x "start.sh" ]; then
            print_pass "start.sh has execute permissions"
        else
            print_fail "start.sh lacks execute permissions"
        fi
    fi
    
    # Check for potential security issues
    if grep -r "password.*=" config/ 2>/dev/null | grep -v "password=\${" | grep -v "password=$" | grep -q .; then
        print_fail "Hardcoded passwords found in configuration files"
    else
        print_pass "No hardcoded passwords found in configuration"
    fi
}

# Performance test (basic)
test_performance() {
    print_test_header "Basic Performance Tests"
    
    # Test response time
    if command -v curl &> /dev/null && nc -z -w5 $TEST_HOST $WEB_PORT 2>/dev/null; then
        RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" http://$TEST_HOST:$WEB_PORT 2>/dev/null || echo "0")
        RESPONSE_MS=$(echo "$RESPONSE_TIME * 1000" | bc 2>/dev/null || echo "0")
        
        if (( $(echo "$RESPONSE_TIME < 2.0" | bc -l 2>/dev/null || echo "0") )); then
            print_pass "Web client response time: ${RESPONSE_MS}ms"
        else
            print_fail "Web client response time too slow: ${RESPONSE_MS}ms"
        fi
    else
        print_skip "Cannot test web client response time"
    fi
}

# Main test function
main() {
    echo "========================================"
    echo "MOITM Server Test Suite"
    echo "========================================"
    echo "Host: $TEST_HOST"
    echo "Java Port: $JAVA_PORT"
    echo "Bedrock Port: $BEDROCK_PORT"
    echo "Web Port: $WEB_PORT"
    echo "Timeout: ${TIMEOUT}s"
    echo "========================================"
    
    # Run all tests
    test_java_environment
    test_system_resources
    test_configuration
    test_mod_loading
    test_docker_setup
    test_security
    test_server_connectivity
    test_server_status
    test_web_client
    test_performance
    
    # Test summary
    echo
    echo "========================================"
    echo "Test Summary"
    echo "========================================"
    echo "Total Tests: $TESTS_TOTAL"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            TEST_HOST="$2"
            shift 2
            ;;
        --java-port)
            JAVA_PORT="$2"
            shift 2
            ;;
        --bedrock-port)
            BEDROCK_PORT="$2"
            shift 2
            ;;
        --web-port)
            WEB_PORT="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --help|-h)
            echo "MOITM Server Test Suite"
            echo "Usage: $0 [options]"
            echo
            echo "Options:"
            echo "  --host HOST        Target host (default: localhost)"
            echo "  --java-port PORT   Java Edition port (default: 25565)"
            echo "  --bedrock-port PORT Bedrock Edition port (default: 19132)"
            echo "  --web-port PORT    Web client port (default: 8080)"
            echo "  --timeout SECONDS  Connection timeout (default: 30)"
            echo "  --help, -h         Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Install required tools if missing
if ! command -v bc &> /dev/null; then
    print_info "Installing bc for calculations..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y bc
    elif command -v yum &> /dev/null; then
        sudo yum install -y bc
    fi
fi

# Run main function
main