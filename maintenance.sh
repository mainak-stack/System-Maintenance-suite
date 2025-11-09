#!/bin/bash

# --- Configuration ---
# Path to the scripts
SCRIPT_DIR=$(pwd)

# Main log file
LOG_FILE="system_maintenance.log"
# ---------------------

# --- Ensure log file is writeable ---
touch "$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "ERROR: Cannot write to log file $LOG_FILE."
    echo "Please run this script with sudo or change log file permissions."
    exit 1
fi

# --- Logging Function ---
log_message() {
    echo "$(date +"%Y-%m-%d %T") - SUITE - $1" >> $LOG_FILE
}

# --- Function to display the menu ---
show_menu() {
    echo "============================="
    echo " System Maintenance Suite"
    echo "============================="
    echo "1. Run System Backup"
    echo "2. Run System Updates & Cleanup (Requires sudo)"
    echo "3. Run Log Monitor"
    echo "4. View Maintenance Log"
    echo "q. Quit"
    echo "-----------------------------"
    echo -n "Please enter your choice: "
}

# --- Main Script Loop ---
while true; do
    show_menu
    read -r choice

    case $choice in
        1)
            echo "Running Backup Script..."
            log_message "User selected: Run Backup"
            ./backup.sh
            if [ $? -ne 0 ]; then
                log_message "ERROR: backup.sh encountered an error."
                echo "ERROR: Backup script failed. Check $LOG_FILE for details."
            fi
            echo "Press [Enter] to continue..."
            read -r
            ;;
        2)
            echo "Running Update & Cleanup Script..."
            log_message "User selected: Run Updates"
            # Check for sudo before running
            if [ "$EUID" -ne 0 ]; then
                echo "This option requires sudo privileges. Trying to run with sudo..."
                sudo ./update.sh
            else
                ./update.sh
            fi
            
            if [ $? -ne 0 ]; then
                log_message "ERROR: update.sh encountered an error."
                echo "ERROR: Update script failed. Check $LOG_FILE for details."
            fi
            echo "Press [Enter] to continue..."
            read -r
            ;;
        3)
            echo "Running Log Monitoring Script..."
            log_message "User selected: Run Log Monitor"
            ./monitor.sh
            if [ $? -ne 0 ]; then
                log_message "ERROR: monitor.sh encountered an error."
                echo "ERROR: Monitor script failed. Check $LOG_FILE for details."
            fi
            echo "Press [Enter] to continue..."
            read -r
            ;;
        4)
            echo "Displaying Maintenance Log..."
            log_message "User selected: View Log"
            # Use 'less' for easy viewing
            less "$LOG_FILE"
            ;;
        q|Q)
            echo "Exiting."
            log_message "User exited the suite."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            log_message "Invalid menu option: $choice"
            sleep 1
            ;;
    esac
    clear # Clear the screen for the next menu display
done

exit 0
