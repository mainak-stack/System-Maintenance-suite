#!/bin/bash

# Log file for this script
LOG_FILE="system_maintenance.log"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %T") - UPDATE - $1" >> $LOG_FILE
}

# --- Check for root/sudo privileges ---
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root or with sudo."
  log_message "ERROR: Script not run as root."
  exit 1
fi

log_message "Starting system update and cleanup..."
echo "Starting system update and cleanup..."

# --- Update Package Lists ---
echo "Updating package lists..."
apt-get update -y
if [ $? -ne 0 ]; then
    log_message "ERROR: 'apt-get update' failed."
    echo "ERROR: 'apt-get update' failed."
    exit 1
fi
log_message "Package lists updated."

# --- Upgrade Packages ---
echo "Upgrading installed packages..."
apt-get upgrade -y
if [ $? -ne 0 ]; then
    log_message "ERROR: 'apt-get upgrade' failed."
    echo "ERROR: 'apt-get upgrade' failed."
    exit 1
fi
log_message "Packages upgraded."

# --- Clean Up ---
echo "Removing unnecessary packages..."
apt-get autoremove -y
log_message "Unnecessary packages removed."

echo "Cleaning up old package cache..."
apt-get clean
log_message "Package cache cleaned."

log_message "SUCCESS: System update and cleanup finished."
echo "System update and cleanup finished."
echo "------------------------"
