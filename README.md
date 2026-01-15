# Linux Server Hardening & Auditing Toolkit

A modular Bash script ecosystem designed to automate the initial security setup (hardening) and ongoing verification (auditing) of Debian and Ubuntu-based Linux servers.

This toolkit follows the cybersecurity principle of **"Trust, but Verify."**
1. **`harden.sh`**: The master script that orchestrates the hardening process.
2. **`verification.sh`**: The audit script that scans the server to confirm security controls are active.

---

## 📂 Included Scripts

| File | Type | Description |
| :--- | :--- | :--- |
| **`harden.sh`** |  **Orchestrator** | Master script. Sets up User/SSH/UFW and runs the modules below. |
| **`fail2ban.sh`** |  Module | Installs **Fail2Ban** to block brute-force attacks. |
| **`harden_network.sh`** |  Module | Hardens the **Network Stack** (sysctl) against spoofing/MITM. |
| **`secUpdate.sh`** |  Module | Configures **Unattended Upgrades** for security patches. |
| **`sharedMemory.sh`** |  Module | Secures Shared Memory (`/dev/shm`) against execution. |
| **`remove_unsecure.sh`** |  Module | Removes bloatware and insecure packages (telnet, ftp). |
| **`sshWarnBanner.sh`** |  Module | Configures a legal warning banner for SSH logins. |
| **`verification.sh`** |  **Audit** | Scans system settings to verify hardening was successful. |

---

##  Script 1: Hardening (`harden.sh`)

This script transforms a fresh server installation into a secured environment. It performs core setup tasks and then automatically executes the external modules.

### Core Features (Built-in)
* **System Updates:** Updates package lists and upgrades installed packages.
* **User Management:** Creates a generic `sudo` user and locks the `root` account.
* **SSH Security:** Migrates existing keys, disables Root Login, and disables Password Auth.
* **Firewall (UFW):** Sets default policies (Deny Incoming / Allow Outgoing) and allows SSH.

### Modular Enhancements
When you run `harden.sh`, it automatically triggers these separate scripts:
* **Active Defense:** Installs `fail2ban` to ban malicious IPs.
* **Kernel Hardening:** Disables IP forwarding, redirects, and source routing.
* **Auto-Patching:** Ensures security updates are applied automatically.
* **Legal Compliance:** Adds a "Authorized Access Only" banner to SSH.

---

##  Script 2: Security Audit (`verification.sh`)

This script performs a read-only scan of the system to ensure hardening rules are applied and to detect configuration drift.

### What it Checks
* **User Security:** Verifies root is locked and no empty passwords exist.
* **SSH Compliance:** Confirms `PermitRootLogin` and `PasswordAuthentication` are "no".
* **Firewall Status:** Checks if UFW is active and reporting status.
* **Service Health:** Verifies `fail2ban` and `unattended-upgrades` are running.
* **Kernel Security:** Checks if shared memory is mounted as `noexec`.

---

## ⚠️ Prerequisites

* **OS:** Debian 10/11/12 or Ubuntu 20.04/22.04 LTS.
* **Permissions:** Must be run as `root` (or via `sudo`).
* **SSH Connection:** You must be connected via **SSH Key pairs** before running `harden.sh`.
    * *Warning:* If you are connected via password, you will be locked out when the script disables password authentication!

---

## 🛠️ Usage Guide

### 1. Download the Toolkit
Clone this repository to your server:
```bash
git clone https://github.com/sdm06/ServerHardening.git
cd ServerHardening

```

### 2. Configure & Run Hardening

Open the master script and edit the user variables at the top:

```bash
nano harden.sh

```

Modify these lines to match your desired username:

```bash
NEW_USER="your_username"
USER_PASS="YourSecurePassword"

```

Make the master script executable and run it. It will handle permissions for the sub-scripts automatically.

```bash
chmod +x harden.sh
sudo ./harden.sh

```

### 3. Verify with Auditing

The hardening script will try to run the verification automatically at the end. You can also run it manually at any time to check server health:

```bash
chmod +x verification.sh
sudo ./verification.sh

```

**Interpretation of Output:**

*  **[ PASS ]**: The setting is secure.
*  **[ FAIL ]**: A critical security vulnerability was detected (requires attention).

---

## 🧪 Testing Protocol

**Do not run `harden.sh` on a production server without testing.**

1. Spin up a Virtual Machine (VM) or a fresh Cloud Instance.
2. Run `harden.sh`.
3. **Keep your current terminal open.**
4. Open a **new** terminal window and attempt to SSH into the server using the new user:
`ssh new_username@your_server_ip`
5. Run `verification.sh` to confirm all checks pass.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
