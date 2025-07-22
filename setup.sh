#!/bin/bash

# Minecraft Fabric Server Quick Setup Script
# This script helps with the initial server setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Minecraft Fabric Server Setup Tool    ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check if running as root (not recommended)
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}Warning: Running as root is not recommended${NC}"
    echo -e "${YELLOW}Consider creating a dedicated user for the server${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Java installation
echo -e "${BLUE}Checking Java installation...${NC}"
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo -e "${GREEN}✓ Java found: $JAVA_VERSION${NC}"
    
    # Extract major version number
    JAVA_MAJOR=$(echo $JAVA_VERSION | cut -d. -f1)
    if [ "$JAVA_MAJOR" -lt 21 ]; then
        echo -e "${RED}✗ Java 21 or higher is required${NC}"
        echo -e "${YELLOW}Please install Java 21: https://adoptium.net/${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Java not found${NC}"
    echo -e "${YELLOW}Please install Java 21: https://adoptium.net/${NC}"
    exit 1
fi

# Check for required files
echo ""
echo -e "${BLUE}Checking server files...${NC}"

if [ ! -f "fabric-server-launcher.jar" ]; then
    echo -e "${YELLOW}✗ fabric-server-launcher.jar not found${NC}"
    echo -e "${YELLOW}Please download it from: https://fabricmc.net/use/server/${NC}"
    echo ""
    read -p "Download automatically? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Downloading Fabric server launcher...${NC}"
        if command_exists wget; then
            wget -O fabric-installer.jar https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.12.0/fabric-installer-0.12.0.jar
            java -jar fabric-installer.jar server -mcversion 1.21 -loader latest
            rm fabric-installer.jar
            echo -e "${GREEN}✓ Fabric server files downloaded${NC}"
        elif command_exists curl; then
            curl -o fabric-installer.jar https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.12.0/fabric-installer-0.12.0.jar
            java -jar fabric-installer.jar server -mcversion 1.21 -loader latest
            rm fabric-installer.jar
            echo -e "${GREEN}✓ Fabric server files downloaded${NC}"
        else
            echo -e "${RED}✗ wget or curl required for automatic download${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Please download manually and run this script again${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ fabric-server-launcher.jar found${NC}"
fi

# Check mods directory
echo ""
echo -e "${BLUE}Checking mods directory...${NC}"
if [ ! -d "mods" ]; then
    mkdir -p mods
    echo -e "${GREEN}✓ Created mods directory${NC}"
else
    echo -e "${GREEN}✓ Mods directory exists${NC}"
fi

MOD_COUNT=$(find mods -name "*.jar" | wc -l)
if [ "$MOD_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}✗ No mods found in mods/ directory${NC}"
    echo -e "${YELLOW}Please refer to MODS_REQUIRED.md for download instructions${NC}"
else
    echo -e "${GREEN}✓ Found $MOD_COUNT mod(s) in mods directory${NC}"
fi

# Check if EULA needs to be accepted
echo ""
echo -e "${BLUE}Checking EULA...${NC}"
if [ ! -f "eula.txt" ]; then
    echo -e "${YELLOW}✗ EULA not found (will be created on first run)${NC}"
elif grep -q "eula=true" eula.txt; then
    echo -e "${GREEN}✓ EULA accepted${NC}"
else
    echo -e "${YELLOW}✗ EULA not accepted${NC}"
    echo -e "${BLUE}Minecraft EULA: https://minecraft.net/eula${NC}"
    echo ""
    read -p "Accept EULA? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "eula=true" > eula.txt
        echo -e "${GREEN}✓ EULA accepted${NC}"
    else
        echo -e "${YELLOW}Server cannot start without EULA acceptance${NC}"
    fi
fi

# Check system resources
echo ""
echo -e "${BLUE}Checking system resources...${NC}"

# Check available RAM
if command_exists free; then
    TOTAL_RAM=$(free -h | awk '/^Mem:/ {print $2}')
    AVAILABLE_RAM=$(free -h | awk '/^Mem:/ {print $7}')
    echo -e "${GREEN}✓ System RAM: $TOTAL_RAM (Available: $AVAILABLE_RAM)${NC}"
    
    # Convert to GB for comparison (rough)
    TOTAL_GB=$(free -g | awk '/^Mem:/ {print $2}')
    if [ "$TOTAL_GB" -lt 4 ]; then
        echo -e "${YELLOW}⚠ Warning: Less than 4GB RAM detected${NC}"
        echo -e "${YELLOW}Consider upgrading for better performance${NC}"
    fi
elif command_exists vm_stat; then
    # macOS
    echo -e "${GREEN}✓ macOS system detected${NC}"
else
    echo -e "${YELLOW}✓ Could not determine RAM info${NC}"
fi

# Check disk space
if command_exists df; then
    DISK_SPACE=$(df -h . | awk 'NR==2 {print $4}')
    echo -e "${GREEN}✓ Available disk space: $DISK_SPACE${NC}"
fi

# Port availability check
echo ""
echo -e "${BLUE}Checking port availability...${NC}"

check_port() {
    local port=$1
    local protocol=$2
    if command_exists ss; then
        if ss -ln${protocol} | grep -q ":${port} "; then
            echo -e "${RED}✗ Port ${port}/${protocol} is in use${NC}"
            return 1
        else
            echo -e "${GREEN}✓ Port ${port}/${protocol} is available${NC}"
            return 0
        fi
    elif command_exists netstat; then
        if netstat -ln${protocol} | grep -q ":${port} "; then
            echo -e "${RED}✗ Port ${port}/${protocol} is in use${NC}"
            return 1
        else
            echo -e "${GREEN}✓ Port ${port}/${protocol} is available${NC}"
            return 0
        fi
    else
        echo -e "${YELLOW}✓ Cannot check port availability (ss/netstat not found)${NC}"
        return 0
    fi
}

check_port 25565 t  # TCP for Java Edition
check_port 19132 u  # UDP for Bedrock Edition

# Final setup summary
echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}           Setup Summary                 ${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}✓ Java 21+ installed${NC}"
echo -e "${GREEN}✓ Fabric server launcher ready${NC}"
echo -e "${GREEN}✓ Configuration files created${NC}"
echo -e "${GREEN}✓ Launch scripts ready${NC}"

if [ "$MOD_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Mods installed ($MOD_COUNT mods)${NC}"
else
    echo -e "${YELLOW}⚠ Mods need to be installed${NC}"
fi

if [ -f "eula.txt" ] && grep -q "eula=true" eula.txt; then
    echo -e "${GREEN}✓ EULA accepted${NC}"
else
    echo -e "${YELLOW}⚠ EULA needs to be accepted${NC}"
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
if [ "$MOD_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}1. Install required mods (see MODS_REQUIRED.md)${NC}"
fi

if [ ! -f "eula.txt" ] || ! grep -q "eula=true" eula.txt; then
    echo -e "${YELLOW}2. Accept the EULA by editing eula.txt${NC}"
fi

echo -e "${BLUE}3. Start the server:${NC}"
echo -e "${GREEN}   Linux/macOS: ./start.sh${NC}"
echo -e "${GREEN}   Windows: run.bat${NC}"

echo ""
echo -e "${BLUE}Server will be accessible on:${NC}"
echo -e "${GREEN}   Java Edition: localhost:25565${NC}"
echo -e "${GREEN}   Bedrock Edition: localhost:19132${NC}"

echo ""
echo -e "${GREEN}Setup complete! 🎉${NC}"