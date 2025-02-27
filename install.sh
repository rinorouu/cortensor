#!/bin/bash

set -e  # Hentikan script jika ada error

echo "Cloning Cortensor installer..."
git clone https://github.com/cortensor/installer

# Pastikan folder 'installer' sudah ada sebelum lanjut
while [ ! -d "installer" ]; do
    echo "Waiting for installer folder..."
    sleep 2
done

cd installer

echo "Installing dependencies..."
chmod +x install-docker-ubuntu.sh install-ipfs-linux.sh install-linux.sh
./install-docker-ubuntu.sh
./install-ipfs-linux.sh
./install-linux.sh
cd

echo "Setting up deploy user directory..."
cp -Rf ./installer /home/deploy/installer
chown -R deploy:deploy /home/deploy/installer

echo "Switching to deploy user..."
sudo -u deploy bash <<EOF
cd ~/

echo "Checking installation files..."
ls -al /usr/local/bin/cortensord
ls -al \$HOME/.cortensor/bin/cortensord
ls -al /etc/systemd/system/cortensor.service
ls -al \$HOME/.cortensor/bin/start-cortensor.sh
ls -al \$HOME/.cortensor/bin/stop-cortensor.sh

echo "Checking Docker and IPFS versions..."
docker version
ipfs version

echo "Generating key for Cortensor..."
/usr/local/bin/cortensord \$HOME/.cortensor/.env tool gen_key
EOF

echo "Installation completed!"
