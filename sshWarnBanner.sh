
setup_ssh_banner() {
    echo "--- Setting up SSH Legal Banner ---"
    
    # Write the warning message
    echo "WARNING: Authorized access only. All activity may be monitored and reported." > /etc/issue.net

    # Tell SSH to use this banner
    if grep -q "^Banner" /etc/ssh/sshd_config; then
        sed -i 's|^Banner.*|Banner /etc/issue.net|' /etc/ssh/sshd_config
    else
        echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
    fi
    
    # Note: You must restart SSH for this to take effect, 
    echo "SSH Banner configured."
}
