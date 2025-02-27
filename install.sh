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

set -e  # Exit script jika terjadi error

# Clone repositori
git clone https://github.com/cortensor/installer
cd installer

# Install dependencies
./install-docker-ubuntu.sh
./install-ipfs-linux.sh
./install-linux.sh

# Setup environment user deploy
cd ..
cp -Rf installer /home/deploy/installer
chown -R deploy:deploy /home/deploy/installer

# Verifikasi instalasi dan setup keys
sudo -u deploy bash <<'EOF'
cd ~/
echo -e "\nVerifying file existence:"
ls -al /usr/local/bin/cortensord
ls -al $HOME/.cortensor/bin/cortensord
ls -al /etc/systemd/system/cortensor.service
ls -al $HOME/.cortensor/bin/start-cortensor.sh
ls -al $HOME/.cortensor/bin/stop-cortensor.sh

echo -e "\nChecking versions:"
docker version
ipfs version

echo -e "\nGenerating keys:"
/usr/local/bin/cortensord ~/.cortensor/.env tool gen_key
EOF

echo -e "\nInstalasi selesai! Semua komponen telah terpasang."
