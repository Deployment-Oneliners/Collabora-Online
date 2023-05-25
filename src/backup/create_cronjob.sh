#!/bin/bash
# Run with:
# chmod +x src/backup/create_cronjob.sh
# src/backup/./create_cronjob.sh

# TODO: remove need for sudo for backup script, then call from regular user
# such that the regular user does not need to be passed from the one who called
# the sudo, like this.
if [ "$SUDO_USER" ]; then
  echo "$SUDO_USER" >"username.txt"
  source src/GLOBAL_VARS.sh
else
  echo "Error, the user that called this sudo shell is not known."
  exit
fi

# Clone the GitHub repository
if [ ! -d "$GIT_DIR_FOR_CRON" ]; then
  git clone https://github.com/HiveMinds/Collabora-Online.git "$GIT_DIR_FOR_CRON"
else
  rm -r "$GIT_DIR_FOR_CRON"
  if [ -d "$GIT_DIR_FOR_CRON" ]; then
    echo "Error, $GIT_DIR_FOR_CRON dir still exists."
    exit
  fi
  git clone https://github.com/HiveMinds/Collabora-Online.git "$GIT_DIR_FOR_CRON"
  if [ ! -d "$GIT_DIR_FOR_CRON" ]; then
    echo "Error, $GIT_DIR_FOR_CRON dir still exists."
    exit
  fi
fi
echo "$SUDO_USER" >"$GIT_DIR_FOR_CRON/username.txt"

# Assert manage_daily_backup.sh script exists.
backup_manager_path="$GIT_DIR_FOR_CRON/src/backup/manage_daily_backup.sh"
if [ ! -f "$backup_manager_path" ]; then
  echo "Error, $backup_manager_path file not found."
  exit
fi
chmod +x "$backup_manager_path"

backup_manager_command="cd $GIT_DIR_FOR_CRON && src/backup/./manage_daily_backup.sh"
# Check if the cron job already exists
if sudo crontab -l | grep -q "$backup_manager_command"; then
  echo "Cron job already exists. Skipping setup."
else
  # Add the cron job entry to run every day at 02:01 midnight.
  (
    sudo crontab -l 2>/dev/null
    echo "1 2 * * * $backup_manager_command"
  ) | sudo crontab -
  echo "Cron job successfully set up."
fi

# Assert the cronjob was added successfully.
if sudo crontab -l | grep -q "$backup_manager_command"; then
  echo ""
else
  echo "Error, cronjob was not found."
  exit 5
fi
