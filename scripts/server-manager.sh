#!/bin/bash

# MOITM Server Management Script
# Handles backup, monitoring, and maintenance tasks

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_DIR/backups}"
LOG_DIR="${LOG_DIR:-$PROJECT_DIR/logs}"
WORLD_DIR="${WORLD_DIR:-$PROJECT_DIR/server/world}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Function to create world backup
backup_world() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/world_backup_$timestamp.tar.gz"
    
    print_status "Creating world backup..."
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$WORLD_DIR" ]; then
        # Create compressed backup
        tar -czf "$backup_file" -C "$(dirname "$WORLD_DIR")" "$(basename "$WORLD_DIR")"
        
        if [ $? -eq 0 ]; then
            local size=$(du -h "$backup_file" | cut -f1)
            print_success "World backup created: $backup_file ($size)"
            
            # Clean old backups (keep last 10)
            cleanup_old_backups
        else
            print_error "Failed to create world backup"
            return 1
        fi
    else
        print_error "World directory not found: $WORLD_DIR"
        return 1
    fi
}

# Function to clean old backups
cleanup_old_backups() {
    local backup_count=$(ls -1 "$BACKUP_DIR"/world_backup_*.tar.gz 2>/dev/null | wc -l)
    
    if [ "$backup_count" -gt 10 ]; then
        print_status "Cleaning old backups (keeping last 10)..."
        ls -1t "$BACKUP_DIR"/world_backup_*.tar.gz | tail -n +11 | xargs rm -f
        print_success "Old backups cleaned"
    fi
}

# Function to restore from backup
restore_world() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        print_error "Usage: $0 restore <backup_file>"
        list_backups
        return 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        return 1
    fi
    
    print_warning "This will replace the current world!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restore cancelled"
        return 0
    fi
    
    print_status "Stopping server..."
    stop_server
    
    print_status "Backing up current world..."
    if [ -d "$WORLD_DIR" ]; then
        mv "$WORLD_DIR" "${WORLD_DIR}.pre-restore.$(date +%s)"
    fi
    
    print_status "Restoring world from backup..."
    tar -xzf "$backup_file" -C "$(dirname "$WORLD_DIR")"
    
    if [ $? -eq 0 ]; then
        print_success "World restored from: $backup_file"
        print_status "You can now start the server"
    else
        print_error "Failed to restore world"
        return 1
    fi
}

# Function to list available backups
list_backups() {
    print_status "Available backups:"
    if [ -d "$BACKUP_DIR" ]; then
        ls -lht "$BACKUP_DIR"/world_backup_*.tar.gz 2>/dev/null | while read -r line; do
            echo "  $line"
        done
    else
        print_warning "No backup directory found"
    fi
}

# Function to check server status
check_server_status() {
    if pgrep -f "fabric-server-mc" > /dev/null; then
        print_success "Server is running"
        
        # Get process info
        local pid=$(pgrep -f "fabric-server-mc")
        local memory=$(ps -p $pid -o rss= 2>/dev/null | awk '{print int($1/1024)" MB"}')
        local cpu=$(ps -p $pid -o %cpu= 2>/dev/null | sed 's/^ *//')
        
        print_status "PID: $pid"
        print_status "Memory: $memory"
        print_status "CPU: $cpu%"
        
        return 0
    else
        print_warning "Server is not running"
        return 1
    fi
}

# Function to stop server gracefully
stop_server() {
    if pgrep -f "fabric-server-mc" > /dev/null; then
        print_status "Stopping server gracefully..."
        pkill -SIGTERM -f "fabric-server-mc"
        
        # Wait for graceful shutdown
        local count=0
        while pgrep -f "fabric-server-mc" > /dev/null && [ $count -lt 30 ]; do
            sleep 1
            ((count++))
        done
        
        if pgrep -f "fabric-server-mc" > /dev/null; then
            print_warning "Server did not stop gracefully, forcing shutdown..."
            pkill -SIGKILL -f "fabric-server-mc"
        fi
        
        print_success "Server stopped"
    else
        print_status "Server is not running"
    fi
}

# Function to restart server
restart_server() {
    stop_server
    sleep 2
    
    print_status "Starting server..."
    cd "$PROJECT_DIR"
    nohup ./start.sh > /dev/null 2>&1 &
    
    # Wait a moment and check if it started
    sleep 5
    if check_server_status > /dev/null 2>&1; then
        print_success "Server restarted successfully"
    else
        print_error "Failed to restart server"
        return 1
    fi
}

# Function to monitor server logs
monitor_logs() {
    local log_file="$LOG_DIR/latest.log"
    
    if [ -f "$log_file" ]; then
        print_status "Monitoring server logs (Ctrl+C to exit)..."
        tail -f "$log_file"
    else
        print_error "Log file not found: $log_file"
        return 1
    fi
}

# Function to get server statistics
show_stats() {
    print_status "MOITM Server Statistics"
    echo "================================"
    
    # Server uptime
    if pgrep -f "fabric-server-mc" > /dev/null; then
        local pid=$(pgrep -f "fabric-server-mc")
        local start_time=$(ps -o lstart= -p $pid 2>/dev/null)
        print_status "Server started: $start_time"
    fi
    
    # World size
    if [ -d "$WORLD_DIR" ]; then
        local world_size=$(du -sh "$WORLD_DIR" 2>/dev/null | cut -f1)
        print_status "World size: $world_size"
    fi
    
    # Backup count
    if [ -d "$BACKUP_DIR" ]; then
        local backup_count=$(ls -1 "$BACKUP_DIR"/world_backup_*.tar.gz 2>/dev/null | wc -l)
        print_status "Available backups: $backup_count"
    fi
    
    # Log file size
    if [ -f "$LOG_DIR/latest.log" ]; then
        local log_size=$(du -sh "$LOG_DIR/latest.log" 2>/dev/null | cut -f1)
        print_status "Current log size: $log_size"
    fi
    
    # Port status
    print_status "Port status:"
    for port in 25565 19132 8080; do
        if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
            echo "  Port $port: OPEN"
        else
            echo "  Port $port: CLOSED"
        fi
    done
}

# Function to clean logs
clean_logs() {
    print_status "Cleaning old log files..."
    
    # Compress logs older than 7 days
    find "$LOG_DIR" -name "*.log" -type f -mtime +7 -exec gzip {} \;
    
    # Remove compressed logs older than 30 days
    find "$LOG_DIR" -name "*.log.gz" -type f -mtime +30 -delete
    
    print_success "Log cleanup completed"
}

# Function to update server
update_server() {
    print_status "Checking for server updates..."
    
    # This is a placeholder for update functionality
    # In a real implementation, this would:
    # 1. Check for new Fabric loader versions
    # 2. Check for mod updates
    # 3. Download and install updates
    # 4. Restart server
    
    print_warning "Update functionality not yet implemented"
    print_status "Please check manually for:"
    print_status "- Fabric loader updates"
    print_status "- Mod updates (Geyser, Floodgate, ViaFabric)"
    print_status "- Minecraft version updates"
}

# Function to show help
show_help() {
    echo "MOITM Server Management Script"
    echo
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  status       Check server status"
    echo "  start        Start the server"
    echo "  stop         Stop the server"
    echo "  restart      Restart the server"
    echo "  backup       Create world backup"
    echo "  restore      Restore world from backup"
    echo "  list-backups List available backups"
    echo "  logs         Monitor server logs"
    echo "  stats        Show server statistics"
    echo "  clean-logs   Clean old log files"
    echo "  update       Check for updates"
    echo "  help         Show this help"
    echo
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 backup"
    echo "  $0 restore /path/to/backup.tar.gz"
    echo "  $0 logs"
}

# Main command dispatcher
main() {
    case "${1:-help}" in
        status)
            check_server_status
            ;;
        start)
            cd "$PROJECT_DIR"
            ./start.sh
            ;;
        stop)
            stop_server
            ;;
        restart)
            restart_server
            ;;
        backup)
            backup_world
            ;;
        restore)
            restore_world "$2"
            ;;
        list-backups)
            list_backups
            ;;
        logs)
            monitor_logs
            ;;
        stats)
            show_stats
            ;;
        clean-logs)
            clean_logs
            ;;
        update)
            update_server
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"