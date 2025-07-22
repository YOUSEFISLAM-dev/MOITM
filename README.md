# MOITM Minecraft Fabric Server 1.21.7

A complete Minecraft server setup using **Fabric 1.21.7** with full **Bedrock Edition support** via Geyser and Floodgate, optimized for both local and VPS deployment.

## 🚀 Features

- **Fabric 1.21.7** server with mod support
- **Cross-Platform Support**: Java Edition (PC) + Bedrock Edition (Mobile, Console, Windows 10/11)
- **Version Compatibility**: Support for multiple client versions via Via*
- **Enhanced Content**: Advanced Netherite mod with improved tools and armor
- **Optimized Performance**: Pre-configured JVM flags and garbage collection
- **Easy Setup**: Automated installation and launch scripts
- **Multi-Platform**: Works on Linux, macOS, and Windows

## 📋 Server Information

| Setting | Java Edition | Bedrock Edition |
|---------|--------------|-----------------|
| **Default Port** | 25565 | 19132 |
| **Protocol** | Java Protocol | Bedrock Protocol |
| **Authentication** | Online Mode | Floodgate |
| **Max Players** | 20 (configurable) | 100 (configurable) |

## 🛠️ Prerequisites

### System Requirements
- **Java 21+** (OpenJDK or Oracle JDK)
- **RAM**: Minimum 2GB, Recommended 4GB+
- **Storage**: ~2GB for server and mods
- **Network**: Ports 25565 (Java) and 19132 (Bedrock) open

### Supported Operating Systems
- ✅ Linux (Ubuntu, Debian, CentOS, Arch)
- ✅ macOS (Intel and Apple Silicon)
- ✅ Windows 10/11
- ✅ VPS/Cloud servers

## 🏃‍♂️ Quick Start

### Option 1: Automated Installation (Recommended)

```bash
# Clone or download this repository
git clone https://github.com/YOUSEFISLAM-dev/MOITM.git
cd MOITM

# Run the installer (Linux/Mac)
chmod +x install.sh
./install.sh

# Download required mods (see mod-list.md)
# Edit eula.txt and change eula=false to eula=true

# Start the server
./start.sh
```

### Option 2: Manual Setup

1. **Download Fabric Server**
   ```bash
   # Download Fabric installer
   wget https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar
   
   # Install Fabric server for 1.21.7
   java -jar fabric-installer-1.0.1.jar server -mcversion 1.21 -loader 0.16.9 -downloadMinecraft
   ```

2. **Download Mods**
   - See [mod-list.md](mod-list.md) for complete download links
   - Place all `.jar` files in the `mods/` folder

3. **Accept EULA**
   ```bash
   # Edit eula.txt
   echo "eula=true" > eula.txt
   ```

4. **Start Server**
   ```bash
   # Linux/Mac
   ./start.sh
   
   # Windows
   start.bat
   ```

## 📁 Folder Structure

```
MOITM/
├── mods/                          # Mod JAR files
│   ├── fabric-api-*.jar          # Core Fabric API
│   ├── yacl-*.jar                # Configuration library
│   ├── resourceful-lib-*.jar     # Resource management
│   ├── advanced-netherite-*.jar  # Enhanced netherite
│   ├── viafabric-*.jar          # Version compatibility
│   ├── geyser-fabric-*.jar      # Bedrock support
│   ├── floodgate-fabric-*.jar   # Bedrock authentication
│   ├── hydraulic-fabric-*.jar   # Performance enhancement
│   └── DOWNLOAD_MODS.txt        # Download instructions
├── config/                       # Configuration files
│   ├── geyser/
│   │   └── config.yml           # Geyser configuration
│   └── floodgate/
│       └── config.yml           # Floodgate configuration
├── server.properties            # Server settings
├── start.sh                     # Linux/Mac launch script
├── start.bat                    # Windows launch script
├── install.sh                   # Installation helper
├── mod-list.md                  # Detailed mod information
├── README.md                    # This file
└── .gitignore                   # Git ignore rules
```

## 🔧 Configuration

### Server Settings (server.properties)
Key settings are pre-configured for optimal performance:
- **Java Port**: 25565
- **Max Players**: 20
- **View Distance**: 10
- **Online Mode**: true (required for Floodgate)

### Bedrock Support (Geyser)
Bedrock players connect via:
- **Port**: 19132 (UDP)
- **Authentication**: Floodgate (no Xbox Live required)
- **Username Prefix**: "." (distinguishes Bedrock players)

### Memory Allocation
The launch scripts automatically detect system RAM and allocate:
- **8GB+ System**: 2GB-6GB for server
- **4GB+ System**: 1GB-3GB for server  
- **<4GB System**: 512MB-2GB for server

## 🔌 Port Configuration

### Firewall Setup

#### Linux (UFW)
```bash
sudo ufw allow 25565/tcp  # Java Edition
sudo ufw allow 19132/udp  # Bedrock Edition
sudo ufw reload
```

#### Linux (iptables)
```bash
iptables -A INPUT -p tcp --dport 25565 -j ACCEPT
iptables -A INPUT -p udp --dport 19132 -j ACCEPT
```

#### Windows Firewall
1. Open Windows Defender Firewall
2. Click "Allow an app or feature"
3. Add Java and allow both private/public networks
4. Manually add ports 25565 (TCP) and 19132 (UDP)

### VPS/Cloud Setup
Most cloud providers require security group rules:
- **AWS**: EC2 Security Groups
- **Google Cloud**: Firewall rules  
- **Digital Ocean**: Cloud Firewalls
- **Azure**: Network Security Groups

## 🎮 Connecting to the Server

### Java Edition (PC)
1. Open Minecraft Java Edition
2. Go to Multiplayer → Add Server
3. Enter server IP and port (default: 25565)
4. Click "Done" and join

### Bedrock Edition (Mobile, Console, Windows 10/11)
1. Open Minecraft Bedrock Edition  
2. Go to Play → Servers → Add Server
3. Enter server IP and port 19132
4. Save and join

**Note**: Bedrock players will have "." prefix in their username.

## 🧪 Included Mods

| Mod | Purpose | Version |
|-----|---------|---------|
| **Fabric API** | Core mod framework | Latest 1.21.7 |
| **YACL** | Configuration library | Latest 1.21.7 |
| **Resourceful Lib** | Resource management | Latest 1.21.7 |
| **Advanced Netherite** | Enhanced netherite gear | Latest 1.21.7 |
| **ViaFabric** | Multi-version support | Latest 1.21 |
| **Geyser-Fabric** | Bedrock client support | Latest 1.21 |
| **Floodgate-Fabric** | Bedrock authentication | Latest 1.21 |
| **Hydraulic-Fabric** | Performance enhancement | Build 93 |

See [mod-list.md](mod-list.md) for detailed information and download links.

## 🚨 Troubleshooting

### Common Issues

#### Server Won't Start
- **Check Java version**: `java -version` (need 21+)
- **Check EULA**: Ensure `eula=true` in eula.txt
- **Check ports**: Make sure 25565 and 19132 aren't in use
- **Check RAM**: Ensure adequate memory available

#### Bedrock Players Can't Connect
- **Firewall**: Verify UDP port 19132 is open
- **Geyser config**: Check IP address in config/geyser/config.yml
- **Floodgate**: Ensure Floodgate is properly installed
- **Online mode**: Must be enabled in server.properties

#### Performance Issues
- **Allocate more RAM**: Edit memory settings in launch scripts
- **Reduce view distance**: Lower value in server.properties
- **Monitor with htop/Task Manager**: Check CPU/RAM usage
- **Remove unnecessary mods**: Keep only essential ones

#### Mod Conflicts
- **Check logs**: Look in logs/latest.log for errors
- **Version compatibility**: Ensure all mods support 1.21.7
- **Dependencies**: Verify all required dependencies are installed

### Getting Help
- **Server logs**: Check `logs/latest.log` for errors
- **Geyser dump**: Use `/geyser dump` command for Bedrock issues
- **Fabric Discord**: [fabricmc.net/discuss](https://fabricmc.net/discuss)
- **Geyser Discord**: [discord.gg/geysermc](https://discord.gg/geysermc)

## 📊 Performance Optimization

### JVM Tuning
The launch scripts include optimized JVM flags:
- **G1 Garbage Collector**: Better for server workloads
- **Memory management**: Optimized heap and garbage collection
- **Aikars flags**: Community-proven server optimizations

### Server Tuning
```properties
# server.properties optimizations
view-distance=10
simulation-distance=10
max-tick-time=60000
network-compression-threshold=256
```

### Mod-Specific Optimizations
- **Geyser**: Reduce `scoreboard-packet-threshold` for high player count
- **Advanced Netherite**: Configure in mod settings if performance issues occur
- **Hydraulic**: Automatically optimizes fluid mechanics

## 🔄 Updates and Maintenance

### Updating the Server
1. **Backup your world**: Copy `world/` folder
2. **Download new Fabric installer**
3. **Update mods**: Check for 1.21.7 compatible versions
4. **Test in staging**: Verify everything works before production

### Regular Maintenance
- **Daily**: Check server logs for errors
- **Weekly**: Backup world data  
- **Monthly**: Update mods and check for security patches
- **As needed**: Monitor performance and adjust settings

## 📄 License

This server setup is provided as-is for educational and personal use. Please respect:
- **Minecraft EULA**: [minecraft.net/eula](https://minecraft.net/eula)
- **Mod licenses**: Each mod has its own license
- **Fabric license**: [fabricmc.net/wiki/license](https://fabricmc.net/wiki/license)

## 🤝 Contributing

Feel free to:
- Report issues with the setup
- Suggest additional compatible mods
- Improve the documentation
- Share performance optimizations

---

**Happy Mining!** 🎉⛏️

For support or questions, please check the troubleshooting section or create an issue in the repository.