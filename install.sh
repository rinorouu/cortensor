#!/bin/bash

set -e 

if ! command -v git &> /dev/null; then
    apt-get update && apt-get install -y git
fi

echo "Cloning repository..."
git clone https://github.com/cortensor/installer
cd installer

echo "Installing Docker..."
./install-docker-ubuntu.sh

echo "Installing IPFS..."
./install-ipfs-linux.sh

echo "Installing Cortensor..."
./install-linux.sh

if ! id "deploy" &>/dev/null; then
    useradd -m -s /bin/bash deploy
fi

echo "Setting up deploy user..."
cp -Rf ./installer /home/deploy/installer
chown -R deploy:deploy /home/deploy/installer

echo "Verifying installations..."
sudo -u deploy sh -c 'cd ~ && ls -al /usr/local/bin/cortensord'
sudo -u deploy sh -c 'cd ~ && ls -al $HOME/.cortensor/bin/cortensord'
sudo -u deploy sh -c 'cd ~ && ls -al /etc/systemd/system/cortensor.service'
sudo -u deploy sh -c 'cd ~ && ls -al $HOME/.cortensor/bin/start-cortensor.sh'
sudo -u deploy sh -c 'cd ~ && ls -al $HOME/.cortensor/bin/stop-cortensor.sh'

echo "Docker Version: $(docker --version)"
echo "IPFS Version: $(ipfs --version)"

echo "Generating new keys..."
sudo -u deploy /usr/local/bin/cortensord /home/deploy/.cortensor/.env tool gen_key

echo "Installation completed! Have a good day Cortensorian ☕"
