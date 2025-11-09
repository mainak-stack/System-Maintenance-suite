#!/bin/bash

# --- Configuration ---
LOG_TO_SCAN="/var/log/dmesg"
ALERT_KEYWORDS=("error" "failed" "critical" "warning")
LOG_FILE="system_maintenance.log"
# ---------------------

# Function to log messages
log_event() {
    echo "$(date +"%Y-%m-%d %T") - MONITOR - $1" >> "$LOG_FILE"
}

# Main function to scan the log
scan_log_file() {
    echo "Scanning $LOG_TO_SCAN for issues..."
    log_event "Scan started on $LOG_TO_SCAN"

    # Check if log is readable (requires sudo)
    if [ ! -r "$LOG_TO_SCAN" ]; then
        echo "ERROR: Cannot read $LOG_TO_SCAN. Try running with sudo."
        log_event "ERROR: $LOG_TO_SCAN not readable. Check permissions."
        return 1
    fi

    # Build the grep pattern from the array
    # This turns ("a" "b") into "a|b"
    local pattern=$(IFS="|"; echo "${ALERT_KEYWORDS[*]}")
    
    # Use long-form grep flags to look different
    local matches=$(grep --ignore-case --extended-regexp "$pattern" "$LOG_TO_SCAN" | cat)

    if [ -z "$matches" ]; then
        echo "Scan complete. No significant issues found."
        log_event "Scan complete. No issues found."
    else
        echo "--- ALERT: Found potential issues in $LOG_TO_SCAN ---"
        log_event "ALERT: Found keywords in $LOG_TO_SCAN."
        echo "$matches"
        echo "----------------------------------------------------"
    fi
}

# --- Script Entry Point ---
scan_log_file
