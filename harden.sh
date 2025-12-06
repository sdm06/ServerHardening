#!/bin/bash

# Script Name: harden.sh
# Description: Automates basic server hardening for Debian/Ubuntu.
# Author: Sviatoslav Diachuk

# Exit immediately if a command exits with a non-zero status.
set -e

# Variables (Change these!)
NEW_USER="admin_user"
USER_PASS="YourStrongPasswd123!!!"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

echo "--- STARTING SYSTEM HARDENING ---"

# 1. Update and Upgrade the OS
echo "[1/5] Updating and Upgrading System..."
apt-get update && apt-get upgrade -y
apt-get install -y sudo ufw # Ensure dependencies are installed

# 2. Create a new user and add to sudo group
echo "[2/5] Creating new user: $NEW_USER..."
# Check if user exists first
if id "$NEW_USER" &>/dev/null; then
    echo "User $NEW_USER already exists. Skipping creation."
else
    useradd -m -s /bin/bash "$NEW_USER"
    echo "$NEW_USER:$USER_PASS" | chpasswd
    usermod -aG sudo "$NEW_USER"
    echo "User created and added to sudo group."
fi

# 3. Setup SSH Keys for the new user
# We copy the root's authorized_keys to the new user so you can log in.
echo "[3/5] Copying SSH keys from root to $NEW_USER..."
mkdir -p /home/"$NEW_USER"/.ssh
cp /root/.ssh/authorized_keys /home/"$NEW_USER"/.ssh/ 2>/dev/null || echo "WARNING: No SSH keys found in root. Password auth required for first login."
chown -R "$NEW_USER":"$NEW_USER" /home/"$NEW_USER"/.ssh
chmod 700 /home/"$NEW_USER"/.ssh
chmod 600 /home/"$NEW_USER"/.ssh/authorized_keys

# 4. Configure SSH (Disable Root Login & Password Auth)
echo "[4/5] Securing SSH configuration..."
SSH_CONFIG="/etc/ssh/sshd_config"

# Backup the config file first
cp $SSH_CONFIG "$SSH_CONFIG.bak"

# Disable Root Login
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG

# Disable Password Authentication
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG

# Restart SSH service to apply changes
systemctl restart ssh
echo "SSH Secured. Root login disabled. Password auth disabled."

# 5. Configure Firewall (UFW)
echo "[5/5] Configuring Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw --force enable
echo "Firewall enabled."

# 6. Lock Root Account
echo "Locking root account password..."
passwd -l root

echo "--- HARDENING COMPLETE ---"
echo "You can now log in via: ssh $NEW_USER@<server-ip>"
