#!/bin/bash

# Minecraft Fabric Server Start Script
# Compatible with Linux and macOS

# Configuration
MIN_RAM="2G"
MAX_RAM="4G"
SERVER_JAR="fabric-server-launcher.jar"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}    Minecraft Fabric Server 1.21.7 Launcher    ${NC}"
echo -e "${BLUE}================================================${NC}"

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo -e "${RED}Error: Java is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install Java 21 or higher${NC}"
    exit 1
fi

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
echo -e "${GREEN}Java version detected: $JAVA_VERSION${NC}"

# Check if server jar exists
if [ ! -f "$SERVER_JAR" ]; then
    echo -e "${RED}Error: $SERVER_JAR not found!${NC}"
    echo -e "${YELLOW}Please download the Fabric server launcher from:${NC}"
    echo -e "${YELLOW}https://fabricmc.net/use/server/${NC}"
    exit 1
fi

# Check if EULA is accepted
if [ ! -f "eula.txt" ] || ! grep -q "eula=true" eula.txt; then
    echo -e "${YELLOW}EULA not accepted. Please read and accept the Minecraft EULA.${NC}"
    echo -e "${YELLOW}Edit eula.txt and change 'eula=false' to 'eula=true'${NC}"
    echo -e "${YELLOW}EULA: https://minecraft.net/eula${NC}"
    exit 1
fi

# Create logs directory if it doesn't exist
mkdir -p logs

# JVM arguments for optimal performance
JVM_ARGS="-Xms$MIN_RAM -Xmx$MAX_RAM"
JVM_ARGS="$JVM_ARGS -XX:+UseG1GC"
JVM_ARGS="$JVM_ARGS -XX:+ParallelRefProcEnabled"
JVM_ARGS="$JVM_ARGS -XX:MaxGCPauseMillis=200"
JVM_ARGS="$JVM_ARGS -XX:+UnlockExperimentalVMOptions"
JVM_ARGS="$JVM_ARGS -XX:+DisableExplicitGC"
JVM_ARGS="$JVM_ARGS -XX:+AlwaysPreTouch"
JVM_ARGS="$JVM_ARGS -XX:G1NewSizePercent=30"
JVM_ARGS="$JVM_ARGS -XX:G1MaxNewSizePercent=40"
JVM_ARGS="$JVM_ARGS -XX:G1HeapRegionSize=8M"
JVM_ARGS="$JVM_ARGS -XX:G1ReservePercent=20"
JVM_ARGS="$JVM_ARGS -XX:G1HeapWastePercent=5"
JVM_ARGS="$JVM_ARGS -XX:G1MixedGCCountTarget=4"
JVM_ARGS="$JVM_ARGS -XX:InitiatingHeapOccupancyPercent=15"
JVM_ARGS="$JVM_ARGS -XX:G1MixedGCLiveThresholdPercent=90"
JVM_ARGS="$JVM_ARGS -XX:G1RSetUpdatingPauseTimePercent=5"
JVM_ARGS="$JVM_ARGS -XX:SurvivorRatio=32"
JVM_ARGS="$JVM_ARGS -XX:+PerfDisableSharedMem"
JVM_ARGS="$JVM_ARGS -XX:MaxTenuringThreshold=1"

# Server arguments
SERVER_ARGS="--nogui"

echo -e "${GREEN}Starting Minecraft Fabric Server...${NC}"
echo -e "${YELLOW}RAM: $MIN_RAM - $MAX_RAM${NC}"
echo -e "${YELLOW}Server JAR: $SERVER_JAR${NC}"
echo -e "${BLUE}================================================${NC}"

# Start the server
java $JVM_ARGS -jar $SERVER_JAR $SERVER_ARGS

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}Server stopped. Check logs for any errors.${NC}"
echo -e "${BLUE}================================================${NC}"