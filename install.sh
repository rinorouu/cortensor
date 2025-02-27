#!/bin/bash

# Fixed One-click Installation Script with Proper Permissions
# Run this script as root/sudo

set -e  # Exit immediately if any command fails

# Create deploy user if not exists
if ! id "deploy" &>/dev/null; then
    echo "Creating deploy user..."
    useradd -m -s /bin/bash deploy
    usermod -aG sudo deploy  # Grant sudo privileges if needed
fi

# Work in deploy user's home directory
DEPLOY_HOME="/home/deploy"

# Install dependencies as root
echo "Installing system dependencies..."
apt-get update
apt-get install -y git curl

# Run installer as deploy user
echo "Running installation as deploy user..."
sudo -u deploy sh -c "
    set -e
    
    # Work in user's home directory
    cd ${DEPLOY_HOME}
    
    # Clean previous installation
    rm -rf installer
    
    # Clone repository
    echo 'Cloning repository...'
    git clone https://github.com/cortensor/installer
    cd installer
    
    # Install Docker
    echo 'Installing Docker...'
    ./install-docker-ubuntu.sh
    
    # Install IPFS
    echo 'Installing IPFS...'
    ./install-ipfs-linux.sh
    
    # Install Cortensor
    echo 'Installing Cortensor...'
    ./install-linux.sh
    
    # Verify installations
    echo 'Verifying installations...'
    ls -al /usr/local/bin/cortensord
    ls -al ${DEPLOY_HOME}/.cortensor/bin/cortensord
    ls -al /etc/systemd/system/cortensor.service
    ls -al ${DEPLOY_HOME}/.cortensor/bin/start-cortensor.sh
    ls -al ${DEPLOY_HOME}/.cortensor/bin/stop-cortensor.sh
    
    # Initialize IPFS
    ipfs init
"

# Post-installation checks
echo "Checking Docker and IPFS versions..."
sudo -u deploy docker --version
sudo -u deploy ipfs --version

# Generate keys as deploy user
echo "Generating keys..."
sudo -u deploy /usr/local/bin/cortensord ${DEPLOY_HOME}/.cortensor/.env tool gen_key

echo "Installation completed successfully!"
