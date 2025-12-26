#!/bin/bash

# Script Name: audit.sh
# Description: Audits the system for basic security configurations and hardening verification.
# Author: Sviatoslav Diachuk

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

echo -e "${YELLOW}--- STARTING SECURITY AUDIT ---${NC}"
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "-----------------------------------"

# Helper function for pass/fail
check_result() {
    if [ "$1" == "PASS" ]; then
        echo -e "[ ${GREEN}PASS${NC} ] $2"
    elif [ "$1" == "WARN" ]; then
        echo -e "[ ${YELLOW}WARN${NC} ] $2"
    else
        echo -e "[ ${RED}FAIL${NC} ] $2"
    fi
}

# 1. Check User Accounts
echo -e "\n${YELLOW}>>> Checking User & Password Security${NC}"

# Check if Root is locked
if passwd -S root | grep -q "L"; then
    check_result "PASS" "Root account is locked/disabled."
else
    check_result "FAIL" "Root account is NOT locked."
fi

# Check for accounts with empty passwords
EMPTY_PASS=$(awk -F: '($2 == "") {print $1}' /etc/shadow)
if [ -z "$EMPTY_PASS" ]; then
    check_result "PASS" "No accounts with empty passwords found."
else
    check_result "FAIL" "Accounts with empty passwords found: $EMPTY_PASS"
fi

# Check if UID 0 is only root
UID_ZERO=$(awk -F: '($3 == "0") {print $1}' /etc/passwd | grep -v '^root$')
if [ -z "$UID_ZERO" ]; then
    check_result "PASS" "Root is the only UID 0 account."
else
    check_result "FAIL" "Non-root accounts with UID 0 found: $UID_ZERO"
fi

# 2. Check SSH Configuration
echo -e "\n${YELLOW}>>> Checking SSH Configuration${NC}"
SSHD_CONFIG="/etc/ssh/sshd_config"

# Check Root Login
if grep -Eq "^PermitRootLogin no" $SSHD_CONFIG; then
    check_result "PASS" "SSH Root Login is disabled."
else
    check_result "FAIL" "SSH Root Login might be enabled."
fi

# Check Password Auth
if grep -Eq "^PasswordAuthentication no" $SSHD_CONFIG; then
    check_result "PASS" "SSH Password Authentication is disabled."
else
    check_result "FAIL" "SSH Password Authentication is enabled."
fi

# Check Empty Passwords in SSH
if grep -Eq "^PermitEmptyPasswords no" $SSHD_CONFIG; then
    check_result "PASS" "SSH Empty Passwords disabled."
else
    # It defaults to no, but good to have explicit
    check_result "WARN" "PermitEmptyPasswords not explicitly set to 'no'."
fi

# 3. Check Firewall (UFW)
echo -e "\n${YELLOW}>>> Checking Firewall Status${NC}"
UFW_STATUS=$(ufw status | grep "Status: active")
if [ -n "$UFW_STATUS" ]; then
    check_result "PASS" "UFW is active."
    echo "   Current Rules:"
    ufw status numbered | head -n 5 | sed 's/^/   /'
else
    check_result "FAIL" "UFW is NOT active."
fi

# 4. Check Important Security Tools
echo -e "\n${YELLOW}>>> Checking Additional Security Tools${NC}"

# Check for Fail2Ban (Intrusion Prevention)
if command -v fail2ban-client &> /dev/null; then
    check_result "PASS" "Fail2Ban is installed."
else
    check_result "WARN" "Fail2Ban is NOT installed (Recommended for brute-force protection)."
fi

# Check for Unattended Upgrades
if dpkg -l | grep -q unattended-upgrades; then
    check_result "PASS" "Unattended-upgrades package is installed."
else
    check_result "WARN" "Automatic security updates are not configured."
fi

# 5. Network Audit (Listening Ports)
echo -e "\n${YELLOW}>>> Auditing Listening Ports (TCP)${NC}"
# Shows what services are exposed to the internet
ss -tulpn | grep LISTEN | awk '{print $1, $5, $7}' | sed 's/^/   /'

echo -e "\n${YELLOW}--- AUDIT COMPLETE ---${NC}"

