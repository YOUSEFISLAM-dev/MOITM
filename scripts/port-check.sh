#!/bin/bash

# MOITM Server Port and Connectivity Test Script
# Tests all required ports and network connectivity

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
JAVA_PORT=${JAVA_PORT:-25565}
BEDROCK_PORT=${BEDROCK_PORT:-19132}
WEB_PORT=${WEB_PORT:-8080}
RCON_PORT=${RCON_PORT:-25575}
HOST=${HOST:-localhost}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Function to check if port is open
check_port() {
    local port=$1
    local protocol=${2:-tcp}
    local name=$3
    
    if [ "$protocol" = "tcp" ]; then
        if nc -z -w5 $HOST $port 2>/dev/null; then
            print_success "$name port $port/tcp is open"
            return 0
        else
            print_error "$name port $port/tcp is closed or unreachable"
            return 1
        fi
    else
        # UDP check is more complex
        if nc -u -z -w5 $HOST $port 2>/dev/null; then
            print_success "$name port $port/udp is open"
            return 0
        else
            print_warning "$name port $port/udp status unknown (UDP is connectionless)"
            return 0
        fi
    fi
}

# Function to check if port is in use
check_port_usage() {
    local port=$1
    local protocol=${2:-tcp}
    local name=$3
    
    if [ "$protocol" = "tcp" ]; then
        if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
            print_success "$name port $port/tcp is in use (server running)"
            return 0
        else
            print_warning "$name port $port/tcp is not in use (server not running)"
            return 1
        fi
    else
        if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
            print_success "$name port $port/udp is in use (server running)"
            return 0
        else
            print_warning "$name port $port/udp is not in use (server not running)"
            return 1
        fi
    fi
}

# Function to test Java Edition connectivity
test_java_edition() {
    print_status "Testing Java Edition connectivity..."
    
    if check_port_usage $JAVA_PORT tcp "Java Edition"; then
        # Try to get server status
        if command -v mcstatus &> /dev/null; then
            print_status "Getting server status..."
            mcstatus $HOST:$JAVA_PORT status 2>/dev/null && print_success "Java Edition server is responding" || print_warning "Java Edition server may not be fully ready"
        else
            print_warning "mcstatus not installed, cannot check server status"
        fi
    fi
}

# Function to test Bedrock Edition connectivity
test_bedrock_edition() {
    print_status "Testing Bedrock Edition connectivity..."
    check_port_usage $BEDROCK_PORT udp "Bedrock Edition"
}

# Function to test web client connectivity
test_web_client() {
    print_status "Testing web client connectivity..."
    
    if check_port_usage $WEB_PORT tcp "Web Client"; then
        # Try to get HTTP response
        if command -v curl &> /dev/null; then
            if curl -s -o /dev/null -w "%{http_code}" http://$HOST:$WEB_PORT | grep -q "200\|301\|302"; then
                print_success "Web client is accessible"
            else
                print_warning "Web client port is open but HTTP response unexpected"
            fi
        elif command -v wget &> /dev/null; then
            if wget -q --spider http://$HOST:$WEB_PORT 2>/dev/null; then
                print_success "Web client is accessible"
            else
                print_warning "Web client port is open but HTTP response unexpected"
            fi
        fi
    fi
}

# Function to test RCON connectivity
test_rcon() {
    print_status "Testing RCON connectivity (optional)..."
    check_port_usage $RCON_PORT tcp "RCON"
}

# Function to check firewall status
check_firewall() {
    print_status "Checking firewall status..."
    
    # Check iptables
    if command -v iptables &> /dev/null && [ "$EUID" -eq 0 ]; then
        if iptables -L INPUT -n | grep -q "ACCEPT.*dpt:$JAVA_PORT"; then
            print_success "iptables allows Java Edition port"
        else
            print_warning "iptables rule for Java Edition port not found"
        fi
    fi
    
    # Check ufw
    if command -v ufw &> /dev/null; then
        if ufw status | grep -q "$JAVA_PORT"; then
            print_success "ufw allows Java Edition port"
        else
            print_warning "ufw rule for Java Edition port not found"
        fi
    fi
    
    # Check firewalld
    if command -v firewall-cmd &> /dev/null; then
        if firewall-cmd --list-ports 2>/dev/null | grep -q "$JAVA_PORT"; then
            print_success "firewalld allows Java Edition port"
        else
            print_warning "firewalld rule for Java Edition port not found"
        fi
    fi
}

# Function to check system resources
check_resources() {
    print_status "Checking system resources..."
    
    # Check memory
    if command -v free &> /dev/null; then
        AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%.0f", $7/1024}')
        if [ "$AVAILABLE_MEM" -gt 4 ]; then
            print_success "Available memory: ${AVAILABLE_MEM}GB"
        else
            print_warning "Available memory: ${AVAILABLE_MEM}GB (recommended: 4GB+)"
        fi
    fi
    
    # Check disk space
    if command -v df &> /dev/null; then
        AVAILABLE_DISK=$(df -h . | awk 'NR==2{print $4}' | sed 's/G//')
        if [ "${AVAILABLE_DISK%.*}" -gt 10 ]; then
            print_success "Available disk space: ${AVAILABLE_DISK}"
        else
            print_warning "Available disk space: ${AVAILABLE_DISK} (recommended: 10GB+)"
        fi
    fi
    
    # Check Java
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        print_success "Java version: $JAVA_VERSION"
    else
        print_error "Java not found"
    fi
}

# Function to generate port forwarding instructions
generate_port_forwarding_guide() {
    print_status "Port forwarding configuration needed:"
    echo
    echo "Configure your router/firewall to forward these ports:"
    echo "  - TCP $JAVA_PORT  -> Java Edition clients"
    echo "  - UDP $BEDROCK_PORT -> Bedrock Edition clients"
    echo "  - TCP $WEB_PORT   -> Web client access"
    echo "  - TCP $RCON_PORT  -> RCON (optional)"
    echo
    echo "Firewall commands (run as root):"
    echo "  # iptables"
    echo "  iptables -A INPUT -p tcp --dport $JAVA_PORT -j ACCEPT"
    echo "  iptables -A INPUT -p udp --dport $BEDROCK_PORT -j ACCEPT"
    echo "  iptables -A INPUT -p tcp --dport $WEB_PORT -j ACCEPT"
    echo
    echo "  # ufw"
    echo "  ufw allow $JAVA_PORT/tcp"
    echo "  ufw allow $BEDROCK_PORT/udp"
    echo "  ufw allow $WEB_PORT/tcp"
    echo
    echo "  # firewalld"
    echo "  firewall-cmd --permanent --add-port=$JAVA_PORT/tcp"
    echo "  firewall-cmd --permanent --add-port=$BEDROCK_PORT/udp"
    echo "  firewall-cmd --permanent --add-port=$WEB_PORT/tcp"
    echo "  firewall-cmd --reload"
    echo
}

# Main function
main() {
    echo "=========================================="
    echo "MOITM Server Connectivity Test"
    echo "=========================================="
    echo "Host: $HOST"
    echo "Java Port: $JAVA_PORT"
    echo "Bedrock Port: $BEDROCK_PORT"
    echo "Web Port: $WEB_PORT"
    echo "RCON Port: $RCON_PORT"
    echo "=========================================="
    echo
    
    # Run tests
    check_resources
    echo
    
    test_java_edition
    echo
    
    test_bedrock_edition
    echo
    
    test_web_client
    echo
    
    test_rcon
    echo
    
    check_firewall
    echo
    
    generate_port_forwarding_guide
    
    echo "=========================================="
    print_status "Test completed"
    echo "=========================================="
}

# Check if script is run with help argument
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "MOITM Server Port Test Script"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --host HOST        Target host (default: localhost)"
    echo "  --java-port PORT   Java Edition port (default: 25565)"
    echo "  --bedrock-port PORT Bedrock Edition port (default: 19132)"
    echo "  --web-port PORT    Web client port (default: 8080)"
    echo "  --rcon-port PORT   RCON port (default: 25575)"
    echo "  --help, -h         Show this help"
    echo
    echo "Environment variables:"
    echo "  HOST, JAVA_PORT, BEDROCK_PORT, WEB_PORT, RCON_PORT"
    exit 0
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            HOST="$2"
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
        --rcon-port)
            RCON_PORT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run main function
main