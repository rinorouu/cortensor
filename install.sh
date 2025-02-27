#!/bin/bash

# Fixed Installation Script with Proper Log Permissions
# Run this script as root/sudo

set -e  # Exit immediately if any command fails

# 1. Setup deploy user and environment
if ! id "deploy" &>/dev/null; then
    useradd -m -s /bin/bash deploy
    usermod -aG docker deploy  # Add to docker group if needed
fi

DEPLOY_HOME="/home/deploy"
LOG_DIR="$DEPLOY_HOME/.cortensor/logs"

# 2. Create log directory with proper permissions
mkdir -p $LOG_DIR
chown -R deploy:deploy $DEPLOY_HOME/.cortensor
chmod 755 $LOG_DIR

# 3. Run installation as deploy user
sudo -u deploy bash <<DEPLOY_SCRIPT
set -e

cd $DEPLOY_HOME

# 4. Clean previous installation
rm -rf installer

# 5. Clone and install
git clone https://github.com/cortensor/installer
cd installer
./install-docker-ubuntu.sh
./install-ipfs-linux.sh
./install-linux.sh

# 6. Verify paths in service file
sed -i "s|/root/|$DEPLOY_HOME/|g" /etc/systemd/system/cortensor.service
sed -i "s|User=root|User=deploy|g" /etc/systemd/system/cortensor.service

# 7. Reconfigure log paths
echo "LOG_PATH=$LOG_DIR/agent_miner.log" >> $DEPLOY_HOME/.cortensor/.env
DEPLOY_SCRIPT

# 8. Fix systemd service permissions
systemctl daemon-reload
systemctl restart cortensor.service

# 9. Verify installation
echo "Checking service status..."
systemctl status cortensor.service
ls -l $LOG_DIR/agent_miner.log

echo "Installation fixed successfully!"
