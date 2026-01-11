
audit_system() {
    echo ""
    echo "=========================================="
    echo "       HARDENING VERIFICATION REPORT      "
    echo "=========================================="
    echo ""

    # 1. Check Firewall (UFW)
    if ufw status | grep -q "Status: active"; then
        echo -e "[ PASS ] Firewall is ACTIVE"
    else
        echo -e "[ FAIL ] Firewall is INACTIVE"
    fi

    # 2. Check SSH Root Login
    if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
        echo -e "[ PASS ] SSH Root Login is DISABLED"
    else
        echo -e "[ FAIL ] SSH Root Login might still be enabled"
    fi

    # 3. Check SSH Password Authentication
    if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
        echo -e "[ PASS ] SSH Password Auth is DISABLED"
    else
        echo -e "[ FAIL ] SSH Password Auth might still be enabled"
    fi

    # 4. Check Fail2Ban Service
    if systemctl is-active --quiet fail2ban; then
        echo -e "[ PASS ] Fail2Ban is RUNNING"
    else
        echo -e "[ FAIL ] Fail2Ban is NOT running"
    fi

    # 5. Check Unattended Upgrades
    if [ -f "/etc/apt/apt.conf.d/20auto-upgrades" ]; then
        echo -e "[ PASS ] Auto-updates are CONFIGURED"
    else
        echo -e "[ FAIL ] Auto-updates config missing"
    fi

    # 6. Check Shared Memory Security
    if mount | grep "/dev/shm" | grep -q "noexec"; then
        echo -e "[ PASS ] Shared Memory (/dev/shm) is SECURED"
    else
        echo -e "[ FAIL ] Shared Memory is NOT secured (missing noexec)"
    fi

    # 7. Check Network Hardening (Sample check: IP Spoofing)
    if sysctl net.ipv4.conf.all.rp_filter | grep -q "1"; then
        echo -e "[ PASS ] Network Stack is HARDENED"
    else
        echo -e "[ FAIL ] Network Stack defaults detected"
    fi

    echo ""
    echo "=========================================="
    echo "   Review any FAIL messages above.        "
    echo "=========================================="
}
