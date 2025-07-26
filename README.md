# MOITM - Advanced Cross-Play Modded Minecraft Server

A customizable, scalable, cross-play Minecraft server supporting mods, multiple client versions, and optional browser access.

## Features

- **Cross-Play Compatibility**: Java Edition and Bedrock Edition clients can play together
- **Mod Support**: Cross-platform compatible mods with automatic synchronization
- **Multi-Version Support**: Clients on different versions can connect via version translation
- **Browser Access**: Optional web-based client for playing from any browser
- **Modular Configuration**: Environment-based configs (dev/test/prod)
- **Automated Deployment**: Scripts for local and remote deployment (VPS, containers)
- **Secure Access**: Whitelisting, authentication, and secure networking

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Java Client   │    │ Bedrock Client  │    │  Web Browser    │
│   (any version) │    │   (any version) │    │    Client       │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │ ┌────────────────────┼──────────────────────┼─────┐
          │ │        Proxy Layer │                      │     │
          │ │  ┌─────────────────▼────┐  ┌──────────────▼───┐ │
          │ │  │    ViaFabric         │  │   Web Gateway    │ │
          │ │  │ (Version Translation)│  │   (JSMine/etc)   │ │
          │ │  └─────────────────┬────┘  └──────────────┬───┘ │
          │ │  ┌─────────────────▼────┐                 │     │
          │ │  │     Geyser           │                 │     │
          │ │  │ (Bedrock Bridge)     │                 │     │
          │ │  └─────────────────┬────┘                 │     │
          │ └────────────────────┼──────────────────────┼─────┘
          │                      │                      │
          └──────────────────────▼──────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │    Fabric Server Core   │
                    │  - Cross-platform mods  │
                    │  - World management     │
                    │  - Player sync          │
                    └─────────────────────────┘
```

## Quick Start

### Prerequisites

- Java 17 or higher
- 4GB+ RAM recommended
- Ports 25565 (Java), 19132 (Bedrock), 8080 (Web) available

### Installation

```bash
# Clone and setup
git clone <repository-url>
cd MOITM
chmod +x setup.sh
./setup.sh

# Start server
./start.sh
```

### Docker Deployment

```bash
docker-compose up -d
```

## Configuration

The server uses environment-based configuration:

- `config/development/` - Local development settings
- `config/testing/` - Testing environment
- `config/production/` - Production deployment

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Java | 17 | 21+ |
| RAM | 4GB | 8GB+ |
| Storage | 10GB | 50GB+ |
| Network | 10Mbps | 100Mbps+ |

## Supported Clients

- **Java Edition**: 1.16.5 - 1.21+
- **Bedrock Edition**: 1.16.200 - Latest
- **Web Browser**: Chrome, Firefox, Safari, Edge

## Documentation

- [Setup Guide](docs/setup.md)
- [Configuration Reference](docs/configuration.md)
- [Mod Development](docs/mod-development.md)
- [Troubleshooting](docs/troubleshooting.md)

## License

ANY ONE CANT USE OR COPY OR INTERCAT THIS EXCEPT THE OWNER OF THIS REPOSITORY 