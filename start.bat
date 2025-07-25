@echo off
title MOITM Advanced Cross-Play Minecraft Server

REM Configuration
set ENVIRONMENT=%ENVIRONMENT%
if "%ENVIRONMENT%"=="" set ENVIRONMENT=development

set JAVA_OPTS=%JAVA_OPTS%
if "%JAVA_OPTS%"=="" set JAVA_OPTS=-Xmx6G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200

set MC_VERSION=%MC_VERSION%
if "%MC_VERSION%"=="" set MC_VERSION=1.21

set FABRIC_VERSION=%FABRIC_VERSION%
if "%FABRIC_VERSION%"=="" set FABRIC_VERSION=0.15.11

echo ==========================================
echo MOITM Advanced Cross-Play Minecraft Server
echo ==========================================
echo Environment: %ENVIRONMENT%
echo Java Options: %JAVA_OPTS%
echo ==========================================

REM Check if Java is installed
java -version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Java not found! Please install Java 17 or higher.
    pause
    exit /b 1
)

REM Create necessary directories
if not exist logs mkdir logs
if not exist world mkdir world
if not exist mods mkdir mods
if not exist server mkdir server
if not exist server\mods mkdir server\mods
if not exist server\config mkdir server\config
if not exist server\config\geyser mkdir server\config\geyser
if not exist server\config\floodgate mkdir server\config\floodgate
if not exist server\config\viafabric mkdir server\config\viafabric

echo [INFO] Directories created

REM Copy configuration files
echo [INFO] Copying configuration files for environment: %ENVIRONMENT%

if exist config\%ENVIRONMENT%\server\server.properties (
    copy /Y config\%ENVIRONMENT%\server\server.properties server\ >nul 2>&1
    echo [SUCCESS] Server properties copied
) else (
    echo [WARNING] Server properties not found for %ENVIRONMENT% environment
)

if exist config\%ENVIRONMENT%\geyser\config.yml (
    copy /Y config\%ENVIRONMENT%\geyser\config.yml server\config\geyser\ >nul 2>&1
    echo [SUCCESS] Geyser configuration copied
)

if exist config\%ENVIRONMENT%\floodgate\config.yml (
    copy /Y config\%ENVIRONMENT%\floodgate\config.yml server\config\floodgate\ >nul 2>&1
    echo [SUCCESS] Floodgate configuration copied
)

if exist config\%ENVIRONMENT%\viafabric\viafabric.yml (
    copy /Y config\%ENVIRONMENT%\viafabric\viafabric.yml server\config\viafabric\ >nul 2>&1
    echo [SUCCESS] ViaFabric configuration copied
)

REM Copy mods
echo [INFO] Copying mods...

if exist mods\required (
    copy /Y mods\required\*.jar server\mods\ >nul 2>&1
    echo [SUCCESS] Required mods copied
)

if exist mods\optional (
    copy /Y mods\optional\*.jar server\mods\ >nul 2>&1
    echo [SUCCESS] Optional mods copied
)

REM Check if server jar exists
set SERVER_JAR=server\fabric-server-mc.%MC_VERSION%-loader.%FABRIC_VERSION%-launcher.0.11.2.jar
if not exist "%SERVER_JAR%" (
    echo [ERROR] Server jar not found: %SERVER_JAR%
    echo [INFO] Run setup.bat first to download the server
    pause
    exit /b 1
)

echo [SUCCESS] Server jar found: %SERVER_JAR%

REM Accept EULA
if not exist server\eula.txt (
    echo [INFO] Creating EULA agreement...
    echo # EULA for MOITM Server > server\eula.txt
    echo # By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA). >> server\eula.txt
    echo eula=true >> server\eula.txt
    echo [SUCCESS] EULA accepted
)

REM Setup logging
set LOG_FILE=logs\server-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%.log
set LOG_FILE=%LOG_FILE: =0%
echo [INFO] Logging to: %LOG_FILE%

REM Start server
echo [INFO] Starting MOITM Server...
echo ======================================

cd server
java %JAVA_OPTS% -jar fabric-server-mc.%MC_VERSION%-loader.%FABRIC_VERSION%-launcher.0.11.2.jar nogui

REM Keep window open on exit
echo.
echo Server stopped.
pause