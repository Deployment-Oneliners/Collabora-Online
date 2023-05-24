#!/bin/bash
# Run with:
# chmod +x src/backup/create_cronjob.sh
# src/backup/./create_cronjob.sh
source src/GLOBAL_VARS.sh

# Clone the GitHub repository
git clone https://github.com/HiveMinds/Collabora-Online.git "$GIT_DIR_FOR_CRON"

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
  # Add the cron job entry
  (
    crontab -l 2>/dev/null
    echo "0 0 * * * $backup_manager_path"
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
