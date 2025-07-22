# Minecraft Fabric 1.21.7 Server Setup

A complete Minecraft server setup using **Fabric 1.21.7** with cross-platform support for both **Java Edition** and **Bedrock Edition** players.

## 🚀 Quick Start

### Prerequisites
- **Java 21 or higher** ([Download here](https://adoptium.net/))
- **Minecraft 1.21.7** compatible
- **4GB+ RAM recommended** (2GB minimum)

### 1. Download Server Files
1. Download the [Fabric Server Launcher](https://fabricmc.net/use/server/) for Minecraft 1.21.7
2. Place `fabric-server-launcher.jar` in this directory
3. Download required mods (see [MODS_REQUIRED.md](MODS_REQUIRED.md))

### 2. Install Mods
Place all required `.jar` files in the `mods/` folder:
- **Core**: fabric-api, yacl, resourceful-lib
- **Gameplay**: advanced-netherite
- **Cross-platform**: Geyser-Fabric, Floodgate-Fabric, hydraulic-fabric
- **Version support**: ViaVersion, ViaBackwards, ViaFabric

### 3. First Run
**Linux/macOS**:
```bash
chmod +x start.sh
./start.sh
```

**Windows**:
```cmd
run.bat
```

### 4. Accept EULA
1. The server will stop and create `eula.txt`
2. Edit `eula.txt` and change `eula=false` to `eula=true`
3. Restart the server

## 📁 File Structure

```
minecraft-server/
├── mods/                    # Fabric mods go here
├── config/                  # Mod configurations
│   ├── Geyser-Fabric/
│   │   └── config.yml      # Geyser configuration
│   └── floodgate/
│       └── config.yml      # Floodgate configuration
├── server.properties       # Server settings
├── start.sh                # Linux/macOS launch script
├── run.bat                 # Windows launch script
├── MODS_REQUIRED.md        # Mod download instructions
└── README.md               # This file
```

## 🌐 Network Configuration

### Java Edition (Port 25565)
- **Default port**: 25565 (TCP)
- **Protocol**: Java Edition clients
- **Authentication**: Online mode (can be changed to offline)

### Bedrock Edition (Port 19132)
- **Default port**: 19132 (UDP)
- **Protocol**: Bedrock Edition clients (PE, Win10, Console)
- **Authentication**: Via Floodgate (Xbox Live bypass)

### Firewall Configuration

**For local servers**:
```bash
# Linux (ufw)
sudo ufw allow 25565/tcp    # Java Edition
sudo ufw allow 19132/udp    # Bedrock Edition

# Windows Firewall
# Add inbound rules for ports 25565 (TCP) and 19132 (UDP)
```

**For VPS/Cloud servers**:
- Configure security groups/firewall to allow:
  - Port 25565 (TCP) - Java Edition
  - Port 19132 (UDP) - Bedrock Edition

## ⚙️ Configuration

### Server Settings (server.properties)
Key settings for cross-platform compatibility:
```properties
server-port=25565
online-mode=true              # Set to false for offline mode
motd=A Minecraft Server with Fabric 1.21.7 and Bedrock Support!
max-players=20
difficulty=normal
gamemode=survival
```

### Geyser Configuration
Located in `config/Geyser-Fabric/config.yml`:
- **Bedrock port**: 19132
- **Authentication**: Floodgate
- **MOTD passthrough**: Enabled

### Floodgate Configuration
Located in `config/floodgate/config.yml`:
- **Username prefix**: `.` (Bedrock players will have `.PlayerName`)
- **Player linking**: Enabled
- **Database**: SQLite (default)

## 🎮 Connecting to the Server

### Java Edition
1. Open Minecraft Java Edition
2. Go to Multiplayer → Add Server
3. **Server Address**: `your-server-ip:25565`
4. Connect normally

### Bedrock Edition
1. Open Minecraft Bedrock Edition
2. Go to Play → Servers → Add Server
3. **Server Name**: Your Server Name
4. **Server Address**: `your-server-ip`
5. **Port**: `19132`
6. Save and connect

## 🔧 Launch Scripts

### Linux/macOS (start.sh)
- **RAM**: 2GB minimum, 4GB maximum (configurable)
- **JVM optimizations**: G1GC with performance tweaks
- **Auto-checks**: Java version, EULA acceptance, server jar

### Windows (run.bat)
- **RAM**: 2GB minimum, 4GB maximum (configurable)
- **JVM optimizations**: G1GC with performance tweaks
- **Auto-checks**: Java version, EULA acceptance, server jar

### Customizing RAM Usage
Edit the launch scripts and modify:
```bash
MIN_RAM="2G"    # Minimum RAM allocation
MAX_RAM="4G"    # Maximum RAM allocation
```

## 🗂️ Mod Information

### Core Dependencies
- **Fabric API**: Required for all Fabric mods
- **YACL**: Configuration library
- **Resourceful Lib**: Library for Advanced Netherite

### Gameplay Mods
- **Advanced Netherite**: Enhanced netherite equipment

### Cross-Platform Support
- **Geyser-Fabric**: Bedrock Edition bridge
- **Floodgate-Fabric**: Authentication bypass for Bedrock
- **Hydraulic-Fabric**: Enhanced Bedrock support

### Version Compatibility
- **ViaVersion**: Multi-version support
- **ViaBackwards**: Backward compatibility
- **ViaFabric**: Fabric integration

## 📊 Performance Optimization

### Recommended System Requirements

**Minimum (1-5 players)**:
- **RAM**: 4GB
- **CPU**: 2 cores
- **Storage**: 2GB free space

**Recommended (5-20 players)**:
- **RAM**: 6-8GB
- **CPU**: 4 cores
- **Storage**: 5GB free space
- **Network**: 100Mbps upload

### JVM Optimizations (Already included in launch scripts)
- **Garbage Collector**: G1GC
- **Heap management**: Optimized for Minecraft
- **Performance flags**: Reduced pause times

## 🚨 Troubleshooting

### Server Won't Start
1. **Check Java version**: Must be Java 21+
2. **Verify EULA**: Must be set to `true`
3. **Check ports**: Ensure 25565 and 19132 are available
4. **Review logs**: Check `logs/latest.log` for errors

### Bedrock Players Can't Connect
1. **Firewall**: Ensure UDP port 19132 is open
2. **Geyser config**: Verify `config/Geyser-Fabric/config.yml`
3. **Floodgate**: Ensure Floodgate is loaded before Geyser
4. **Xbox Live**: Bedrock players need Xbox Live accounts

### Mod Loading Issues
1. **Version compatibility**: All mods must support Fabric 1.21.7
2. **Dependencies**: Check [MODS_REQUIRED.md](MODS_REQUIRED.md)
3. **Conflicts**: Remove duplicate or conflicting mods
4. **Load order**: Dependencies must load before dependent mods

### Performance Issues
1. **Increase RAM**: Edit launch scripts
2. **Reduce view distance**: Lower `view-distance` in server.properties
3. **Remove unnecessary mods**: Keep only essential mods
4. **Check system resources**: Monitor CPU and memory usage

## 🔄 Updating

### Server Updates
1. Download new Fabric server launcher
2. Replace `fabric-server-launcher.jar`
3. Update server.properties if needed
4. Restart server

### Mod Updates
1. Download updated mod versions
2. Replace old `.jar` files in `mods/` folder
3. Restart server
4. Check logs for compatibility issues

## 📈 Monitoring

### Log Files
- **Latest log**: `logs/latest.log`
- **Previous logs**: `logs/YYYY-MM-DD-X.log.gz`
- **Crash reports**: `crash-reports/`

### Useful Commands (In-game)
```
/tps                    # Check server performance
/geyser dump            # Generate Geyser debug info
/geyser offhand         # Toggle offhand for Bedrock players
/floodgate dump         # Generate Floodgate debug info
```

## 🆘 Support

### Common Issues
- **Port binding errors**: Another service using the port
- **Permission denied**: Run with appropriate permissions
- **OutOfMemoryError**: Increase RAM allocation
- **Connection refused**: Check firewall and port forwarding

### Getting Help
1. Check server logs first
2. Verify all mods are compatible with Fabric 1.21.7
3. Test with minimal mod setup
4. Check Geyser/Floodgate documentation for Bedrock issues

### Resources
- **Fabric**: https://fabricmc.net/
- **Geyser**: https://geysermc.org/
- **Modrinth**: https://modrinth.com/
- **Minecraft Wiki**: https://minecraft.wiki/

---

## 📝 License

This server setup is provided as-is for educational and server hosting purposes. Please respect Minecraft's EULA and mod licenses.

## 🤝 Contributing

Feel free to submit issues or improvements to this server setup configuration.