# MOITM Troubleshooting Guide

This guide helps you diagnose and fix common issues with the MOITM Advanced Cross-Play Minecraft Server.

## Quick Diagnostics

### Run the Test Suite

Before troubleshooting manually, run the automated test suite:

```bash
# Run comprehensive tests
./scripts/test-suite.sh

# Check connectivity only
./scripts/port-check.sh

# Check server status
./scripts/server-manager.sh status
```

## Common Issues

### 1. Server Won't Start

#### Symptoms
- Server fails to start
- Immediate crash on startup
- "Could not reserve enough space for object heap" error

#### Diagnosis
```bash
# Check Java version
java -version

# Check available memory
free -h

# Check server logs
tail -f logs/latest.log

# Test basic configuration
./scripts/test-suite.sh --java-environment
```

#### Solutions

**Java Version Issues:**
```bash
# Install Java 17 or higher
# Ubuntu/Debian
sudo apt update && sudo apt install openjdk-21-jdk

# CentOS/RHEL
sudo yum install java-21-openjdk-devel

# Verify installation
java -version
```

**Memory Issues:**
```bash
# Reduce memory allocation in start.sh or environment
export JAVA_OPTS="-Xmx2G -Xms1G -XX:+UseG1GC"

# Or edit the configuration
vim config/development/.env
```

**Missing Files:**
```bash
# Run setup script to download required files
./setup.sh

# Check if Fabric server exists
ls -la server/fabric-server-*.jar
```

### 2. Cross-Play Not Working

#### Symptoms
- Java Edition clients can connect, Bedrock cannot
- Bedrock clients can connect, Java cannot
- Both can connect but cannot see each other

#### Diagnosis
```bash
# Check Geyser status in server logs
grep -i geyser logs/latest.log

# Test ports
nc -z localhost 25565  # Java port
nc -u -z localhost 19132  # Bedrock port

# Check Geyser configuration
cat config/development/geyser/config.yml
```

#### Solutions

**Geyser Not Loading:**
```bash
# Check if Geyser mod is present
ls -la server/mods/*geyser*

# Download Geyser if missing
cd mods/required
wget https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/fabric
```

**Port Issues:**
```bash
# Check firewall
sudo ufw status
sudo firewall-cmd --list-ports

# Open Bedrock port (UDP)
sudo ufw allow 19132/udp
sudo firewall-cmd --permanent --add-port=19132/udp
sudo firewall-cmd --reload
```

**Authentication Issues:**
```bash
# Verify online-mode is disabled
grep "online-mode" server/server.properties
# Should show: online-mode=false

# Check Floodgate configuration
cat config/development/floodgate/config.yml
```

### 3. Version Compatibility Issues

#### Symptoms
- "Incompatible client version" error
- Clients on different versions cannot connect
- ViaFabric errors in logs

#### Diagnosis
```bash
# Check ViaFabric logs
grep -i via logs/latest.log

# Check supported versions
cat config/development/viafabric/viafabric.yml

# Test with specific client version
./scripts/test-suite.sh --version-check
```

#### Solutions

**Update ViaFabric:**
```bash
# Download latest ViaFabric
cd mods/required
rm -f ViaFabric-*.jar
wget https://github.com/ViaVersion/ViaFabric/releases/latest/download/ViaFabric-0.4.13+32-main.jar
```

**Expand Version Support:**
```yaml
# Edit config/development/viafabric/viafabric.yml
serverside:
  min-version: 578  # 1.15.2 (expand if needed)
  max-version: 767  # 1.21 (update for newer versions)
```

### 4. Performance Issues

#### Symptoms
- Server lag or TPS drops
- High CPU/memory usage
- Players experiencing lag

#### Diagnosis
```bash
# Check server performance
./scripts/server-manager.sh stats

# Monitor resource usage
top -p $(pgrep -f fabric-server)
htop

# Check JVM garbage collection
grep -i gc logs/latest.log
```

#### Solutions

**Memory Optimization:**
```bash
# Increase heap size
export JAVA_OPTS="-Xmx8G -Xms4G -XX:+UseG1GC"

# Enable G1GC optimizations
export JAVA_OPTS="-Xmx8G -Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200"
```

**Server Settings:**
```properties
# Edit server.properties
view-distance=8        # Reduce from default 10
simulation-distance=6  # Reduce simulation load
max-players=50         # Limit concurrent players
```

**Remove Unnecessary Mods:**
```bash
# Move optional mods to disable them
mv mods/optional/* mods/disabled/
```

### 5. Web Client Issues

#### Symptoms
- Web client page doesn't load
- "Server offline" message when server is running
- JavaScript errors in browser console

#### Diagnosis
```bash
# Test web client port
curl -I http://localhost:8080

# Check web client files
ls -la web-client/

# Test server status endpoint
curl http://localhost:8080/api/status
```

#### Solutions

**Web Server Not Running:**
```bash
# Start web server component
cd web-client
python3 -m http.server 8080

# Or use nginx
sudo apt install nginx
sudo cp config/nginx/nginx.conf /etc/nginx/sites-available/moitm
sudo ln -s /etc/nginx/sites-available/moitm /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

**CORS Issues:**
```javascript
// Add CORS headers to web client
// Edit web-client/client.js
fetch('/api/status', {
  mode: 'cors',
  headers: {
    'Access-Control-Allow-Origin': '*'
  }
})
```

### 6. Mod Loading Issues

#### Symptoms
- Mods not loading
- "Mod dependency not found" errors
- Server crashes with mod-related errors

#### Diagnosis
```bash
# Check mod directory
ls -la server/mods/

# Check Fabric loader logs
grep -i fabric logs/latest.log

# Verify mod compatibility
./scripts/test-suite.sh --mod-loading
```

#### Solutions

**Missing Dependencies:**
```bash
# Install Fabric API (required for most mods)
cd server/mods
wget https://github.com/FabricMC/fabric/releases/latest/download/fabric-api-*.jar
```

**Incompatible Mod Versions:**
```bash
# Check mod versions against Minecraft version
# Remove incompatible mods
mv server/mods/incompatible-mod.jar server/mods/disabled/

# Download compatible versions
# Check mod pages for version compatibility
```

### 7. Database Issues (Floodgate)

#### Symptoms
- "Database connection failed" errors
- Linked accounts not working
- Floodgate authentication errors

#### Diagnosis
```bash
# Check Floodgate logs
grep -i floodgate logs/latest.log

# Test database connection
mysql -h localhost -u root -p -e "SHOW DATABASES;"

# Check Floodgate config
cat config/production/floodgate/config.yml
```

#### Solutions

**H2 Database (Development):**
```yaml
# Use H2 for development
database:
  type: h2
```

**MySQL Setup (Production):**
```bash
# Install MySQL
sudo apt install mysql-server

# Create database and user
mysql -u root -p << EOF
CREATE DATABASE floodgate_prod;
CREATE USER 'floodgate_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON floodgate_prod.* TO 'floodgate_user'@'localhost';
FLUSH PRIVILEGES;
EOF
```

### 8. Docker Issues

#### Symptoms
- Docker containers won't start
- Port conflicts
- Volume mount issues

#### Diagnosis
```bash
# Check Docker status
docker-compose ps

# View container logs
docker-compose logs minecraft-server

# Check port usage
docker port moitm-server
```

#### Solutions

**Port Conflicts:**
```yaml
# Edit docker-compose.yml to use different ports
services:
  minecraft-server:
    ports:
      - "25566:25565"  # Use different external port
      - "19133:19132/udp"
```

**Permission Issues:**
```bash
# Fix volume permissions
sudo chown -R 1000:1000 world logs

# Or use Docker user mapping
docker-compose exec minecraft-server chown -R minecraft:minecraft /opt/minecraft
```

**Container Startup Issues:**
```bash
# Rebuild container
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 9. Network/Connectivity Issues

#### Symptoms
- Players cannot connect from outside network
- "Connection timed out" errors
- Works locally but not remotely

#### Diagnosis
```bash
# Test external connectivity
./scripts/port-check.sh --host your-public-ip

# Check firewall rules
sudo ufw status verbose
sudo iptables -L

# Test from external network
nmap -p 25565,19132 your-public-ip
```

#### Solutions

**Router Configuration:**
```
1. Access router admin panel (usually 192.168.1.1)
2. Navigate to Port Forwarding
3. Add rules:
   - TCP 25565 → Your Server IP
   - UDP 19132 → Your Server IP
   - TCP 8080 → Your Server IP (for web client)
```

**Firewall Configuration:**
```bash
# Open required ports
sudo ufw allow 25565/tcp
sudo ufw allow 19132/udp
sudo ufw allow 8080/tcp

# Or disable firewall temporarily for testing
sudo ufw disable
```

**ISP/VPS Issues:**
```bash
# Check if ISP blocks ports
telnet your-isp-gateway 25565

# For VPS, check provider firewall/security groups
# Common with AWS, GCP, Azure, etc.
```

### 10. SSL/HTTPS Issues

#### Symptoms
- HTTPS not working for web client
- Certificate errors
- Mixed content warnings

#### Diagnosis
```bash
# Check SSL certificate
openssl x509 -in /path/to/cert.pem -text -noout

# Test HTTPS connection
curl -k https://your-domain:443

# Check nginx SSL config
nginx -t
```

#### Solutions

**Generate Self-Signed Certificate:**
```bash
# For development/testing
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

**Let's Encrypt Certificate:**
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## Diagnostic Commands

### Server Information
```bash
# Java version and path
which java && java -version

# Server process information
ps aux | grep fabric-server

# Memory usage
free -h && df -h

# Network connections
netstat -tulnp | grep -E '(25565|19132|8080)'
```

### Log Analysis
```bash
# Recent errors
tail -100 logs/latest.log | grep -i error

# Geyser status
grep -i geyser logs/latest.log | tail -20

# Player connections
grep -i "joined\|left" logs/latest.log | tail -20

# Performance issues
grep -i "can't keep up" logs/latest.log
```

### Configuration Validation
```bash
# Validate YAML files
python3 -c "import yaml; yaml.safe_load(open('config/development/geyser/config.yml'))"

# Check server properties syntax
grep -v '^#' server/server.properties | grep -v '^$'

# Validate JSON (if any)
python3 -m json.tool config.json
```

## Performance Monitoring

### Real-time Monitoring
```bash
# System resources
htop

# Network activity
iftop

# Disk I/O
iotop

# Java GC activity
jstat -gc $(pgrep -f fabric-server) 1s
```

### Log-based Monitoring
```bash
# TPS monitoring
grep "Can't keep up" logs/latest.log

# Memory warnings
grep -i "memory" logs/latest.log

# Connection patterns
grep "logged in with entity id" logs/latest.log | wc -l
```

## Getting Help

### Information to Collect

When seeking help, provide:

1. **System Information:**
   ```bash
   uname -a
   java -version
   cat /etc/os-release
   ```

2. **Server Configuration:**
   ```bash
   cat config/development/.env
   head -20 config/development/server/server.properties
   ```

3. **Error Logs:**
   ```bash
   tail -100 logs/latest.log
   grep -i error logs/latest.log | tail -20
   ```

4. **Test Results:**
   ```bash
   ./scripts/test-suite.sh > test-results.txt
   ```

### Community Resources

- **GitHub Issues**: Report bugs and feature requests
- **Discord/Forums**: Community support and discussions
- **Documentation**: Check the docs/ directory for guides
- **Mod Communities**: Geyser, Floodgate, ViaFabric communities

### Professional Support

For production environments, consider:
- Managed Minecraft hosting services
- Professional server administration
- Custom development services
- Enterprise support contracts

## Prevention Tips

### Regular Maintenance
```bash
# Weekly tasks
./scripts/server-manager.sh backup
./scripts/server-manager.sh clean-logs
./scripts/test-suite.sh

# Monthly tasks
# Check for mod updates
# Review server performance
# Update documentation
```

### Monitoring Setup
```bash
# Set up automated monitoring
# Install monitoring tools (Prometheus, Grafana)
# Configure alerting for critical issues
# Regular backup verification
```

### Best Practices
- Keep regular backups
- Monitor server performance
- Update mods and server regularly
- Document configuration changes
- Test in development before production
- Monitor security advisories