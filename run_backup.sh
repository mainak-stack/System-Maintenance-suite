#!/bin/bash

# --- Configuration ---
SRC_PATH="/home/user/Documents" # <-- UPDATE THIS
DEST_PATH="/mnt/backups"       # <-- UPDATE THIS
LOG_FILE="system_maintenance.log"
# ---------------------

# Function to log messages
log_event() {
    # Appends "timestamp - BACKUP - message" to the log
    echo "$(date +"%Y-%m-%d %T") - BACKUP - $1" >> "$LOG_FILE"
}

# Main function to perform the backup
perform_backup() {
    echo "Starting backup of '$SRC_PATH'..."
    log_event "Backup process initiated for $SRC_PATH."

    # Check if source exists
    if [ ! -d "$SRC_PATH" ]; then
        echo "ERROR: Source directory $SRC_PATH does not exist."
        log_event "ERROR: Source directory $SRC_PATH not found."
        return 1
    fi

    # Create backup directory if it doesn't exist
    mkdir -p "$DEST_PATH"

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local archive_file="$DEST_PATH/backup-$timestamp.tar.gz"

    # Create tarball and check for errors
    if ! tar -czf "$archive_file" "$SRC_PATH"; then
        echo "ERROR: Backup failed."
        log_event "ERROR: Failed to create tarball $archive_file."
        return 1
    fi

    echo "Backup successful: $archive_file"
    log_event "SUCCESS: Backup created at $archive_file."
    
    # Clean up old backups (older than 7 days)
    echo "Cleaning up old backups..."
    find "$DEST_PATH" -type f -name "backup-*.tar.gz" -mtime +7 -exec rm {} \;
    log_event "Old backup cleanup complete."
}

# --- Script Entry Point ---
# The 'main' function is called only when the script is executed directly
perform_backup
