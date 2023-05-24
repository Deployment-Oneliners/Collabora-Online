#!/bin/bash
# Run with:
# chmod +x src/backup/manage_daily_backup.sh
# src/backup/./manage_daily_backup.sh
source src/GLOBAL_VARS.sh
source src/backup/exponential_backups.sh

create_backup_directory() {
  mkdir -p "$BACKUP_PATH"
  if [[ ! -d "$BACKUP_PATH/" ]]; then
    echo "Error, backup path:$BACKUP_PATH not found."
    exit
  fi
}

# Create a backup.
create_a_nextcloud_backup() {
  local todays_date="$1"
  src/backup/./export_data -a -b -c -d

  # Create the array with filenames that are to be deleted.
  local filenames_to_be_deleted
  get_backup_filenames_of_date filenames_to_be_deleted "$BACKUP_PATH" "$BACKUP_EXTENSION_WO_DOT" "$todays_date"
  declare -p filenames_to_be_deleted

  # Assert the backup exists.
  if [ ${#filenames_to_be_deleted[@]} -lt 1 ]; then
    echo "No backup file was found."
    exit
  fi
}

apply_exponential_backup_filter() {
  local todays_date="$1"

  # Create the array with dates of backup files.
  local backup_dates
  get_backup_dates "$BACKUP_PATH" "$BACKUP_EXTENSION_WO_DOT" backup_dates
  declare -p backup_dates
  # Run the exponential backup filter.
  local inverse="false" # Do not delete the files to keep in exponential curve.
  delete_unwanted_backups "$todays_date" "$inverse" "$BACKUP_PATH" "$BACKUP_EXTENSION_WO_DOT" "${backup_dates[@]}"
}

# Run the functions.
create_backup_directory
TODAYS_DATE=$(date '+%Y%m%d')
create_a_nextcloud_backup "$TODAYS_DATE"

apply_exponential_backup_filter "$TODAYS_DATE"
