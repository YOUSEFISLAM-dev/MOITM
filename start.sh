#!/bin/bash

# MOITM Server Startup Script
# Advanced Cross-Play Modded Minecraft Server

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${ENVIRONMENT:-development}
JAVA_OPTS=${JAVA_OPTS:-"-Xmx6G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"}
MC_VERSION=${MC_VERSION:-1.21}
FABRIC_VERSION=${FABRIC_VERSION:-0.15.11}

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if server is already running
check_running() {
    if pgrep -f "fabric-server-mc" > /dev/null; then
        print_error "Server appears to be already running!"
        read -p "Force start anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        print_warning "Continuing with force start..."
    fi
}

# Function to setup directories
setup_directories() {
    print_status "Setting up directories..."
    
    # Create necessary directories
    mkdir -p logs world mods server/mods server/config
    
    # Create server subdirectories
    mkdir -p server/config/{geyser,floodgate,viafabric}
    
    print_success "Directories created"
}

# Function to copy configuration files
copy_configs() {
    print_status "Copying configuration files for environment: $ENVIRONMENT"
    
    # Copy server properties
    if [ -f "config/$ENVIRONMENT/server/server.properties" ]; then
        cp "config/$ENVIRONMENT/server/server.properties" server/
        print_success "Server properties copied"
    else
        print_warning "Server properties not found for $ENVIRONMENT environment"
    fi
    
    # Copy Geyser config
    if [ -f "config/$ENVIRONMENT/geyser/config.yml" ]; then
        cp "config/$ENVIRONMENT/geyser/config.yml" server/config/geyser/
        print_success "Geyser configuration copied"
    fi
    
    # Copy Floodgate config
    if [ -f "config/$ENVIRONMENT/floodgate/config.yml" ]; then
        cp "config/$ENVIRONMENT/floodgate/config.yml" server/config/floodgate/
        print_success "Floodgate configuration copied"
    fi
    
    # Copy ViaFabric config
    if [ -f "config/$ENVIRONMENT/viafabric/viafabric.yml" ]; then
        cp "config/$ENVIRONMENT/viafabric/viafabric.yml" server/config/viafabric/
        print_success "ViaFabric configuration copied"
    fi
}

# Function to copy mods
copy_mods() {
    print_status "Copying mods..."
    
    # Copy required mods
    if [ -d "mods/required" ]; then
        cp -f mods/required/*.jar server/mods/ 2>/dev/null || true
        print_success "Required mods copied"
    fi
    
    # Copy optional mods
    if [ -d "mods/optional" ]; then
        cp -f mods/optional/*.jar server/mods/ 2>/dev/null || true
        print_success "Optional mods copied"
    fi
    
    # Count mods
    MOD_COUNT=$(find server/mods -name "*.jar" | wc -l)
    print_status "Total mods loaded: $MOD_COUNT"
}

# Function to check Java version
check_java() {
    if ! command -v java &> /dev/null; then
        print_error "Java not found! Please install Java 17 or higher."
        exit 1
    fi
    
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | sed 's/\..*//')
    if [ "$JAVA_VERSION" -lt 17 ]; then
        print_error "Java $JAVA_VERSION found, but Java 17+ is required."
        exit 1
    fi
    
    print_success "Java $JAVA_VERSION found"
}

# Function to check if server jar exists
check_server_jar() {
    SERVER_JAR="server/fabric-server-mc.$MC_VERSION-loader.$FABRIC_VERSION-launcher.0.11.2.jar"
    
    if [ ! -f "$SERVER_JAR" ]; then
        print_error "Server jar not found: $SERVER_JAR"
        print_status "Run ./setup.sh first to download the server"
        exit 1
    fi
    
    print_success "Server jar found: $SERVER_JAR"
}

# Function to accept EULA
accept_eula() {
    if [ ! -f "server/eula.txt" ]; then
        print_status "Creating EULA agreement..."
        echo "# EULA for MOITM Server" > server/eula.txt
        echo "# By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA)." >> server/eula.txt
        echo "eula=true" >> server/eula.txt
        print_success "EULA accepted"
    fi
}

# Function to setup logging
setup_logging() {
    LOG_FILE="logs/server-$(date +%Y%m%d-%H%M%S).log"
    print_status "Logging to: $LOG_FILE"
    
    # Create log directory if it doesn't exist
    mkdir -p logs
    
    # Setup log rotation
    if command -v logrotate &> /dev/null; then
        cat > logs/logrotate.conf << EOF
logs/server-*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    create 644 $(whoami) $(whoami)
}
EOF
    fi
}

# Function to create PID file
create_pid_file() {
    echo $$ > server/server.pid
}

# Function to cleanup on exit
cleanup() {
    print_status "Cleaning up..."
    if [ -f "server/server.pid" ]; then
        rm -f server/server.pid
    fi
}

# Function to handle signals
handle_signal() {
    print_status "Received signal, stopping server gracefully..."
    if [ -f "server/server.pid" ]; then
        kill -TERM $(cat server/server.pid) 2>/dev/null || true
    fi
    cleanup
    exit 0
}

# Function to start the server
start_server() {
    print_status "Starting MOITM Server..."
    print_status "Environment: $ENVIRONMENT"
    print_status "Java Options: $JAVA_OPTS"
    print_status "======================================"
    
    cd server
    
    # Start server with proper logging
    exec java $JAVA_OPTS -jar "fabric-server-mc.$MC_VERSION-loader.$FABRIC_VERSION-launcher.0.11.2.jar" nogui 2>&1 | tee "../$LOG_FILE"
}

# Main function
main() {
    # Set up signal handlers
    trap handle_signal SIGTERM SIGINT
    trap cleanup EXIT
    
    print_status "MOITM Advanced Cross-Play Minecraft Server"
    print_status "=========================================="
    
    # Pre-flight checks
    check_running
    check_java
    
    # Setup
    setup_directories
    copy_configs
    copy_mods
    check_server_jar
    accept_eula
    setup_logging
    create_pid_file
    
    # Start server
    start_server
}

# Run main function
main "$@"