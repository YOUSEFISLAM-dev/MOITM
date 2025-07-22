@echo off
title Minecraft Fabric Server 1.21.7 Launcher

REM Configuration
set MIN_RAM=2G
set MAX_RAM=4G
set SERVER_JAR=fabric-server-launcher.jar

echo ================================================
echo     Minecraft Fabric Server 1.21.7 Launcher    
echo ================================================

REM Check if Java is installed
java -version >nul 2>&1
if errorlevel 1 (
    echo Error: Java is not installed or not in PATH
    echo Please install Java 21 or higher
    echo Download from: https://adoptium.net/
    pause
    exit /b 1
)

REM Display Java version
echo Java version:
java -version

REM Check if server jar exists
if not exist "%SERVER_JAR%" (
    echo Error: %SERVER_JAR% not found!
    echo Please download the Fabric server launcher from:
    echo https://fabricmc.net/use/server/
    pause
    exit /b 1
)

REM Check if EULA is accepted
if not exist "eula.txt" (
    echo EULA not found. Please run the server once to generate eula.txt
    echo Then edit it and change 'eula=false' to 'eula=true'
    echo EULA: https://minecraft.net/eula
    pause
    exit /b 1
)

findstr /c:"eula=true" eula.txt >nul
if errorlevel 1 (
    echo EULA not accepted. Please read and accept the Minecraft EULA.
    echo Edit eula.txt and change 'eula=false' to 'eula=true'
    echo EULA: https://minecraft.net/eula
    pause
    exit /b 1
)

REM Create logs directory if it doesn't exist
if not exist "logs" mkdir logs

REM JVM arguments for optimal performance
set JVM_ARGS=-Xms%MIN_RAM% -Xmx%MAX_RAM%
set JVM_ARGS=%JVM_ARGS% -XX:+UseG1GC
set JVM_ARGS=%JVM_ARGS% -XX:+ParallelRefProcEnabled
set JVM_ARGS=%JVM_ARGS% -XX:MaxGCPauseMillis=200
set JVM_ARGS=%JVM_ARGS% -XX:+UnlockExperimentalVMOptions
set JVM_ARGS=%JVM_ARGS% -XX:+DisableExplicitGC
set JVM_ARGS=%JVM_ARGS% -XX:+AlwaysPreTouch
set JVM_ARGS=%JVM_ARGS% -XX:G1NewSizePercent=30
set JVM_ARGS=%JVM_ARGS% -XX:G1MaxNewSizePercent=40
set JVM_ARGS=%JVM_ARGS% -XX:G1HeapRegionSize=8M
set JVM_ARGS=%JVM_ARGS% -XX:G1ReservePercent=20
set JVM_ARGS=%JVM_ARGS% -XX:G1HeapWastePercent=5
set JVM_ARGS=%JVM_ARGS% -XX:G1MixedGCCountTarget=4
set JVM_ARGS=%JVM_ARGS% -XX:InitiatingHeapOccupancyPercent=15
set JVM_ARGS=%JVM_ARGS% -XX:G1MixedGCLiveThresholdPercent=90
set JVM_ARGS=%JVM_ARGS% -XX:G1RSetUpdatingPauseTimePercent=5
set JVM_ARGS=%JVM_ARGS% -XX:SurvivorRatio=32
set JVM_ARGS=%JVM_ARGS% -XX:+PerfDisableSharedMem
set JVM_ARGS=%JVM_ARGS% -XX:MaxTenuringThreshold=1

REM Server arguments
set SERVER_ARGS=--nogui

echo Starting Minecraft Fabric Server...
echo RAM: %MIN_RAM% - %MAX_RAM%
echo Server JAR: %SERVER_JAR%
echo ================================================

REM Start the server
java %JVM_ARGS% -jar %SERVER_JAR% %SERVER_ARGS%

echo ================================================
echo Server stopped. Check logs for any errors.
echo ================================================
pause