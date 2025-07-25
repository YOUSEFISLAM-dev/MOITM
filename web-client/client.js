// MOITM Web Client JavaScript
// Handles server connectivity, status checks, and web client integration

class MOITMWebClient {
    constructor() {
        this.serverConfig = {
            javaPort: 25565,
            bedrockPort: 19132,
            webPort: 8080,
            statusEndpoint: '/api/status'
        };
        
        this.serverStatus = {
            online: false,
            players: 0,
            maxPlayers: 0,
            version: 'Unknown',
            motd: 'Unknown',
            mods: 0
        };
        
        this.webClientLoaded = false;
        this.init();
    }

    init() {
        this.updateServerInfo();
        this.checkServerStatus();
        
        // Check server status every 30 seconds
        setInterval(() => this.checkServerStatus(), 30000);
        
        // Initialize event listeners
        this.setupEventListeners();
    }

    setupEventListeners() {
        // Handle window resize for responsive canvas
        window.addEventListener('resize', () => {
            if (this.webClientLoaded) {
                this.resizeGameCanvas();
            }
        });

        // Handle keyboard events for game client
        document.addEventListener('keydown', (event) => {
            if (this.webClientLoaded) {
                this.handleKeyDown(event);
            }
        });

        document.addEventListener('keyup', (event) => {
            if (this.webClientLoaded) {
                this.handleKeyUp(event);
            }
        });
    }

    async checkServerStatus() {
        try {
            // Try to connect to the server status endpoint
            const response = await fetch(this.serverConfig.statusEndpoint, {
                method: 'GET',
                timeout: 5000
            });

            if (response.ok) {
                const data = await response.json();
                this.updateServerStatus(data);
            } else {
                throw new Error('Server not responding');
            }
        } catch (error) {
            console.warn('Failed to get server status:', error);
            this.updateServerStatus(null);
        }
    }

    updateServerStatus(data) {
        const statusIndicator = document.getElementById('statusIndicator');
        const statusText = document.getElementById('serverStatus');
        const webClientBtn = document.getElementById('webClientBtn');

        if (data && data.online) {
            this.serverStatus = { ...this.serverStatus, ...data };
            statusIndicator.className = 'status-indicator status-online';
            statusText.textContent = 'Online';
            webClientBtn.disabled = false;
            webClientBtn.textContent = 'Launch Web Client';
        } else {
            this.serverStatus.online = false;
            statusIndicator.className = 'status-indicator status-offline';
            statusText.textContent = 'Offline';
            webClientBtn.disabled = true;
            webClientBtn.textContent = 'Server Offline';
        }

        this.updateServerInfo();
    }

    updateServerInfo() {
        const elements = {
            javaAddress: document.getElementById('javaAddress'),
            bedrockAddress: document.getElementById('bedrockAddress'),
            serverVersion: document.getElementById('serverVersion'),
            playersOnline: document.getElementById('playersOnline'),
            serverMotd: document.getElementById('serverMotd'),
            modCount: document.getElementById('modCount')
        };

        if (elements.javaAddress) {
            elements.javaAddress.textContent = `${window.location.hostname}:${this.serverConfig.javaPort}`;
        }
        
        if (elements.bedrockAddress) {
            elements.bedrockAddress.textContent = `${window.location.hostname}:${this.serverConfig.bedrockPort}`;
        }
        
        if (elements.serverVersion) {
            elements.serverVersion.textContent = this.serverStatus.version || 'Unknown';
        }
        
        if (elements.playersOnline) {
            elements.playersOnline.textContent = `${this.serverStatus.players || 0}/${this.serverStatus.maxPlayers || 0}`;
        }
        
        if (elements.serverMotd) {
            elements.serverMotd.textContent = this.serverStatus.motd || 'MOITM Server';
        }
        
        if (elements.modCount) {
            elements.modCount.textContent = `${this.serverStatus.mods || 0} active`;
        }
    }

    async launchWebClient() {
        if (!this.serverStatus.online) {
            this.showNotification('Server is offline', 'error');
            return;
        }

        const loadingScreen = document.getElementById('loadingScreen');
        const clientOptions = document.getElementById('clientOptions');
        const gameCanvas = document.getElementById('gameCanvas');

        // Show loading screen
        loadingScreen.classList.remove('hidden');
        clientOptions.style.display = 'none';

        try {
            // Initialize web client
            await this.initializeWebClient();
            
            // Hide loading and show game canvas
            loadingScreen.classList.add('hidden');
            gameCanvas.style.display = 'block';
            
            this.webClientLoaded = true;
            this.showNotification('Web client loaded successfully!', 'success');
            
        } catch (error) {
            console.error('Failed to load web client:', error);
            loadingScreen.classList.add('hidden');
            clientOptions.style.display = 'grid';
            this.showNotification('Failed to load web client. Please try again.', 'error');
        }
    }

    async initializeWebClient() {
        // This is a placeholder for web client integration
        // In a real implementation, this would load a WebAssembly Minecraft client
        // or integrate with a service like Eaglercraft
        
        return new Promise((resolve, reject) => {
            // Simulate loading time
            setTimeout(() => {
                // For demo purposes, just show a placeholder
                const canvas = document.getElementById('gameCanvas');
                const ctx = canvas.getContext('2d');
                
                // Draw a simple placeholder
                ctx.fillStyle = '#2c3e50';
                ctx.fillRect(0, 0, canvas.width, canvas.height);
                
                ctx.fillStyle = '#3498db';
                ctx.font = '24px Arial';
                ctx.textAlign = 'center';
                ctx.fillText('Minecraft Web Client', canvas.width / 2, canvas.height / 2 - 20);
                ctx.fillText('(Integration Required)', canvas.width / 2, canvas.height / 2 + 20);
                
                resolve();
            }, 2000);
        });
    }

    resizeGameCanvas() {
        const canvas = document.getElementById('gameCanvas');
        if (canvas) {
            // Maintain aspect ratio
            const container = canvas.parentElement;
            const containerWidth = container.offsetWidth;
            const aspectRatio = 16 / 9; // Standard game aspect ratio
            
            canvas.width = containerWidth;
            canvas.height = containerWidth / aspectRatio;
        }
    }

    handleKeyDown(event) {
        // Handle game controls
        // This would be passed to the web client engine
        console.log('Key down:', event.code);
    }

    handleKeyUp(event) {
        // Handle game controls
        // This would be passed to the web client engine
        console.log('Key up:', event.code);
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'error' ? '#e74c3c' : type === 'success' ? '#27ae60' : '#3498db'};
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 5px;
            z-index: 1000;
            animation: slideIn 0.3s ease;
        `;
        notification.textContent = message;

        // Add animation styles
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
        `;
        document.head.appendChild(style);

        document.body.appendChild(notification);

        // Remove after 3 seconds
        setTimeout(() => {
            notification.remove();
        }, 3000);
    }
}

// Global functions for button clicks
function launchWebClient() {
    window.moitmClient.launchWebClient();
}

function downloadJavaClient() {
    const serverAddress = `${window.location.hostname}:${window.moitmClient.serverConfig.javaPort}`;
    
    const modal = createModal('Java Edition Connection', `
        <div style="text-align: center;">
            <h3>Connect with Java Edition</h3>
            <p>Use the official Minecraft Java Edition launcher and connect to:</p>
            <div style="background: rgba(0,0,0,0.3); padding: 1rem; border-radius: 5px; margin: 1rem 0; font-family: monospace; font-size: 1.2rem;">
                ${serverAddress}
            </div>
            <p>Make sure you're using a compatible version (1.16.5 - 1.21+)</p>
            <div style="margin-top: 1rem;">
                <button class="btn" onclick="copyToClipboard('${serverAddress}')">Copy Address</button>
                <a href="https://minecraft.net/download" target="_blank" class="btn" style="margin-left: 1rem;">Download Minecraft</a>
            </div>
        </div>
    `);
}

function connectBedrock() {
    const serverAddress = window.location.hostname;
    const port = window.moitmClient.serverConfig.bedrockPort;
    
    const modal = createModal('Bedrock Edition Connection', `
        <div style="text-align: center;">
            <h3>Connect with Bedrock Edition</h3>
            <p>Add server in Minecraft Bedrock Edition:</p>
            <div style="text-align: left; background: rgba(0,0,0,0.3); padding: 1rem; border-radius: 5px; margin: 1rem 0;">
                <strong>Server Name:</strong> MOITM Server<br>
                <strong>Server Address:</strong> <span style="font-family: monospace;">${serverAddress}</span><br>
                <strong>Port:</strong> <span style="font-family: monospace;">${port}</span>
            </div>
            <p><strong>Supported Platforms:</strong></p>
            <p>Mobile (iOS/Android), Xbox, PlayStation, Nintendo Switch, Windows 10/11</p>
            <div style="margin-top: 1rem;">
                <button class="btn" onclick="copyToClipboard('${serverAddress}')">Copy Address</button>
                <button class="btn" onclick="copyToClipboard('${port}')" style="margin-left: 1rem;">Copy Port</button>
            </div>
        </div>
    `);
}

function createModal(title, content) {
    // Remove existing modal if any
    const existingModal = document.getElementById('modal');
    if (existingModal) {
        existingModal.remove();
    }

    const modal = document.createElement('div');
    modal.id = 'modal';
    modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.7);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
    `;

    modal.innerHTML = `
        <div style="background: #2c3e50; border-radius: 10px; padding: 2rem; max-width: 500px; width: 90%;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                <h2 style="color: #3498db;">${title}</h2>
                <button onclick="closeModal()" style="background: none; border: none; color: white; font-size: 1.5rem; cursor: pointer;">&times;</button>
            </div>
            ${content}
        </div>
    `;

    document.body.appendChild(modal);

    // Close on background click
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeModal();
        }
    });

    return modal;
}

function closeModal() {
    const modal = document.getElementById('modal');
    if (modal) {
        modal.remove();
    }
}

function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        window.moitmClient.showNotification('Copied to clipboard!', 'success');
    }).catch(() => {
        window.moitmClient.showNotification('Failed to copy to clipboard', 'error');
    });
}

// Initialize the web client when the page loads
document.addEventListener('DOMContentLoaded', () => {
    window.moitmClient = new MOITMWebClient();
});