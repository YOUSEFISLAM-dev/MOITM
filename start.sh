#!/bin/bash

# MOITM Minecraft Fabric 1.21.7 Server Launch Script
# Compatible with both local and VPS environments

echo "=================================================="
echo "    MOITM Minecraft Fabric 1.21.7 Server"
echo "    Starting server with Bedrock support..."
echo "=================================================="

# Set working directory to script location
cd "$(dirname "$0")"

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "ERROR: Java is not installed or not in PATH"
    echo "Please install Java 21 or higher"
    exit 1
fi

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 21 ]; then
    echo "WARNING: Java 21 or higher is recommended for Minecraft 1.21.7"
    echo "Current version: $(java -version 2>&1 | head -n 1)"
    read -p "Continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if fabric server launcher exists
if [ ! -f "fabric-server-launch.jar" ]; then
    echo "ERROR: fabric-server-launch.jar not found!"
    echo "Please download the Fabric server launcher from:"
    echo "https://fabricmc.net/use/server/"
    exit 1
fi

# Create EULA file if it doesn't exist
if [ ! -f "eula.txt" ]; then
    echo "Creating eula.txt - you must accept the Minecraft EULA to continue"
    echo "# https://account.mojang.com/documents/minecraft_eula" > eula.txt
    echo "eula=false" >> eula.txt
    echo ""
    echo "Please edit eula.txt and change 'eula=false' to 'eula=true' to accept the Minecraft EULA"
    echo "Then run this script again"
    exit 1
fi

# Check if EULA is accepted
if ! grep -q "eula=true" eula.txt; then
    echo "ERROR: You must accept the Minecraft EULA by setting eula=true in eula.txt"
    exit 1
fi

# Set memory allocation based on system RAM
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2}')
if [ "$TOTAL_RAM" -gt 8192 ]; then
    # More than 8GB RAM
    MIN_RAM="2G"
    MAX_RAM="6G"
elif [ "$TOTAL_RAM" -gt 4096 ]; then
    # More than 4GB RAM
    MIN_RAM="1G"
    MAX_RAM="3G"
else
    # 4GB or less RAM
    MIN_RAM="512M"
    MAX_RAM="2G"
fi

echo "Detected system RAM: ${TOTAL_RAM}MB"
echo "Allocating ${MIN_RAM} to ${MAX_RAM} for Minecraft server"

# JVM optimization flags for Minecraft servers
JVM_ARGS=(
    "-Xms${MIN_RAM}"
    "-Xmx${MAX_RAM}"
    "-XX:+UseG1GC"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1NewSizePercent=30"
    "-XX:G1MaxNewSizePercent=40"
    "-XX:G1HeapRegionSize=8M"
    "-XX:G1ReservePercent=20"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:InitiatingHeapOccupancyPercent=15"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
    "-Dusing.aikars.flags=https://mcflags.emc.gs"
    "-Daikars.new.flags=true"
    "-Dfabric.log.level=WARN"
)

echo "Starting server with optimized JVM flags..."
echo "Java Edition: localhost:25565"
echo "Bedrock Edition: localhost:19132"
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server with all optimizations
java "${JVM_ARGS[@]}" -jar fabric-server-launch.jar nogui

echo ""
echo "Server stopped."