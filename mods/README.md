# Mods Directory

This directory should contain all the required Fabric mods for the server.

## Required Mods (place .jar files here):

1. **fabric-api-[version]+1.21.7.jar**
2. **yet-another-config-lib-fabric-[version].jar**
3. **resourceful-lib-fabric-[version].jar**
4. **advancednetherite-fabric-[version].jar**
5. **Geyser-Fabric-[version].jar**
6. **floodgate-fabric-[version].jar**
7. **hydraulic-fabric-1.0.0+build.93.jar**
8. **ViaVersion-[version].jar**
9. **ViaBackwards-[version].jar**
10. **viafabric-[version].jar**

## Download Instructions

See [../MODS_REQUIRED.md](../MODS_REQUIRED.md) for detailed download links and instructions.

## File Structure Example:

```
mods/
├── fabric-api-0.92.2+1.21.7.jar
├── yet-another-config-lib-fabric-3.2.1.jar
├── resourceful-lib-fabric-2.1.24.jar
├── advancednetherite-fabric-2.0.0.jar
├── Geyser-Fabric-2.2.0.jar
├── floodgate-fabric-2.2.1.jar
├── hydraulic-fabric-1.0.0+build.93.jar
├── ViaVersion-4.8.1.jar
├── ViaBackwards-4.8.1.jar
└── viafabric-0.4.12.jar
```

## Important Notes:

- **All mods must be compatible with Fabric 1.21.7**
- **Do not include client-side only mods**
- **Ensure all dependencies are included**
- **Remove any old/duplicate mod versions**

The server will automatically load all `.jar` files from this directory on startup.