Automated System Hardening Script (Bash)

A Bash script designed to automate the initial security setup (hardening) of Debian and Ubuntu-based Linux servers. This script transforms a fresh server installation into a secured environment by implementing industry-standard security practices, removing the need for manual configuration.
🚀 Features

This script automatically performs the following actions:

    System Updates: Updates package lists and upgrades installed packages to the latest versions.

    User Management:

        Creates a new administrative user.

        Adds the new user to the sudo group.

        Locks the default root account password to prevent direct access.

    SSH Security:

        Migrates Keys: Copies existing SSH keys from root to the new user (preserves access).

        Disables Root Login: Prevents root login over SSH.

        Disables Password Auth: Enforces Key-based authentication for higher security.

    Firewall Configuration:

        Installs and enables UFW (Uncomplicated Firewall).

        Sets default policies to deny incoming and allow outgoing.

        Explicitly allows SSH (Port 22) connections.

⚠️ Prerequisites

    Operating System: Debian 10/11/12 or Ubuntu 20.04/22.04 LTS.

    Permissions: Must be run as root (or via sudo).

    SSH Connection: You must be connected to the server via SSH Key pairs before running this script. The script copies your current key to the new user. If you are connected via password, you may be locked out when password authentication is disabled.

🛠️ Usage
1. Download the script

Clone this repository or download the script directly to your server:
Bash

wget https://github.com/sdm06/ServerHardening.git

2. Configure Variables

Open the script and edit the user configuration variables at the top of the file:
Bash

vi harden.sh
or
nano harden.sh

Modify these lines:
Bash

NEW_USER="your_username"
USER_PASS="YourSecurePassword" # Used only if key auth fails locally

3. Make Executable

Give the script execution permissions:
Bash

chmod +x harden.sh

4. Run the Script

Execute the script with root privileges:
Bash

sudo ./harden.sh

🧪 Testing

Do not run this on a production server without testing.

    Spin up a Virtual Machine (VM) or a fresh Droplet/EC2 instance.

    Run the script.

    Keep your current terminal open.

    Open a new terminal window and attempt to SSH into the server using the new user: ssh new_username@your_server_ip

    Verify that root login is denied.

📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

