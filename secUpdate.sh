
setup_auto_updates() {
    echo "--- Configuring Unattended Security Upgrades ---"
    apt-get install -y unattended-upgrades

    # Create the configuration to enable auto-updates
    cat <<EOF > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
    
    # Ensure the service runs
    systemctl restart unattended-upgrades
    echo "Unattended upgrades enabled."
}
