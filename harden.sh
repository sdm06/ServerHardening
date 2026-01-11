#!/bin/bash

# Script Name: harden.sh
# Description: Automates server hardening and orchestrates modular security scripts.
# Author: Sviatoslav Diachuk

# Exit immediately if a command exits with a non-zero status.
set -e

# --- CONFIGURATION VARIABLES (Change these!) ---
NEW_USER="admin_user"
USER_PASS="YourStrongPasswd123!!!"

# --- PRE-FLIGHT CHECKS ---
if [ "$EUID" -ne 0 ]; then 
  echo "ERROR: This script must be run as root."
  exit 1
fi

echo "=========================================="
echo "   STARTING HARDENING PROCESS             "
echo "=========================================="

# 1. Update and Upgrade the OS
echo "[1/8] Updating and Upgrading System..."
apt-get update && apt-get upgrade -y
apt-get install -y sudo ufw curl wget git

# 2. User Management (Core Logic)
echo "[2/8] Setting up User: $NEW_USER..."
if id "$NEW_USER" &>/dev/null; then
    echo "User $NEW_USER already exists. Skipping creation."
else
    useradd -m -s /bin/bash "$NEW_USER"
    echo "$NEW_USER:$USER_PASS" | chpasswd
    usermod -aG sudo "$NEW_USER"
    echo "User created and added to sudo group."
fi

# 3. SSH Key Migration (Core Logic)
echo "[3/8] Migrating SSH Keys..."
mkdir -p /home/"$NEW_USER"/.ssh
cp /root/.ssh/authorized_keys /home/"$NEW_USER"/.ssh/ 2>/dev/null || echo "WARNING: No SSH keys found in root. Password auth required for first login."
chown -R "$NEW_USER":"$NEW_USER" /home/"$NEW_USER"/.ssh
chmod 700 /home/"$NEW_USER"/.ssh
chmod 600 /home/"$NEW_USER"/.ssh/authorized_keys

# 4. SSH Hardening (Core Logic)
echo "[4/8] Securing SSH Configuration..."
SSH_CONFIG="/etc/ssh/sshd_config"
cp $SSH_CONFIG "$SSH_CONFIG.bak"

# Disable Root Login & Password Auth
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG

systemctl restart ssh

# 5. Firewall Setup (Core Logic)
echo "[5/8] Configuring Firewall (UFW)..."
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw --force enable

# 6. Lock Root Account
echo "[6/8] Locking root account..."
passwd -l root

# 7. EXECUTE EXTERNAL MODULES
echo "[7/8] Executing Modular Hardening Scripts..."

# Helper function to run scripts if they exist
run_module() {
    local script_name="$1"
    if [ -f "./$script_name" ]; then
        echo ">>> Running module: $script_name"
        chmod +x "./$script_name"
        ./"$script_name"
    else
        echo "WARNING: Module $script_name not found. Skipping."
    fi
}

# Execute the specific modules found in your directory
run_module "fail2ban.sh"
run_module "harden_network.sh"
run_module "secUpdate.sh"
run_module "sharedMemory.sh"
run_module "remove_unsecure.sh"
run_module "sshWarnBanner.sh"

# 8. Final Verification
echo "[8/8] Running Final Verification..."
if [ -f "./verification.sh" ]; then
    chmod +x "./verification.sh"
    ./verification.sh
else
    echo "Verification script not found."
fi

echo ""
echo "=========================================="
echo "       HARDENING PROCESS COMPLETE         "
echo "=========================================="
echo "New User: $NEW_USER"
echo "SSH Port: 22 (Default)"
echo "Access: ssh $NEW_USER@<server-ip>"
