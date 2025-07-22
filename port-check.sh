#!/bin/bash

# Minecraft Server Port Checker
# This script helps diagnose network connectivity issues

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}    Minecraft Server Port Checker       ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Default ports
JAVA_PORT=25565
BEDROCK_PORT=19132

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if port is listening
check_listening_port() {
    local port=$1
    local protocol=$2
    local service_name=$3
    
    echo -e "${BLUE}Checking $service_name (port $port/$protocol)...${NC}"
    
    if command_exists ss; then
        if ss -ln${protocol} | grep -q ":${port} "; then
            echo -e "${GREEN}✓ Port ${port}/${protocol} is listening${NC}"
            return 0
        else
            echo -e "${RED}✗ Port ${port}/${protocol} is not listening${NC}"
            return 1
        fi
    elif command_exists netstat; then
        if netstat -ln${protocol} | grep -q ":${port} "; then
            echo -e "${GREEN}✓ Port ${port}/${protocol} is listening${NC}"
            return 0
        else
            echo -e "${RED}✗ Port ${port}/${protocol} is not listening${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}? Cannot check port (ss/netstat not found)${NC}"
        return 2
    fi
}

# Function to check external connectivity
check_external_connectivity() {
    local port=$1
    local protocol=$2
    local service_name=$3
    
    echo -e "${BLUE}Checking external connectivity for $service_name...${NC}"
    
    if command_exists nc; then
        if timeout 5 nc -zv localhost $port 2>/dev/null; then
            echo -e "${GREEN}✓ Can connect to localhost:${port}${NC}"
        else
            echo -e "${RED}✗ Cannot connect to localhost:${port}${NC}"
        fi
    elif command_exists telnet; then
        if timeout 5 telnet localhost $port 2>/dev/null | grep -q "Connected"; then
            echo -e "${GREEN}✓ Can connect to localhost:${port}${NC}"
        else
            echo -e "${RED}✗ Cannot connect to localhost:${port}${NC}"
        fi
    else
        echo -e "${YELLOW}? Cannot test connectivity (nc/telnet not found)${NC}"
    fi
}

# Check if server is running
echo -e "${BLUE}Checking if Minecraft server is running...${NC}"
if pgrep -f "fabric-server-launcher.jar" > /dev/null; then
    echo -e "${GREEN}✓ Server process found${NC}"
    SERVER_RUNNING=true
else
    echo -e "${YELLOW}? Server process not found${NC}"
    echo -e "${YELLOW}Note: Server might not be running or using different jar name${NC}"
    SERVER_RUNNING=false
fi

echo ""

# Check Java Edition port
check_listening_port $JAVA_PORT "t" "Java Edition"
if [ $SERVER_RUNNING = true ]; then
    check_external_connectivity $JAVA_PORT "tcp" "Java Edition"
fi

echo ""

# Check Bedrock Edition port
check_listening_port $BEDROCK_PORT "u" "Bedrock Edition (Geyser)"
if [ $SERVER_RUNNING = true ]; then
    echo -e "${BLUE}Note: UDP connectivity testing is limited${NC}"
fi

echo ""

# Check firewall status (Linux)
if command_exists ufw; then
    echo -e "${BLUE}Checking UFW firewall status...${NC}"
    UFW_STATUS=$(ufw status 2>/dev/null | head -1)
    echo -e "${YELLOW}$UFW_STATUS${NC}"
    
    if ufw status | grep -q "$JAVA_PORT"; then
        echo -e "${GREEN}✓ Java port $JAVA_PORT rule found in UFW${NC}"
    else
        echo -e "${RED}✗ Java port $JAVA_PORT rule not found in UFW${NC}"
        echo -e "${YELLOW}  Add rule: sudo ufw allow $JAVA_PORT/tcp${NC}"
    fi
    
    if ufw status | grep -q "$BEDROCK_PORT"; then
        echo -e "${GREEN}✓ Bedrock port $BEDROCK_PORT rule found in UFW${NC}"
    else
        echo -e "${RED}✗ Bedrock port $BEDROCK_PORT rule not found in UFW${NC}"
        echo -e "${YELLOW}  Add rule: sudo ufw allow $BEDROCK_PORT/udp${NC}"
    fi
elif command_exists firewall-cmd; then
    echo -e "${BLUE}Checking firewalld status...${NC}"
    if firewall-cmd --state 2>/dev/null | grep -q "running"; then
        echo -e "${YELLOW}Firewalld is running${NC}"
        # Check if ports are open
        if firewall-cmd --list-ports | grep -q "$JAVA_PORT/tcp"; then
            echo -e "${GREEN}✓ Java port $JAVA_PORT/tcp is open${NC}"
        else
            echo -e "${RED}✗ Java port $JAVA_PORT/tcp is not open${NC}"
            echo -e "${YELLOW}  Add rule: sudo firewall-cmd --add-port=$JAVA_PORT/tcp --permanent${NC}"
        fi
        
        if firewall-cmd --list-ports | grep -q "$BEDROCK_PORT/udp"; then
            echo -e "${GREEN}✓ Bedrock port $BEDROCK_PORT/udp is open${NC}"
        else
            echo -e "${RED}✗ Bedrock port $BEDROCK_PORT/udp is not open${NC}"
            echo -e "${YELLOW}  Add rule: sudo firewall-cmd --add-port=$BEDROCK_PORT/udp --permanent${NC}"
        fi
    else
        echo -e "${GREEN}✓ Firewalld is not running${NC}"
    fi
else
    echo -e "${YELLOW}? No common firewall tools found (ufw/firewalld)${NC}"
fi

echo ""

# Network interface information
echo -e "${BLUE}Network interface information:${NC}"
if command_exists ip; then
    echo -e "${YELLOW}IP addresses:${NC}"
    ip addr show | grep "inet " | awk '{print $2}' | grep -v "127.0.0.1"
elif command_exists ifconfig; then
    echo -e "${YELLOW}IP addresses:${NC}"
    ifconfig | grep "inet " | awk '{print $2}' | grep -v "127.0.0.1"
fi

echo ""

# Provide connection instructions
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}         Connection Information          ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "${GREEN}Java Edition clients:${NC}"
echo -e "  ${YELLOW}Local: localhost:$JAVA_PORT${NC}"
echo -e "  ${YELLOW}LAN: <local-ip>:$JAVA_PORT${NC}"
echo -e "  ${YELLOW}Internet: <public-ip>:$JAVA_PORT${NC}"
echo ""
echo -e "${GREEN}Bedrock Edition clients:${NC}"
echo -e "  ${YELLOW}Local: localhost:$BEDROCK_PORT${NC}"
echo -e "  ${YELLOW}LAN: <local-ip>:$BEDROCK_PORT${NC}"
echo -e "  ${YELLOW}Internet: <public-ip>:$BEDROCK_PORT${NC}"

echo ""
echo -e "${BLUE}Troubleshooting tips:${NC}"
echo -e "${YELLOW}• Ensure server is running (./start.sh or run.bat)${NC}"
echo -e "${YELLOW}• Check firewall rules for ports $JAVA_PORT/tcp and $BEDROCK_PORT/udp${NC}"
echo -e "${YELLOW}• For VPS: Configure security groups in cloud console${NC}"
echo -e "${YELLOW}• For home networks: Configure port forwarding on router${NC}"
echo -e "${YELLOW}• Check server logs: tail -f logs/latest.log${NC}"

echo ""
echo -e "${GREEN}Port check complete! 🔍${NC}"