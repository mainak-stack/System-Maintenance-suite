#!/bin/bash

# --- Configuration ---
# Log file to monitor
MONITOR_LOG="/var/log/syslog" 

# Keywords to search for (case-insensitive)
KEYWORDS="ERROR|Failed|Critical"

# Log file for this script
LOG_FILE="system_maintenance.log"
# ---------------------

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %T") - MONITOR - $1" >> $LOG_FILE
}

# --- Error Handling ---
# Check if log file exists
if [ ! -f "$MONITOR_LOG" ]; then
    log_message "ERROR: Log file $MONITOR_LOG not found."
    echo "ERROR: Log file $MONITOR_LOG not found."
    exit 1
fi

# --- Main Monitoring Process ---
log_message "Starting log monitoring for keywords: $KEYWORDS"
echo "Scanning $MONITOR_LOG for keywords: $KEYWORDS..."

# Search for keywords, ignoring case ('-i')
# We pipe to 'cat' to avoid grep exiting with code 1 if no matches are found
MATCHES=$(grep -i -E "$KEYWORDS" "$MONITOR_LOG" | cat)

if [ -z "$MATCHES" ]; then
    log_message "No critical issues found."
    echo "Scan complete. No critical issues found."
else
    log_message "ALERT: Critical keywords found in $MONITOR_LOG."
    echo "--- ALERT: Critical keywords found in $MONITOR_LOG ---"
    echo "$MATCHES"
    echo "----------------------------------------------------"
fi

echo "------------------------"
