#!/bin/bash


# Clone repository
git clone https://github.com/cortensor/installer
cd installer || exit

# Run installation scripts
sudo ./install-docker-ubuntu.sh
sudo ./install-ipfs-linux.sh
sudo ./install-linux.sh

# Copy files to deploy user's home
sudo mkdir -p /home/deploy/installer
sudo cp -Rf . /home/deploy/installer
sudo chown -R deploy:deploy /home/deploy/installer

# Verify installations as deploy user
sudo -u deploy /bin/bash <<-'EOF'
    echo -e "\n=== Checking file permissions ==="
    ls -al /usr/local/bin/cortensord
    ls -al "$HOME/.cortensor/bin/cortensord"
    ls -al /etc/systemd/system/cortensor.service
    ls -al "$HOME/.cortensor/bin/start-cortensor.sh"
    ls -al "$HOME/.cortensor/bin/stop-cortensor.sh"
    
    echo -e "\n=== Checking software versions ==="
    docker --version
    ipfs --version
EOF

echo -e "\nInstallation completed!"
