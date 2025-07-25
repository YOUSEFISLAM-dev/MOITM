# MOITM Required Mods

This directory contains essential mods required for cross-play functionality.

## Core Cross-Play Mods

### 1. Geyser-Fabric
- **Purpose**: Enables Bedrock Edition clients to connect to Java Edition servers
- **Download**: https://geysermc.org/download
- **Version**: Latest compatible with your Minecraft version
- **File**: `Geyser-Fabric-*.jar`

### 2. Floodgate-Fabric  
- **Purpose**: Allows Bedrock players to join without Java Edition accounts
- **Download**: https://github.com/GeyserMC/Floodgate
- **Version**: Must match Geyser version
- **File**: `floodgate-fabric-*.jar`

### 3. ViaFabric
- **Purpose**: Enables multiple Minecraft versions to connect
- **Download**: https://github.com/ViaVersion/ViaFabric
- **Version**: Latest stable
- **File**: `ViaFabric-*.jar`

## Installation

1. Download the required mod JARs from the links above
2. Place them in this directory (`mods/required/`)
3. Run the setup script: `./setup.sh`
4. Start the server: `./start.sh`

## Compatibility Matrix

| Minecraft Version | Geyser | Floodgate | ViaFabric |
|------------------|---------|-----------|-----------|
| 1.21             | 2.2.3+  | 2.2.2+    | 0.4.13+   |
| 1.20.6           | 2.2.0+  | 2.2.0+    | 0.4.12+   |
| 1.20.4           | 2.1.0+  | 2.1.0+    | 0.4.11+   |
| 1.20.1           | 2.1.0+  | 2.1.0+    | 0.4.10+   |

## Configuration

Each mod has its own configuration directory in `config/`:
- `config/development/geyser/config.yml`
- `config/development/floodgate/config.yml`  
- `config/development/viafabric/viafabric.yml`

## Troubleshooting

### Common Issues

1. **"Incompatible mod version"**
   - Ensure all mods are compatible with your Minecraft/Fabric version
   - Check the compatibility matrix above

2. **"Floodgate key not found"**
   - Ensure `config/floodgate/key.pem` exists
   - Generate with: `java -jar floodgate-*.jar generatekey`

3. **"Port already in use"**
   - Change ports in respective config files
   - Default: Java 25565, Bedrock 19132

## Performance Notes

- Geyser: Moderate CPU usage for translation
- Floodgate: Minimal overhead
- ViaFabric: Low to moderate CPU usage depending on version differences

## Security Considerations

- Use Floodgate authentication in production
- Configure whitelisting if needed
- Monitor for unusual connection patterns
- Keep mods updated for security patches