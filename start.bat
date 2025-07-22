@echo off
title MOITM Minecraft Fabric 1.21.7 Server

echo ==================================================
echo     MOITM Minecraft Fabric 1.21.7 Server
echo     Starting server with Bedrock support...
echo ==================================================

cd /d "%~dp0"

:: Check if Java is installed
java -version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install Java 21 or higher
    echo Download from: https://adoptopenjdk.net/
    pause
    exit /b 1
)

:: Check if fabric server launcher exists
if not exist "fabric-server-launch.jar" (
    echo ERROR: fabric-server-launch.jar not found!
    echo Please download the Fabric server launcher from:
    echo https://fabricmc.net/use/server/
    pause
    exit /b 1
)

:: Create EULA file if it doesn't exist
if not exist "eula.txt" (
    echo Creating eula.txt - you must accept the Minecraft EULA to continue
    echo # https://account.mojang.com/documents/minecraft_eula > eula.txt
    echo eula=false >> eula.txt
    echo.
    echo Please edit eula.txt and change 'eula=false' to 'eula=true' to accept the Minecraft EULA
    echo Then run this script again
    pause
    exit /b 1
)

:: Check if EULA is accepted
findstr /i "eula=true" eula.txt >nul
if errorlevel 1 (
    echo ERROR: You must accept the Minecraft EULA by setting eula=true in eula.txt
    pause
    exit /b 1
)

:: Get system memory (approximation for Windows)
for /f "tokens=2 delims==" %%i in ('wmic computersystem get TotalPhysicalMemory /value') do set TOTAL_RAM=%%i
set /a RAM_GB=!TOTAL_RAM!/1073741824

:: Set memory allocation based on system RAM
if %RAM_GB% gtr 8 (
    set MIN_RAM=2G
    set MAX_RAM=6G
) else if %RAM_GB% gtr 4 (
    set MIN_RAM=1G
    set MAX_RAM=3G
) else (
    set MIN_RAM=512M
    set MAX_RAM=2G
)

echo Detected system RAM: %RAM_GB%GB
echo Allocating %MIN_RAM% to %MAX_RAM% for Minecraft server

echo Starting server with optimized JVM flags...
echo Java Edition: localhost:25565
echo Bedrock Edition: localhost:19132
echo Press Ctrl+C to stop the server
echo.

:: Start the server with optimizations
java -Xms%MIN_RAM% -Xmx%MAX_RAM% ^
     -XX:+UseG1GC ^
     -XX:+ParallelRefProcEnabled ^
     -XX:MaxGCPauseMillis=200 ^
     -XX:+UnlockExperimentalVMOptions ^
     -XX:+DisableExplicitGC ^
     -XX:+AlwaysPreTouch ^
     -XX:G1NewSizePercent=30 ^
     -XX:G1MaxNewSizePercent=40 ^
     -XX:G1HeapRegionSize=8M ^
     -XX:G1ReservePercent=20 ^
     -XX:G1HeapWastePercent=5 ^
     -XX:G1MixedGCCountTarget=4 ^
     -XX:InitiatingHeapOccupancyPercent=15 ^
     -XX:G1MixedGCLiveThresholdPercent=90 ^
     -XX:G1RSetUpdatingPauseTimePercent=5 ^
     -XX:SurvivorRatio=32 ^
     -XX:+PerfDisableSharedMem ^
     -XX:MaxTenuringThreshold=1 ^
     -Dusing.aikars.flags=https://mcflags.emc.gs ^
     -Daikars.new.flags=true ^
     -Dfabric.log.level=WARN ^
     -jar fabric-server-launch.jar nogui

echo.
echo Server stopped.
pause