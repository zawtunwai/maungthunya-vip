#!/bin/bash

# Installer Script for MAUNG THUN YA SSH Manager
# GitHub: https://github.com/zawtunwai/maungthunya-vip

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=================================${NC}"
echo -e "${GREEN}မောင်သုည SSH Manager Installer${NC}"
echo -e "${YELLOW}=================================${NC}"

# Check root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root${NC}" 
   exit 1
fi

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
apt update -y && apt upgrade -y

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
apt install -y curl wget net-tools lsb-release python3 screen psmisc lsof

# Download menu script
echo -e "${YELLOW}Downloading menu script...${NC}"
wget -O /usr/local/bin/menu "https://raw.githubusercontent.com/zawtunwai/maungthunya-vip/main/menu.sh?t=$(date +%s)"

# Make executable
chmod +x /usr/local/bin/menu
# REMOVED: chmod +x /usr/local/bin/menu.sh  # ဒီစာကြောင်း ဖျက်လိုက်ပါ

# Create alias
echo -e "${YELLOW}Creating alias...${NC}"
echo 'alias menu="/usr/local/bin/menu"' >> /root/.bashrc
echo 'alias menu="/usr/local/bin/menu"' >> /root/.profile
source /root/.bashrc

# Create backup of original SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}=================================${NC}"
echo -e "${YELLOW}Usage:${NC}"
echo -e "  Type ${GREEN}menu${NC} to start the manager"
echo -e "  Or run: ${GREEN}bash /usr/local/bin/menu${NC}"
echo -e "${GREEN}=================================${NC}"

# AUTO START MENU AFTER INSTALLATION (OPTIONAL)
echo ""
read -p "Start menu now? (y/n): " start_now
if [[ "$start_now" == "y" || "$start_now" == "Y" ]]; then
    echo -e "${YELLOW}Starting menu...${NC}"
    bash /usr/local/bin/menu
fi
