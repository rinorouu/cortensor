#!/bin/bash

cat << "EOF"
  ___                       ___           ___     
     /  /\        ___          /__/\         /  /\    
    /  /::\      /  /\         \  \:\       /  /::\   
   /  /:/\:\    /  /:/          \  \:\     /  /:/\:\  
  /  /:/~/:/   /__/::\      _____\__\:\   /  /:/  \:\ 
 /__/:/ /:/___ \__\/\:\__  /__/::::::::\ /__/:/ \__\:\
 \  \:\/:::::/    \  \:\/\ \  \:\~~\~~\/ \  \:\ /  /:/
  \  \::/~~~~      \__\::/  \  \:\  ~~~   \  \:\  /:/ 
   \  \:\          /__/:/    \  \:\        \  \:\/:/  
    \  \:\         \__\/      \  \:\        \  \::/   
     \__\/                     \__\/         \__\/    

EOF
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

cd

# Copy files and set permissions
echo "Setting up deploy user..."
cp -Rf ./installer /home/deploy/installer
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

echo "Installation completed successfully!"
