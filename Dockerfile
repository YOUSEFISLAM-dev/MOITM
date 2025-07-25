FROM eclipse-temurin:21-jdk-jammy

# Set maintainer information
LABEL maintainer="MOITM Team"
LABEL description="Advanced Cross-Play Modded Minecraft Server"
LABEL version="1.0"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    jq \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Create minecraft user and group
RUN groupadd -r minecraft && useradd -r -g minecraft -m -d /home/minecraft minecraft

# Set working directory
WORKDIR /opt/minecraft

# Copy server files
COPY --chown=minecraft:minecraft . .

# Create necessary directories
RUN mkdir -p server mods logs world config \
    && chown -R minecraft:minecraft /opt/minecraft

# Install Fabric and download mods
RUN chmod +x setup.sh && \
    su - minecraft -c "cd /opt/minecraft && ./setup.sh --docker"

# Switch to minecraft user
USER minecraft

# Expose ports
EXPOSE 25565/tcp   # Java Edition
EXPOSE 19132/udp   # Bedrock Edition  
EXPOSE 8080/tcp    # Web Client
EXPOSE 25575/tcp   # RCON (optional)

# Create volume mount points
VOLUME ["/opt/minecraft/world", "/opt/minecraft/logs", "/opt/minecraft/config"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD netstat -an | grep :25565 > /dev/null || exit 1

# Environment variables
ENV JAVA_OPTS="-Xmx6G -Xms2G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200"
ENV ENVIRONMENT="production"
ENV MC_VERSION="1.21"
ENV FABRIC_VERSION="0.15.11"

# Start command
CMD ["./start.sh"]