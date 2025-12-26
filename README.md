
#  Linux Server Hardening & Auditing Toolkit

A collection of Bash scripts designed to automate the initial security setup (hardening) and ongoing security verification (auditing) of Debian and Ubuntu-based Linux servers.

This toolkit follows the cybersecurity principle of **"Trust, but Verify."**
1. **`harden.sh`**: Configures the server to be secure.
2. **`audit.sh`**: Scans the server to verify it *is* secure.

---

## 📂 Included Scripts

| File | Type | Description |
| :--- | :--- | :--- |
| **`harden.sh`** |  Configuration | Automates user creation, SSH locking, and Firewall setup. |
| **`audit.sh`** |  Verification | Scans system settings, users, and ports to detect vulnerabilities. |

---

##  Script 1: Hardening (`harden.sh`)

This script transforms a fresh server installation into a secured environment by implementing industry-standard security practices.

### Key Features
* **System Updates:** Updates package lists and upgrades installed packages.
* **User Management:**
    * Creates a new administrative user with `sudo` privileges.
    * Locks the default `root` account password.
* **SSH Security:**
    * **Migrates Keys:** Copies existing SSH keys from root to the new user (prevents lockout).
    * **Disables Root Login:** Prevents root login over SSH.
    * **Disables Password Auth:** Enforces Key-based authentication.
* **Firewall (UFW):**
    * Installs/Enables UFW.
    * **Default:** Deny Incoming / Allow Outgoing.
    * **Allow:** SSH (Port 22).

---

## 🔍 Script 2: Security Audit (`audit.sh`)

This script performs a read-only scan of the system to ensure hardening rules are applied and to detect configuration drift.

### What it Checks
* **User Security:** Checks if root is locked, scans for empty passwords, and detects non-root users with UID 0 (fake root accounts).
* **SSH Compliance:** Verifies that Root Login and Password Authentication are actually disabled in the config.
* **Firewall Status:** Checks if UFW is active and lists current rules.
* **Attack Surface:** Lists all open TCP listening ports exposed to the network.
* **Tools:** Checks for the presence of security tools like `fail2ban`.

---

## ⚠️ Prerequisites

* **OS:** Debian 10/11/12 or Ubuntu 20.04/22.04 LTS.
* **Permissions:** Must be run as `root` (or via `sudo`).
* **SSH Connection:** You must be connected via **SSH Key pairs** before running `harden.sh`.
    * *Warning:* If you are connected via password, you will be locked out when the script disables password authentication!

---

##  Usage Guide

### 1. Download the Toolkit
Clone this repository to your server:
```bash
git clone https://github.com/sdm06/ServerHardening.git
cd ServerHardening

```

### 2. Configure & Run Hardening

Open the hardening script and edit the variables at the top:

```bash
nano harden.sh

```

Modify these lines to match your desired username:

```bash
NEW_USER="your_username"
USER_PASS="YourSecurePassword"

```

Make executable and run:

```bash
chmod +x harden.sh
sudo ./harden.sh

```

### 3. Verify with Auditing

Once hardening is complete, run the audit script to verify the security posture. No configuration is required.

```bash
chmod +x audit.sh
sudo ./audit.sh

```

**Interpretation of Output:**

* 🟢 **[ PASS ]**: The setting is secure.
* 🟡 **[ WARN ]**: Configuration is missing or non-standard (requires attention).
* 🔴 **[ FAIL ]**: A critical security vulnerability was detected.

---

##  Testing Protocol

**Do not run `harden.sh` on a production server without testing.**

1. Spin up a Virtual Machine (VM) or a fresh Cloud Instance (Droplet/EC2).
2. Run `harden.sh`.
3. **Keep your current terminal open.**
4. Open a **new** terminal window and attempt to SSH into the server using the new user:
`ssh new_username@your_server_ip`
5. Run `audit.sh` to confirm all checks pass (Green).

---

##  License

This project is licensed under the MIT License - see the LICENSE file for details.

---
