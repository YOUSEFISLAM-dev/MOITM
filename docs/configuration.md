# MOITM Configuration Reference

This document provides detailed information about configuring the MOITM Advanced Cross-Play Modded Minecraft Server.

## Configuration Structure

```
config/
├── development/          # Development environment
├── testing/             # Testing environment  
├── production/          # Production environment
│   ├── geyser/
│   │   └── config.yml
│   ├── floodgate/
│   │   └── config.yml
│   ├── viafabric/
│   │   └── viafabric.yml
│   ├── server/
│   │   └── server.properties
│   └── .env             # Environment variables
└── nginx/               # Web proxy configuration
```

## Environment Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ENVIRONMENT` | development | Server environment (development/testing/production) |
| `MC_VERSION` | 1.21 | Minecraft version |
| `FABRIC_VERSION` | 0.15.11 | Fabric loader version |
| `JAVA_OPTS` | -Xmx4G -Xms1G | JVM options |
| `JAVA_PORT` | 25565 | Java Edition port |
| `BEDROCK_PORT` | 19132 | Bedrock Edition port |
| `WEB_PORT` | 8080 | Web client port |
| `RCON_PORT` | 25575 | RCON port |
| `MAX_PLAYERS` | 100 | Maximum players |
| `VIEW_DISTANCE` | 10 | Server view distance |
| `ONLINE_MODE` | false | Authentication mode |

### Development Environment

```bash
# config/development/.env
ENVIRONMENT=development
JAVA_OPTS=-Xmx4G -Xms1G -XX:+UseG1GC
MAX_PLAYERS=20
VIEW_DISTANCE=8
DEBUG_MODE=true
WHITELIST_ENABLED=false
```

### Production Environment

```bash
# config/production/.env
ENVIRONMENT=production
JAVA_OPTS=-Xmx8G -Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled
MAX_PLAYERS=100
VIEW_DISTANCE=12
DEBUG_MODE=false
WHITELIST_ENABLED=true
SSL_ENABLED=true
BACKUP_ENABLED=true
```

## Server Properties Configuration

### Basic Settings

| Property | Development | Production | Description |
|----------|-------------|------------|-------------|
| `motd` | MOITM Dev Server | MOITM Production | Server description |
| `max-players` | 20 | 100 | Maximum concurrent players |
| `difficulty` | normal | hard | Game difficulty |
| `gamemode` | survival | survival | Default game mode |
| `online-mode` | false | false | Authentication (must be false for cross-play) |
| `white-list` | false | true | Enable whitelist |

### Performance Settings

| Property | Development | Production | Description |
|----------|-------------|------------|-------------|
| `view-distance` | 8 | 12 | Client view distance |
| `simulation-distance` | 8 | 10 | Server simulation distance |
| `max-tick-time` | 60000 | 60000 | Maximum tick time (ms) |
| `network-compression-threshold` | 256 | 512 | Network compression |

### Security Settings

| Property | Development | Production | Description |
|----------|-------------|------------|-------------|
| `enforce-whitelist` | false | true | Enforce whitelist |
| `enable-rcon` | false | true | Enable RCON |
| `rcon.password` | "" | ${RCON_PASSWORD} | RCON password |
| `hide-online-players` | false | true | Hide player list |

## Geyser Configuration

### Network Settings

```yaml
# config/geyser/config.yml
bedrock:
  address: 0.0.0.0          # Listen on all interfaces
  port: 19132               # Bedrock port
  compression-level: 6      # Compression (1-9, higher = more CPU)
  
remote:
  address: 127.0.0.1        # Java server address
  port: 25565               # Java server port
  auth-type: floodgate      # Authentication type
```

### Performance Tuning

| Setting | Development | Production | Description |
|---------|-------------|------------|-------------|
| `compression-level` | 6 | 8 | Network compression |
| `general-thread-pool` | 32 | 64 | Thread pool size |
| `cache-images` | 0 | 7 | Image cache duration (days) |
| `allow-custom-skulls` | true | false | Custom skull support |

### Cross-Platform Features

```yaml
# Bedrock-specific settings
show-cooldown: true              # Show attack cooldown
show-coordinates: true           # Show coordinates
allow-third-party-capes: true    # Allow custom capes
emote-offhand-workaround: disabled # Emote handling
```

## Floodgate Configuration

### Authentication Settings

```yaml
# config/floodgate/config.yml
username-prefix: "."             # Bedrock username prefix
replace-spaces: true             # Replace spaces in usernames

player-data:
  enabled: true                  # Save player data
  save-data: true               # Persist across sessions
```

### Database Configuration

```yaml
# Development (H2 database)
database:
  type: h2
  
# Production (MySQL)
database:
  type: mysql
  host: ${DB_HOST}
  port: ${DB_PORT}
  database: ${DB_NAME}
  username: ${DB_USER}
  password: ${DB_PASSWORD}
```

### Security Settings

```yaml
security:
  enable-ip-forwarding: true     # For proxy setups
  allowed-proxies:               # Trusted proxy IPs
    - "127.0.0.1"
    - "::1"
```

## ViaFabric Configuration

### Version Support

```yaml
# config/viafabric/viafabric.yml
enabled: true
protocol-version: -1             # Use server version

translation:
  enabled: true
  supported-versions:
    - 578  # 1.15.2
    - 735  # 1.16.1
    - 751  # 1.16.4/1.16.5
    - 757  # 1.18/1.18.1
    - 763  # 1.20/1.20.1
    - 767  # 1.21
```

### Performance Settings

```yaml
performance:
  thread-pool-size: 4            # Development
  thread-pool-size: 8            # Production
  async-translation: true
  cache-packets: true
  max-cache-size: 1000          # Development
  max-cache-size: 2000          # Production
```

### Client Settings

```yaml
clientside:
  enabled: true
  hide-button: false            # Development
  hide-button: true             # Production
  protocol-hack: true
```

## Web Client Configuration

### Basic Settings

```javascript
// web-client/config.js
const config = {
  serverHost: window.location.hostname,
  javaPort: 25565,
  bedrockPort: 19132,
  webPort: 8080,
  statusEndpoint: '/api/status'
};
```

### Performance Settings

```javascript
// Performance configuration
const performanceConfig = {
  maxFPS: 60,                    # Maximum FPS
  renderDistance: 8,             # Render distance
  enableShadows: false,          # Shadow rendering
  enableReflections: false,      # Water reflections
  particleDensity: 0.5          # Particle density
};
```

## Docker Configuration

### Environment Variables

```yaml
# docker-compose.yml
services:
  minecraft-server:
    environment:
      - ENVIRONMENT=${ENVIRONMENT:-production}
      - JAVA_OPTS=${JAVA_OPTS}
      - MC_VERSION=${MC_VERSION:-1.21}
      - TZ=${TZ:-UTC}
```

### Resource Limits

```yaml
# Resource configuration
services:
  minecraft-server:
    mem_limit: ${MEM_LIMIT:-8g}
    mem_reservation: ${MEM_RESERVATION:-2g}
    cpus: ${CPU_LIMIT:-4.0}
```

### Volume Mounts

```yaml
volumes:
  # Persistent data
  - minecraft_world:/opt/minecraft/world
  - minecraft_logs:/opt/minecraft/logs
  
  # Configuration (read-only)
  - ./config:/opt/minecraft/config:ro
  - ./mods/optional:/opt/minecraft/mods/optional:ro
```

## Network Configuration

### Port Configuration

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| Java Edition | 25565 | TCP | Primary game port |
| Bedrock Edition | 19132 | UDP | Cross-play port |
| Web Client | 8080 | TCP | Browser access |
| RCON | 25575 | TCP | Remote console |
| HTTP | 80 | TCP | Web interface |
| HTTPS | 443 | TCP | Secure web interface |
| Monitoring | 9090 | TCP | Prometheus metrics |

### Firewall Rules

```bash
# UFW (Ubuntu/Debian)
ufw allow 25565/tcp comment "Minecraft Java"
ufw allow 19132/udp comment "Minecraft Bedrock"
ufw allow 8080/tcp comment "Web Client"
ufw allow 25575/tcp comment "RCON"

# firewalld (CentOS/RHEL)
firewall-cmd --permanent --add-port=25565/tcp
firewall-cmd --permanent --add-port=19132/udp
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload
```

### Nginx Proxy Configuration

```nginx
# config/nginx/nginx.conf
upstream minecraft_web {
    server minecraft-server:8080;
}

server {
    listen 80;
    server_name minecraft.yourdomain.com;
    
    location / {
        proxy_pass http://minecraft_web;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## JVM Optimization

### Memory Settings

```bash
# Development
JAVA_OPTS="-Xmx4G -Xms1G -XX:+UseG1GC"

# Production
JAVA_OPTS="-Xmx8G -Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200"
```

### Garbage Collection

```bash
# G1GC optimizations
-XX:+UseG1GC
-XX:+ParallelRefProcEnabled
-XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions
-XX:+DisableExplicitGC
-XX:+AlwaysPreTouch
-XX:G1NewSizePercent=30
-XX:G1MaxNewSizePercent=40
-XX:G1HeapRegionSize=8M
-XX:G1ReservePercent=20
-XX:G1HeapWastePercent=5
```

### Performance Monitoring

```bash
# JVM monitoring flags
-XX:+UnlockDiagnosticVMOptions
-XX:+DebugNonSafepoints
-XX:+LogGCApplicationStoppedTime
-Xloggc:logs/gc.log
-XX:+UseGCLogFileRotation
-XX:NumberOfGCLogFiles=5
-XX:GCLogFileSize=3M
```

## Security Configuration

### Authentication

```yaml
# Whitelist configuration
white-list=true
enforce-whitelist=true

# Player authentication
online-mode=false              # Required for cross-play
auth-type=floodgate           # Floodgate handles auth
```

### Access Control

```yaml
# RCON security
enable-rcon=true
rcon.password=${RCON_PASSWORD}
rcon.port=25575

# Command permissions
op-permission-level=4
function-permission-level=2
enable-command-block=false     # Production security
```

### Network Security

```yaml
# Rate limiting
rate-limit=300                 # Connections per IP

# Proxy protection
prevent-proxy-connections=false # Allow proxy connections
enable-proxy-protocol=true     # For load balancer setup
```

## Monitoring Configuration

### Prometheus Metrics

```yaml
# config/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'minecraft-server'
    static_configs:
      - targets: ['minecraft-server:8080']
    metrics_path: '/metrics'
```

### Health Checks

```yaml
# Docker health check
healthcheck:
  test: ["CMD", "netstat", "-an", "|", "grep", ":25565"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 120s
```

## Backup Configuration

### Automated Backups

```bash
# Backup schedule (crontab)
0 */6 * * * /opt/minecraft/MOITM/scripts/server-manager.sh backup

# Backup retention
BACKUP_RETENTION=30d           # Keep backups for 30 days
BACKUP_COMPRESS=true           # Compress backups
```

### Backup Locations

```bash
# Local backups
BACKUP_DIR=/opt/minecraft/MOITM/backups

# Remote backups (optional)
REMOTE_BACKUP_HOST=backup.server.com
REMOTE_BACKUP_PATH=/backups/minecraft
```

## Performance Tuning

### Server Optimization

| Setting | Low-End | High-End | Description |
|---------|---------|----------|-------------|
| `view-distance` | 6 | 16 | Player view distance |
| `simulation-distance` | 6 | 12 | Server simulation range |
| `max-players` | 20 | 200 | Maximum concurrent players |
| `entity-broadcast-range-percentage` | 50 | 100 | Entity sync range |

### Memory Allocation

```bash
# Server size recommendations
# Small (1-20 players): 4GB RAM
JAVA_OPTS="-Xmx3G -Xms1G"

# Medium (20-50 players): 8GB RAM  
JAVA_OPTS="-Xmx6G -Xms2G"

# Large (50+ players): 16GB+ RAM
JAVA_OPTS="-Xmx12G -Xms4G"
```

### Network Optimization

```properties
# server.properties optimizations
network-compression-threshold=256    # Lower for fast networks
max-tick-time=60000                 # Prevent timeout kicks
use-native-transport=true           # Use native networking
```

## Troubleshooting

### Common Configuration Issues

1. **Cross-play not working**
   - Verify `online-mode=false` in server.properties
   - Check Geyser/Floodgate configuration
   - Ensure UDP port 19132 is open

2. **Version compatibility issues**
   - Check ViaFabric supported versions
   - Verify protocol version settings
   - Update ViaFabric if needed

3. **Performance problems**
   - Increase JVM memory allocation
   - Reduce view/simulation distance
   - Check for resource-intensive mods

4. **Web client not loading**
   - Verify web client port is accessible
   - Check nginx proxy configuration
   - Ensure WebAssembly support in browser

### Configuration Validation

Use the test suite to validate configuration:

```bash
# Run configuration tests
./scripts/test-suite.sh

# Check specific components
./scripts/port-check.sh
./scripts/server-manager.sh status
```

## Configuration Examples

### Small Development Server

```bash
# 4GB RAM, 1-10 players
JAVA_OPTS="-Xmx3G -Xms1G -XX:+UseG1GC"
MAX_PLAYERS=10
VIEW_DISTANCE=6
SIMULATION_DISTANCE=6
WHITELIST_ENABLED=false
DEBUG_MODE=true
```

### Large Production Server

```bash
# 16GB RAM, 50-100 players
JAVA_OPTS="-Xmx12G -Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled"
MAX_PLAYERS=100
VIEW_DISTANCE=12
SIMULATION_DISTANCE=10
WHITELIST_ENABLED=true
DEBUG_MODE=false
SSL_ENABLED=true
BACKUP_ENABLED=true
MONITORING_ENABLED=true
```