#!/bin/bash

# One-click Installation Script for Cortensor (Fixed Version)
# Run this script as root/sudo

set -e  # Exit immediately if any command fails

# Install git if not exists
if ! command -v git &> /dev/null; then
    apt-get update && apt-get install -y git
fi

# Clone repository
echo "Cloning repository..."
git clone https://github.com/cortensor/installer
cd installer

# Run installation scripts
echo "Installing Docker..."
./install-docker-ubuntu.sh

echo "Installing IPFS..."
./install-ipfs-linux.sh

echo "Installing Cortensor..."
./install-linux.sh

# Create deploy user if not exists
if ! id "deploy" &>/dev/null; then
    useradd -m -s /bin/bash deploy
fi

# Copy files and set permissions (FIXED PATH)
echo "Setting up deploy user..."
mkdir -p /home/deploy/installer
cp -Rf ./* /home/deploy/installer
chown -R deploy:deploy /home/deploy/installer

# Verify installations as deploy user
echo "Verifying installations..."
sudo -u deploy sh -c 'cd ~ && ls -al /usr/local/bin/cortensord'
sudo -u deploy sh -c 'cd ~ && ls -al $HOME/.cortensor/bin/cortensord'
sudo -u deploy sh -c 'cd ~ && ls -al /etc/systemd/system/cortensor.service'
sudo -u deploy sh -c 'cd ~ && ls -al $HOME/.cortensor/bin/start-cortensor.sh'
sudo -u deploy sh -c 'cd ~ && ls -al $HOME/.cortensor/bin/stop-cortensor.sh'

# Check Docker and IPFS versions
echo "Docker Version: $(docker --version)"
echo "IPFS Version: $(ipfs --version)"

# Generate key as deploy user
echo "Generating keys..."
sudo -u deploy /usr/local/bin/cortensord /home/deploy/.cortensor/.env tool gen_key

echo "Installation completed! Have a nice day cortensorian ☕"
