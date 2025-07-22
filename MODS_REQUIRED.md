# Required Mods for Fabric 1.21.7 Server

This file contains the exact mods and versions needed for the server to work correctly.
Download these mods and place them in the `mods/` folder.

## Core Dependencies (Required)

### 1. Fabric API
- **Download**: https://modrinth.com/mod/fabric-api/versions?l=fabric&v=1.21.7
- **File**: `fabric-api-[version]+1.21.7.jar`
- **Purpose**: Core API for all Fabric mods

### 2. YACL (Yet Another Config Lib)
- **Download**: https://modrinth.com/mod/yacl/versions?l=fabric&v=1.21.7
- **File**: `yet-another-config-lib-fabric-[version].jar`
- **Purpose**: Configuration library dependency

### 3. Resourceful Lib
- **Download**: https://modrinth.com/mod/resourceful-lib/versions?l=fabric&v=1.21.7
- **File**: `resourceful-lib-fabric-[version].jar`
- **Purpose**: Library dependency for Advanced Netherite

## Gameplay Mods

### 4. Advanced Netherite
- **Download**: https://modrinth.com/mod/advanced-netherite/versions?l=fabric&v=1.21.7
- **File**: `advancednetherite-fabric-[version].jar`
- **Purpose**: Enhanced netherite tools and armor
- **Dependencies**: fabric-api, resourceful-lib

## Cross-Platform Support (Bedrock Edition)

### 5. Geyser-Fabric
- **Download**: https://geysermc.org/download?platform=fabric&version=1.21
- **File**: `Geyser-Fabric-[version].jar`
- **Purpose**: Allows Bedrock Edition players to join
- **Port**: 19132 (UDP)

### 6. Floodgate-Fabric
- **Download**: https://geysermc.org/download?platform=fabric&version=1.21
- **File**: `floodgate-fabric-[version].jar`
- **Purpose**: Authentication bypass for Bedrock Edition players
- **Dependencies**: Geyser-Fabric

### 7. Hydraulic-Fabric
- **Download**: https://download.geysermc.org/v2/projects/hydraulic/versions/1.0.0/builds/93/downloads/fabric
- **File**: `hydraulic-fabric-1.0.0+build.93.jar`
- **Purpose**: Enhanced Bedrock Edition support and performance

## Version Compatibility Support

### 8. ViaVersion
- **Download**: https://modrinth.com/plugin/viaversion/versions?l=fabric&v=1.21.7
- **File**: `ViaVersion-[version].jar`
- **Purpose**: Allows older clients to connect

### 9. ViaBackwards
- **Download**: https://modrinth.com/plugin/viabackwards/versions?l=fabric&v=1.21.7
- **File**: `ViaBackwards-[version].jar`
- **Purpose**: Extended backward compatibility
- **Dependencies**: ViaVersion

### 10. ViaFabric
- **Download**: https://modrinth.com/mod/viafabric/versions?l=fabric&v=1.21.7
- **File**: `viafabric-[version].jar`
- **Purpose**: Fabric integration for Via* mods
- **Dependencies**: ViaVersion

## Installation Instructions

1. **Download the Fabric Server Launcher**:
   - Go to https://fabricmc.net/use/server/
   - Download the installer for Minecraft 1.21.7
   - Run: `java -jar fabric-installer-[version].jar server`

2. **Create the mods folder** (if not exists):
   ```bash
   mkdir mods
   ```

3. **Download all required mods**:
   - Use the links above to download the latest compatible versions
   - Ensure all versions are compatible with Fabric 1.21.7
   - Place all `.jar` files in the `mods/` folder

4. **Verify mod compatibility**:
   - Check that all mods are for Fabric 1.21.7
   - Ensure no duplicate functionality between mods
   - Review server logs for any dependency warnings

## Mod Loading Order (Automatic)

Fabric loads mods automatically, but these dependencies should be noted:
1. Fabric API (loads first)
2. YACL and Resourceful Lib (libraries)
3. ViaVersion → ViaBackwards → ViaFabric (in order)
4. Floodgate → Geyser (Floodgate must load before Geyser)
5. Hydraulic (loads after Geyser)
6. Advanced Netherite (loads after its dependencies)

## Expected File Structure

```
mods/
├── fabric-api-[version]+1.21.7.jar
├── yet-another-config-lib-fabric-[version].jar
├── resourceful-lib-fabric-[version].jar
├── advancednetherite-fabric-[version].jar
├── Geyser-Fabric-[version].jar
├── floodgate-fabric-[version].jar
├── hydraulic-fabric-1.0.0+build.93.jar
├── ViaVersion-[version].jar
├── ViaBackwards-[version].jar
└── viafabric-[version].jar
```

## Troubleshooting

### Common Issues:
1. **Mod conflicts**: Check logs for incompatible mods
2. **Missing dependencies**: Ensure all required libraries are installed
3. **Version mismatches**: Verify all mods support Fabric 1.21.7
4. **Port conflicts**: Ensure ports 25565 (Java) and 19132 (Bedrock) are available

### Verification Commands:
```bash
# Check if mods loaded correctly
grep -i "loaded.*mod" logs/latest.log

# Check for errors
grep -i "error\|exception" logs/latest.log

# Check Geyser connection
grep -i "geyser" logs/latest.log
```

### Performance Notes:
- Recommended minimum RAM: 4GB
- Recommended for 10+ players: 6GB+
- VPS deployment: Ensure UDP port 19132 is open for Bedrock clients