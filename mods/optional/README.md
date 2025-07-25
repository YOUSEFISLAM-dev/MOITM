# MOITM Optional Mods

This directory contains optional mods that enhance gameplay while maintaining cross-platform compatibility.

## Recommended Cross-Platform Mods

### Performance & Optimization
- **Lithium**: Server-side performance optimizations
- **Starlight**: Improved lighting engine
- **FerriteCore**: Memory usage optimizations
- **Krypton**: Network performance improvements

### Gameplay Enhancement
- **Waystones**: Fast travel system
- **Iron Chests**: Additional storage options
- **Simple Voice Chat**: Voice communication (Java only)
- **Roughly Enough Items (REI)**: Recipe viewer

### World Generation
- **Terralith**: Enhanced terrain generation
- **Structory**: Additional structures
- **YUNG's Better Dungeons**: Improved dungeon generation

### Quality of Life
- **Carpet**: Technical tweaks and debugging
- **AppleSkin**: Food/hunger information
- **JourneyMap**: Minimap and waypoints
- **Inventory Profiles Next**: Inventory management

## Cross-Platform Compatibility

### ✅ Fully Compatible
These mods work seamlessly with both Java and Bedrock clients:
- Server-side optimization mods (Lithium, Starlight, etc.)
- Block/item additions that follow vanilla mechanics
- World generation mods
- Server utilities and admin tools

### ⚠️ Partially Compatible  
These mods work but may have limited features for Bedrock clients:
- Client-side UI mods (only Java clients see the UI)
- Advanced redstone mechanics (may not sync properly)
- Custom particles/sounds (may not appear for Bedrock)

### ❌ Java Only
These mods only work for Java Edition clients:
- Fabric API dependent mods with client requirements
- Shader mods
- Advanced client-side modifications

## Installation Guidelines

1. **Research Compatibility**: Check mod pages for Bedrock compatibility notes
2. **Test Incrementally**: Add one mod at a time and test with both client types
3. **Monitor Performance**: Watch server performance with each addition
4. **Document Changes**: Keep track of what mods are added for troubleshooting

## Mod Testing Checklist

For each new mod:
- [ ] Server starts successfully
- [ ] Java Edition clients can connect
- [ ] Bedrock Edition clients can connect  
- [ ] Mod features work for Java clients
- [ ] Mod doesn't break features for Bedrock clients
- [ ] No significant performance impact
- [ ] No console errors related to the mod

## Performance Considerations

### Server Resources
- **RAM**: Each mod typically adds 50-200MB usage
- **CPU**: Processing varies greatly by mod type
- **Network**: Some mods increase packet traffic

### Recommended Limits
- **Small Server** (1-10 players): 5-15 mods
- **Medium Server** (10-50 players): 10-25 mods  
- **Large Server** (50+ players): Focus on optimization mods

## Configuration Tips

1. **Disable Unnecessary Features**: Turn off mod features that don't work cross-platform
2. **Optimize Settings**: Reduce processing-intensive features
3. **Sync Configs**: Ensure config files are consistent across environments
4. **Monitor Logs**: Watch for mod-related errors or warnings

## Troubleshooting

### Common Issues

1. **Mod Not Loading**
   - Check Fabric version compatibility
   - Verify dependencies are installed
   - Check for conflicting mods

2. **Bedrock Clients Can't See Mod Features**
   - This is normal for client-side mods
   - Use server-side alternatives when possible

3. **Performance Issues**
   - Remove mods one by one to identify culprit
   - Check server console for error messages
   - Monitor resource usage

### Debugging Steps

1. Remove all optional mods
2. Verify base server works
3. Add mods back one by one
4. Test with both client types after each addition
5. Document which mod causes issues

## Mod Sources

### Trusted Sources
- **Modrinth**: https://modrinth.com/
- **CurseForge**: https://www.curseforge.com/minecraft/mc-mods
- **GitHub**: Official mod repositories

### Security Notes
- Only download from official sources
- Verify checksums when available
- Keep mods updated for security patches
- Scan files with antivirus if unsure