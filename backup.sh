#!/bin/bash

# --- Configuration ---
# Directory to back up
SOURCE_DIR="/home/user/Documents" 

# Where to store the backups
BACKUP_DIR="/mnt/backups"

# Log file for this script
LOG_FILE="system_maintenance.log"
# ---------------------

# Create a timestamp (e.g., 2025-11-09)
TIMESTAMP=$(date +"%Y-%m-%d")
FILENAME="backup-$TIMESTAMP.tar.gz"
BACKUP_PATH="$BACKUP_DIR/$FILENAME"

# Logging function
log_message() {
    echo "$(date +"%Y-%m-%d %T") - BACKUP - $1" >> $LOG_FILE
}

# --- Error Handling ---
# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "ERROR: Source directory $SOURCE_DIR does not exist."
    echo "ERROR: Source directory $SOURCE_DIR does not exist."
    exit 1
fi

# Check if backup directory exists, create if not
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        log_message "ERROR: Could not create backup directory $BACKUP_DIR."
        echo "ERROR: Could not create backup directory $BACKUP_DIR."
        exit 1
    fi
fi

# --- Main Backup Process ---
echo "Starting backup of $SOURCE_DIR..."
log_message "Starting backup of $SOURCE_DIR to $BACKUP_PATH"

# Create the compressed archive
# 'c' - create, 'z' - gzip, 'f' - file
tar -czf "$BACKUP_PATH" "$SOURCE_DIR"

# --- Verification and Logging ---
if [ $? -eq 0 ]; then
    log_message "SUCCESS: Backup completed successfully: $FILENAME"
    echo "Backup completed successfully: $FILENAME"
else
    log_message "ERROR: Backup failed."
    echo "ERROR: Backup failed."
fi

# Optional: Remove backups older than 7 days
find "$BACKUP_DIR" -type f -name "backup-*.tar.gz" -mtime +7 -exec rm {} \;
log_message "Old backups removed."

echo "------------------------"
