# MOITM Minecraft Fabric Server - Mod List

## Required Mods for Fabric 1.21.7

### Core Framework Mods

#### 1. Fabric API
- **Purpose**: Essential API for all Fabric mods
- **Version**: Latest for 1.21.7
- **Download**: [Modrinth - Fabric API](https://modrinth.com/mod/fabric-api/versions?g=1.21)
- **Status**: ✅ Required for all other mods

#### 2. YACL (Yet Another Config Lib)
- **Purpose**: Configuration library for mods
- **Version**: Latest for 1.21.7  
- **Download**: [Modrinth - YACL](https://modrinth.com/mod/yacl/versions?g=1.21)
- **Status**: ✅ Required by several mods

#### 3. Resourceful Lib
- **Purpose**: Utility library for resource management
- **Version**: Latest for 1.21.7
- **Download**: [Modrinth - Resourceful Lib](https://modrinth.com/mod/resourceful-lib/versions?g=1.21)
- **Status**: ✅ Required by Advanced Netherite

### Content Mods

#### 4. Advanced Netherite
- **Purpose**: Enhanced netherite tools and armor with additional features
- **Version**: Latest for 1.21.7
- **Download**: [Modrinth - Advanced Netherite](https://modrinth.com/mod/advanced-netherite/versions?g=1.21)
- **Dependencies**: Resourceful Lib
- **Status**: ✅ Content mod

### Version Compatibility Mods

#### 5. ViaVersion
- **Purpose**: Allows newer clients to connect to older servers
- **Version**: Latest stable
- **Download**: [SpigotMC - ViaVersion](https://www.spigotmc.org/resources/viaversion.19254/)
- **Alternative**: [GitHub Releases](https://github.com/ViaVersion/ViaVersion/releases)
- **Status**: ✅ Protocol compatibility

#### 6. ViaBackwards  
- **Purpose**: Allows older clients to connect to newer servers
- **Version**: Latest stable
- **Download**: [SpigotMC - ViaBackwards](https://www.spigotmc.org/resources/viabackwards.27448/)
- **Alternative**: [GitHub Releases](https://github.com/ViaVersion/ViaBackwards/releases)
- **Dependencies**: ViaVersion
- **Status**: ✅ Protocol compatibility

#### 7. ViaFabric
- **Purpose**: Fabric implementation of Via* protocol support
- **Version**: Latest for 1.21
- **Download**: [Modrinth - ViaFabric](https://modrinth.com/mod/viafabric/versions?g=1.21)
- **Dependencies**: ViaVersion, ViaBackwards
- **Status**: ✅ Required for Via* integration

### Bedrock Support Mods

#### 8. Geyser-Fabric
- **Purpose**: Allows Bedrock Edition players to join Java Edition servers
- **Version**: Latest for 1.21
- **Download**: [Geyser Downloads - Fabric](https://geysermc.org/download/?platform=fabric)
- **Status**: ✅ Cross-platform support

#### 9. Floodgate-Fabric
- **Purpose**: Authentication system for Bedrock players on Java servers
- **Version**: Latest for 1.21
- **Download**: [Geyser Downloads - Fabric](https://geysermc.org/download/?platform=fabric)
- **Dependencies**: Works with Geyser
- **Status**: ✅ Bedrock authentication

#### 10. Hydraulic-Fabric
- **Purpose**: Enhanced fluid mechanics and performance
- **Version**: 1.0.0 Build 93
- **Download**: [Direct Download](https://download.geysermc.org/v2/projects/hydraulic/versions/1.0.0/builds/93/downloads/fabric)
- **Status**: ✅ Performance enhancement

## Installation Instructions

### Automatic Installation (Recommended)
1. Run `./install.sh` (Linux/Mac) or use manual steps below
2. Follow the prompts to download Fabric server
3. Download mods manually using links above

### Manual Installation
1. Create a `mods` folder in your server directory
2. Download each mod from the links provided
3. Ensure you download the correct version for Fabric 1.21.7
4. Place all `.jar` files in the `mods` folder

## Mod Compatibility Notes

### Known Compatible Combinations
- ✅ Fabric API + YACL + Resourceful Lib + Advanced Netherite
- ✅ ViaVersion + ViaBackwards + ViaFabric (for multi-version support)
- ✅ Geyser + Floodgate + Hydraulic (for Bedrock support)

### Potential Conflicts
- ⚠️ Some Via* mods may conflict with certain content mods
- ⚠️ Geyser may have issues with mods that heavily modify networking
- ⚠️ Always test mod combinations in a development environment first

## Version Compatibility Matrix

| Minecraft Version | Fabric Loader | Fabric API | Status |
|-------------------|---------------|------------|---------|
| 1.21.7           | 0.16.9+       | Latest     | ✅ Supported |
| 1.21.6           | 0.16.9+       | Latest     | ✅ Compatible |
| 1.21.5           | 0.16.8+       | Latest     | ⚠️ May work |

## Performance Recommendations

### For High-Performance Servers
- Use G1GC garbage collector (included in start scripts)
- Allocate 4-8GB RAM for 10-20 players
- Enable Hydraulic-Fabric for better fluid performance
- Monitor server performance with `/geyser dump` for Bedrock issues

### For Low-Resource Servers  
- Reduce view distance in server.properties
- Limit concurrent Bedrock connections in Geyser config
- Consider removing Advanced Netherite if performance is critical

## Troubleshooting

### Common Issues
1. **Mod Not Loading**: Check Fabric version compatibility
2. **Bedrock Can't Connect**: Verify Geyser/Floodgate configuration and firewall settings
3. **Version Mismatch**: Ensure Via* mods are compatible versions
4. **Performance Issues**: Reduce mod count or increase server resources

### Support Resources
- [Fabric Wiki](https://fabricmc.net/wiki/)
- [Geyser Discord](https://discord.gg/geysermc)
- [Mod-specific GitHub issues](https://github.com/)

Last updated: $(date +"%Y-%m-%d")