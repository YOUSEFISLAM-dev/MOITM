# MOITM Setup Guide

This guide will walk you through setting up the MOITM Advanced Cross-Play Modded Minecraft Server.

## Prerequisites

### System Requirements

#### Minimum Requirements
- **OS**: Linux (Ubuntu 20.04+, CentOS 8+), Windows 10+, macOS 10.15+
- **Java**: Java 17 or higher
- **RAM**: 4GB available
- **Storage**: 10GB free space
- **Network**: 10Mbps upload/download

#### Recommended Requirements
- **OS**: Ubuntu 22.04 LTS
- **Java**: Java 21
- **RAM**: 8GB+ available
- **Storage**: 50GB+ SSD
- **Network**: 100Mbps+ with low latency

### Network Ports

The following ports must be available:

| Port | Protocol | Purpose |
|------|----------|---------|
| 25565 | TCP | Java Edition clients |
| 19132 | UDP | Bedrock Edition clients |
| 8080 | TCP | Web client interface |
| 25575 | TCP | RCON (optional) |

## Installation Methods

### Method 1: Automated Setup (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUSEFISLAM-dev/MOITM.git
   cd MOITM
   ```

2. **Run the setup script:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Start the server:**
   ```bash
   ./start.sh
   ```

### Method 2: Docker Deployment

1. **Prerequisites:**
   ```bash
   # Install Docker and Docker Compose
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

2. **Deploy with Docker:**
   ```bash
   git clone https://github.com/YOUSEFISLAM-dev/MOITM.git
   cd MOITM
   docker-compose up -d
   ```

3. **Check status:**
   ```bash
   docker-compose ps
   docker-compose logs -f minecraft-server
   ```

### Method 3: Manual Installation

1. **Install Java 21:**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install openjdk-21-jdk
   
   # CentOS/RHEL
   sudo yum install java-21-openjdk-devel
   
   # Verify installation
   java -version
   ```

2. **Download Fabric Server:**
   ```bash
   mkdir moitm-server && cd moitm-server
   wget https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.2/fabric-installer-0.11.2.jar
   java -jar fabric-installer-0.11.2.jar server -mcversion 1.21 -loader 0.15.11 -downloadMinecraft
   ```

3. **Download Required Mods:**
   ```bash
   mkdir mods
   cd mods
   # Download Geyser
   wget https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/fabric
   # Download Floodgate
   wget https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/fabric
   # Download ViaFabric
   wget https://github.com/ViaVersion/ViaFabric/releases/latest/download/ViaFabric-*.jar
   ```

4. **Configure and Start:**
   ```bash
   # Accept EULA
   echo "eula=true" > eula.txt
   
   # Start server
   java -Xmx6G -Xms2G -XX:+UseG1GC -jar fabric-server-*.jar nogui
   ```

## Configuration

### Environment Configuration

Copy the appropriate environment file:

```bash
# Development
cp config/development/.env .env

# Production
cp config/production/.env .env
```

Edit the `.env` file to match your needs:

```bash
# Basic settings
ENVIRONMENT=development
JAVA_OPTS=-Xmx4G -Xms1G
MAX_PLAYERS=50

# Ports (change if needed)
JAVA_PORT=25565
BEDROCK_PORT=19132
WEB_PORT=8080
```

### Mod Configuration

#### Geyser (Bedrock Bridge)
Edit `config/geyser/config.yml`:

```yaml
bedrock:
  address: 0.0.0.0
  port: 19132
  motd1: "MOITM Server"
  motd2: "Cross-Play Enabled"

remote:
  address: 127.0.0.1
  port: 25565
  auth-type: floodgate
```

#### Floodgate (Authentication)
Edit `config/floodgate/config.yml`:

```yaml
username-prefix: "."
player-data:
  enabled: true
  save-data: true
```

#### ViaFabric (Version Compatibility)
Edit `config/viafabric/viafabric.yml`:

```yaml
enabled: true
serverside:
  enabled: true
  min-version: 578  # 1.15.2
  max-version: 767  # 1.21
```

## Network Setup

### Firewall Configuration

#### Ubuntu/Debian (ufw)
```bash
sudo ufw allow 25565/tcp comment "Minecraft Java"
sudo ufw allow 19132/udp comment "Minecraft Bedrock"
sudo ufw allow 8080/tcp comment "Web Client"
sudo ufw enable
```

#### CentOS/RHEL (firewalld)
```bash
sudo firewall-cmd --permanent --add-port=25565/tcp
sudo firewall-cmd --permanent --add-port=19132/udp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

#### Manual iptables
```bash
sudo iptables -A INPUT -p tcp --dport 25565 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 19132 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
```

### Router Port Forwarding

Configure your router to forward these ports to your server:

1. Access your router's admin interface (usually http://192.168.1.1)
2. Navigate to Port Forwarding settings
3. Add rules:
   - **Minecraft Java**: TCP 25565 → Your Server IP
   - **Minecraft Bedrock**: UDP 19132 → Your Server IP
   - **Web Client**: TCP 8080 → Your Server IP

## Service Management

### Systemd Service (Linux)

1. **Install the service:**
   ```bash
   sudo cp minecraft-server.service /etc/systemd/system/
   sudo systemctl daemon-reload
   ```

2. **Enable and start:**
   ```bash
   sudo systemctl enable minecraft-server
   sudo systemctl start minecraft-server
   ```

3. **Manage the service:**
   ```bash
   # Status
   sudo systemctl status minecraft-server
   
   # Logs
   sudo journalctl -u minecraft-server -f
   
   # Stop
   sudo systemctl stop minecraft-server
   
   # Restart
   sudo systemctl restart minecraft-server
   ```

### Windows Service

Use the provided `start.bat` file or install as a Windows service using tools like NSSM.

## Testing

### Connectivity Test

Run the port check script:

```bash
chmod +x scripts/port-check.sh
./scripts/port-check.sh
```

### Client Testing

1. **Java Edition:**
   - Open Minecraft Java Edition
   - Add server: `your-server-ip:25565`
   - Connect and verify cross-play functionality

2. **Bedrock Edition:**
   - Open Minecraft Bedrock Edition
   - Add server: `your-server-ip` port `19132`
   - Connect and verify Java player interaction

3. **Web Client:**
   - Open browser to `http://your-server-ip:8080`
   - Click "Launch Web Client"
   - Verify functionality

## Troubleshooting

### Common Issues

#### "Server won't start"
1. Check Java version: `java -version`
2. Verify EULA acceptance: `cat server/eula.txt`
3. Check logs: `tail -f logs/latest.log`

#### "Can't connect from Bedrock"
1. Verify Geyser is running: Check server logs
2. Check firewall: UDP port 19132
3. Verify Floodgate configuration

#### "Version incompatibility"
1. Check ViaFabric logs
2. Verify supported versions in config
3. Update client or server as needed

#### "Performance issues"
1. Increase Java memory: Edit `JAVA_OPTS`
2. Reduce view distance: Edit `server.properties`
3. Remove unnecessary mods

### Getting Help

1. **Check logs:** Always check server logs first
2. **Discord/Forums:** Join the community for support
3. **GitHub Issues:** Report bugs with detailed information
4. **Documentation:** Review the troubleshooting guide

## Next Steps

- [Configuration Reference](configuration.md)
- [Mod Development Guide](mod-development.md)
- [Advanced Deployment](deployment.md)
- [Performance Tuning](performance.md)