#!/bin/bash

LOG_FILE="system_maintenance.log"

# Function to log messages
log_event() {
    echo "$(date +"%Y-%m-%d %T") - UPDATE - $1" >> "$LOG_FILE"
}

# Function to check for root privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_event "ERROR: Script not run as root."
        echo "ERROR: This script requires sudo/root privileges to run."
        exit 1
    fi
}

run_package_updates() {
    echo "Updating package lists..."
    if ! apt update -y; then
        log_event "ERROR: 'apt update' failed."
        echo "ERROR: Failed to update package lists."
        return 1
    fi
    log_event "Package lists updated."
}

run_package_upgrades() {
    echo "Upgrading installed packages..."
    if ! apt upgrade -y; then
        log_event "ERROR: 'apt upgrade' failed."
        echo "ERROR: Failed to upgrade packages."
        return 1
    fi
    log_event "Packages upgraded."
}

run_system_cleanup() {
    echo "Removing unused packages..."
    if ! apt autoremove -y; then
        log_event "ERROR: 'apt autoremove' failed."
        return 1
    fi
    log_event "Unused packages removed."

    echo "Cleaning package cache..."
    if ! apt clean; then
        log_event "ERROR: 'apt clean' failed."
        return 1
    fi
    log_event "Package cache cleaned."
}

# --- Main Execution ---
check_root
log_event "Update script started."

run_package_updates
run_package_upgrades
run_system_cleanup

log_event "SUCCESS: System update and cleanup finished."
echo "System update and cleanup finished."
