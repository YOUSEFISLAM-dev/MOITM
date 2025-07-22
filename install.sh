#!/bin/bash

# MOITM Minecraft Fabric Server Installation Script
# This script helps automate the installation of the server and mods

echo "=================================================="
echo "    MOITM Minecraft Fabric Server Installer"
echo "    Fabric 1.21.7 with Bedrock Support"
echo "=================================================="

cd "$(dirname "$0")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to download file with wget or curl
download_file() {
    local url=$1
    local output=$2
    local description=$3
    
    print_status "Downloading $description..."
    
    if command -v wget &> /dev/null; then
        wget -O "$output" "$url"
    elif command -v curl &> /dev/null; then
        curl -L -o "$output" "$url"
    else
        print_error "Neither wget nor curl is available. Please install one of them."
        return 1
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Downloaded $description"
        return 0
    else
        print_error "Failed to download $description"
        return 1
    fi
}

# Check for required tools
print_status "Checking system requirements..."

# Check Java
if ! command -v java &> /dev/null; then
    print_error "Java is not installed. Please install Java 21 or higher."
    echo "Ubuntu/Debian: sudo apt install openjdk-21-jdk"
    echo "CentOS/RHEL: sudo yum install java-21-openjdk-devel"
    echo "Arch Linux: sudo pacman -S jdk-openjdk"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 21 ]; then
    print_warning "Java 21 or higher is recommended. Current: $(java -version 2>&1 | head -n 1)"
else
    print_success "Java version check passed"
fi

# Check for download tools
if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
    print_error "Neither wget nor curl is available. Please install one:"
    echo "Ubuntu/Debian: sudo apt install wget"
    echo "CentOS/RHEL: sudo yum install wget"
    exit 1
fi

# Create necessary directories
print_status "Creating directory structure..."
mkdir -p mods config/{geyser,floodgate} server logs

# Download Fabric Server Launcher
if [ ! -f "fabric-server-launch.jar" ]; then
    print_status "Downloading Fabric Server Launcher..."
    FABRIC_INSTALLER_URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar"
    
    if download_file "$FABRIC_INSTALLER_URL" "fabric-installer.jar" "Fabric Installer"; then
        print_status "Installing Fabric server..."
        java -jar fabric-installer.jar server -mcversion 1.21 -loader 0.16.9 -downloadMinecraft
        
        if [ -f "fabric-server-launch.jar" ]; then
            print_success "Fabric server installed successfully"
            rm fabric-installer.jar
        else
            print_error "Failed to install Fabric server"
            exit 1
        fi
    else
        exit 1
    fi
else
    print_success "Fabric server launcher already exists"
fi

# Create mods download instructions
print_status "Creating mod download guide..."

cat > mods/DOWNLOAD_MODS.txt << 'EOF'
MOITM Minecraft Server - Required Mods Download Guide
====================================================

Please download the following mods and place them in this 'mods' folder:

CORE MODS (Required):
1. Fabric API (Latest 1.21.7)
   URL: https://modrinth.com/mod/fabric-api/versions?g=1.21
   
2. YACL (Yet Another Config Lib) - Latest 1.21.7
   URL: https://modrinth.com/mod/yacl/versions?g=1.21

UTILITY MODS:
3. Resourceful Lib - Latest 1.21.7
   URL: https://modrinth.com/mod/resourceful-lib/versions?g=1.21

CONTENT MODS:
4. Advanced Netherite - Latest 1.21.7
   URL: https://modrinth.com/mod/advanced-netherite/versions?g=1.21

VERSION COMPATIBILITY MODS:
5. ViaVersion - Latest
   URL: https://www.spigotmc.org/resources/viaversion.19254/
   
6. ViaBackwards - Latest  
   URL: https://www.spigotmc.org/resources/viabackwards.27448/
   
7. ViaFabric - Latest for 1.21
   URL: https://modrinth.com/mod/viafabric/versions

BEDROCK SUPPORT MODS:
8. Geyser-Fabric - Latest 1.21
   URL: https://geysermc.org/download/?platform=fabric
   
9. Floodgate-Fabric - Latest 1.21
   URL: https://geysermc.org/download/?platform=fabric

10. Hydraulic-Fabric - Build 93
    Direct URL: https://download.geysermc.org/v2/projects/hydraulic/versions/1.0.0/builds/93/downloads/fabric

INSTALLATION NOTES:
- Download the .jar files and place them directly in this mods/ folder
- Make sure all mods are compatible with Fabric 1.21.7
- Check mod descriptions for any additional dependencies
- Some mods may require additional configuration in the config/ folder

After downloading all mods, run start.sh (Linux/Mac) or start.bat (Windows) to start the server.
EOF

print_success "Mod download guide created in mods/DOWNLOAD_MODS.txt"

# Set up basic server files
if [ ! -f "eula.txt" ]; then
    print_status "Creating EULA file..."
    cat > eula.txt << 'EOF'
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
#You must accept the EULA to run the server
eula=false
EOF
    print_warning "EULA created with eula=false. You must change it to eula=true to run the server."
fi

# Make scripts executable
chmod +x start.sh 2>/dev/null || true

print_status "Installation complete!"
echo ""
print_success "Next steps:"
echo "1. Download all required mods (see mods/DOWNLOAD_MODS.txt)"
echo "2. Edit eula.txt and change 'eula=false' to 'eula=true'"
echo "3. Run ./start.sh (Linux/Mac) or start.bat (Windows)"
echo "4. Server will be available at:"
echo "   - Java Edition: localhost:25565"
echo "   - Bedrock Edition: localhost:19132"
echo ""
print_warning "Remember to configure your firewall to allow these ports!"

exit 0