
setup_fail2ban() {
    echo "--- Installing and Configuring Fail2Ban ---"
    apt-get update
    apt-get install -y fail2ban

    # Create a local config file to override defaults safely
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

    # Increase ban time to 1 hour (3600 seconds)
    # Finds the bantime line and replaces it
    sed -i 's/bantime  = 10m/bantime = 1h/g' /etc/fail2ban/jail.local

    # Restart to apply changes
    systemctl enable fail2ban
    systemctl restart fail2ban
    echo "Fail2Ban installed and running."
}
