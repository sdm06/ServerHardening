
remove_bloatware() {
    echo "--- Removing Unused/Insecure Packages ---"
    # List of packages to remove
    PACKAGES="telnet ftp rsh-client rsh-redone-client talk"

    apt-get remove --purge -y $PACKAGES
    apt-get autoremove -y
    echo "Bloatware removed."
}
