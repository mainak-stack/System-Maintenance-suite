#!/bin/bash

# Define the single log file
MASTER_LOG="system_maintenance.log"

# Get the directory this script is in
SCRIPT_DIR=$(dirname "$0")

# Define paths to the other scripts
BACKUP_SCRIPT="$SCRIPT_DIR/run_backup.sh"
UPDATE_SCRIPT="$SCRIPT_DIR/run_updates.sh"
MONITOR_SCRIPT="$SCRIPT_DIR/check_logs.sh"

# Function to log suite events
log_event() {
    echo "$(date +"%Y-%m-%d %T") - SUITE - $1" >> "$MASTER_LOG"
}

# Function to display the main menu
display_menu() {
    clear # Clear the screen for a clean menu
    echo "================================="
    echo " System Administration Suite"
    echo "================================="
    echo " 1. Run System Backup"
    echo " 2. Run System Updates"
    echo " 3. Check System Logs"
    echo " 4. View Maintenance Log"
    echo " Q. Quit"
    echo "---------------------------------"
}

# --- Menu Action Functions ---

handle_backup() {
    echo "Starting backup process..."
    log_event "User selected: Run Backup"
    if ! "$BACKUP_SCRIPT"; then
        log_event "ERROR: Backup script failed."
        echo "ERROR: Backup script encountered a problem."
    fi
}

handle_updates() {
    echo "Starting update process..."
    log_event "User selected: Run Updates"
    # This script must be run as root
    if [ "$EUID" -ne 0 ]; then
        echo "Relaunching update script with sudo..."
        sudo "$UPDATE_SCRIPT"
    else
        "$UPDATE_SCRIPT"
    fi
    
    if [ $? -ne 0 ]; then
        log_event "ERROR: Update script failed."
        echo "ERROR: Update script encountered a problem."
    fi
}

handle_monitoring() {
    echo "Starting log check..."
    log_event "User selected: Check Logs"
    # This script also needs sudo to read /var/log/dmesg
    if [ "$EUID" -ne 0 ]; then
        echo "Relaunching monitor script with sudo..."
        sudo "$MONITOR_SCRIPT"
    else
        "$MONITOR_SCRIPT"
    fi
    
    if [ $? -ne 0 ]; then
        log_event "ERROR: Monitor script failed."
        echo "ERROR: Monitor script encountered a problem."
    fi
}

view_log() {
    log_event "User selected: View Log"
    if [ -f "$MASTER_LOG" ]; then
        less "$MASTER_LOG"
    else
        echo "Log file not found."
    fi
}

# --- Main Application Loop ---
touch "$MASTER_LOG" # Ensure log file exists
log_event "Maintenance suite started."

while true; do
    display_menu
    echo -n "Select an option: "
    read -r choice

    case $choice in
        1)
            handle_backup
            ;;
        2)
            handle_updates
            ;;
        3)
            handle_monitoring
            ;;
        4)
            view_log
            ;;
        [qQ])
            log_event "Maintenance suite exited."
            echo "Exiting."
            break
            ;;
        *)
            log_event "Invalid menu option: $choice"
            echo "Invalid option. Press [Enter] to try again."
            read -r
            ;;
    esac
    
    if [[ "$choice" != "4" && "$choice" != "q" && "$choice" != "Q" ]]; then
        echo "Press [Enter] to return to the menu..."
        read -r
    fi
done

exit 0
