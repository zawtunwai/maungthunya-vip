#!/bin/bash
# MAUNG THUN YA PRE-INSTALL VERIFICATION
# NO CACHE + IPv4 FIXED VERSION

clear
echo -e "\033[1;36m"
echo "╔═════════════════════════════════════════════════╗"
echo "║        MAUNG THUN YA SSH MANAGER v1.0           ║"
echo "║         PRE-INSTALLATION VERIFICATION           ║"
echo "╚═════════════════════════════════════════════════╝"
echo -e "\033[0m"

# Load lock config from GitHub (NO CACHE + FORCE UPDATE)
CONFIG_URL="https://raw.githubusercontent.com/zawtunwai/maungthunya-vip/main/config_lock.sh?version=$(date +%s%N)"
LOCK_CONFIG=$(curl -s --max-time 10 -H "Cache-Control: no-cache, no-store, must-revalidate" -H "Pragma: no-cache" "$CONFIG_URL" 2>/dev/null)

# If can't download config, show error and exit
if [ -z "$LOCK_CONFIG" ]; then
    echo -e "\033[1;31m"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║         CONFIGURATION ERROR!                    ║"
    echo "╠══════════════════════════════════════════════════╣"
    echo "║  Cannot download configuration file.            ║"
    echo "║  Please check internet connection.              ║"
    echo "║  If problem persists, contact script owner.     ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "\033[0m"
    exit 1
fi

# Parse ALLOWED_IPS
ALLOWED_IPS=()
IP_LINE=$(echo "$LOCK_CONFIG" | grep "ALLOWED_IPS=")

if [[ "$IP_LINE" =~ ALLOWED_IPS=\((.*)\) ]]; then
    IP_CONTENT="${BASH_REMATCH[1]}"
    IP_CONTENT=$(echo "$IP_CONTENT" | tr -d '"' | tr -d "'")
    IP_CONTENT=$(echo "$IP_CONTENT" | tr '\n' ' ' | sed 's/  */ /g')
    IFS=' ' read -ra ALLOWED_IPS <<< "$IP_CONTENT"
fi

# Parse LICENSE_KEY
LICENSE_KEY=""
KEY_LINE=$(echo "$LOCK_CONFIG" | grep "LICENSE_KEY=")

if [[ "$KEY_LINE" =~ LICENSE_KEY=\"([^\"]+)\" ]]; then
    LICENSE_KEY="${BASH_REMATCH[1]}"
fi

# Get current server IP - FORCE IPv4 ONLY
MY_IP=""
if command -v curl &> /dev/null; then
    # Force IPv4 only
    MY_IP=$(curl -s --max-time 3 -4 ifconfig.me 2>/dev/null)
    if [ -z "$MY_IP" ]; then
        MY_IP=$(curl -s --max-time 3 ipv4.icanhazip.com 2>/dev/null)
    fi
fi

# If still no IP, try other methods
if [ -z "$MY_IP" ]; then
    # Extract only IPv4 from hostname
    ALL_IPS=$(hostname -I 2>/dev/null || echo "")
    MY_IP=$(echo "$ALL_IPS" | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) print $i}' | head -1)
fi

if [ -z "$MY_IP" ]; then
    MY_IP="UNKNOWN"
fi

MY_IP=$(echo "$MY_IP" | xargs)

# Check if current IP is in allowed list
IP_ALLOWED=0
for allowed_ip in "${ALLOWED_IPS[@]}"; do
    allowed_ip=$(echo "$allowed_ip" | xargs)
    if [[ "$allowed_ip" == "$MY_IP" ]]; then
        IP_ALLOWED=1
        break
    fi
done

# If IP not allowed, show error and exit
if [[ $IP_ALLOWED -eq 0 ]]; then
    echo -e "\033[1;31m"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║             ACCESS DENIED - WRONG IP!            ║"
    echo "╠══════════════════════════════════════════════════╣"
    echo "║  Your Server IP: $MY_IP                    ║"
    echo "║                                                  ║"
    echo "║  This IP is not authorized to run this script.   ║"
    echo "║  Please contact the script owner.                ║"
    echo "║                                                  ║"
    echo "║  Telegram: https://t.me/Zero_Free_Vpn.           ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "\033[0m"
    exit 1
fi

# Ask for license key
echo -e "\033[1;36m"
echo "╔══════════════════════════════════════════════════╗"
echo "║                 LICENSE VERIFICATION             ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  Server IP: $MY_IP                         ║"
echo "║  Status: ✓ IP Verified                           ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "\033[0m"

echo -n "Enter License Key: "
read -s USER_KEY
echo ""
USER_KEY=$(echo "$USER_KEY" | xargs)

if [[ "$USER_KEY" != "$LICENSE_KEY" ]]; then
    echo -e "\n\033[1;31m"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║           INVALID LICENSE KEY!                   ║"
    echo "╠══════════════════════════════════════════════════╣"
    echo "║  Contact owner for valid license key.            ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "\033[0m"
    exit 1
fi

# Success
clear
echo -e "\033[1;32m"
echo "╔══════════════════════════════════════════════════╗"
echo "║         AUTHENTICATION SUCCESSFUL!               ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  IP: $MY_IP ✓                              ║"
echo "║  License: ✓                                      ║"
echo "║  Starting installation...                        ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "\033[0m"
sleep 2

# Run installation with cache prevention
INSTALL_URL="https://raw.githubusercontent.com/zawtunwai/maungthunya-vip/main/install.sh?t=$(date +%s)"
bash <(curl -s -H "Cache-Control: no-cache" "$INSTALL_URL")
