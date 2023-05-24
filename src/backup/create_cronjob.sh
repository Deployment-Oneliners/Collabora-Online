#!/bin/bash
# Run with:
# chmod +x src/backup/create_cronjob.sh
# src/backup/./create_cronjob.sh
source src/GLOBAL_VARS.sh

# Clone the GitHub repository
# TODO: pull if already cloned.

if [ ! -d "$GIT_DIR_FOR_CRON" ]; then
  git clone https://github.com/HiveMinds/Collabora-Online.git "$GIT_DIR_FOR_CRON"
fi

# Assert manage_daily_backup.sh script exists.
backup_manager_path="$GIT_DIR_FOR_CRON/src/backup/manage_daily_backup.sh"
if [ ! -f "$backup_manager_path" ]; then
  echo "Error, $backup_manager_path file not found."
  exit
fi
chmod +x "$backup_manager_path"

# Check if the cron job already exists
if crontab -l | grep -q "$backup_manager_path"; then
  echo "Cron job already exists. Skipping setup."
else
  # Add the cron job entry to run every day at 01:02 midnight.
  (
    crontab -l 2>/dev/null
    echo "1 2 * * * $backup_manager_path"
  ) | crontab -
  echo "Cron job successfully set up."
fi

# Assert the cronjob was added successfully.
if crontab -l | grep -q "$backup_manager_path"; then
  echo ""
else
  echo "Error, cronjob was not found."
  exit 5
fi
