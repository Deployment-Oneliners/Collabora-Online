#!/bin/bash
# shellcheck disable=SC2034

# Specify apps that are supported in this project.
SUPPORTED_APPS=("Orbot" "DAVx5")

# Tor configuration settings
#Setup variables (change values if you need)
TOR_SERVICE_DIR=/var/lib/tor
NEXTCLOUD_HIDDEN_SERVICE_DIR=nextcloud
NEXTCLOUD_HIDDEN_SERVICE_PATH="$TOR_SERVICE_DIR/$NEXTCLOUD_HIDDEN_SERVICE_DIR"

TORRC_FILEPATH="/etc/tor/torrc"
TOR_LOG_FILEPATH="tor_log.txt"

# Read username from file or get it from the user that called su.
USERNAME="$(cat "username.txt")"
if [ "$USERNAME" == "" ]; then
  if [ "$SUDO_USER" ]; then
    USERNAME="$SUDO_USER"
  else
    echo "Error, the user that called this sudo shell is not known."
    exit
  fi
fi

ROOT_CA_DIR="/home/$USERNAME"
ROOT_CA_PEM_PATH="$ROOT_CA_DIR/$CA_PUBLIC_KEY_FILENAME"
VDIRSYNCER_CONFIG_PATH="/home/$USERNAME/.config/vdirsyncer"
VDIRSYNCER_CONFIG_FILENAME="config"
VDIRSYNCER_STATUS_PATH="/home/$USERNAME/.config/vdirsyncer/status/"
VDIRSYNCER_CONTACTS_PATH="/home/$USERNAME/Documents/Contacts/"
VDIRSYNCER_CALENDAR_PATH="/home/$USERNAME/Documents/Calendar/"
KHAL_CONFIG_PATH="/home/$USERNAME/.config/khal"
KHAL_CONFIG_FILENAME="config"

SSL4TOR_DIR="ssl4tor"

# Backup configuration
BASE=2
MAX_POWER=16
WINDOW_FACTOR=8 # Keep a backup of max 8*2*16= 256 days old.

BACKUP_PATH="/home/$USERNAME/Nextcloud/backups"
BACKUP_EXTENSION_WO_DOT="tar.gz"
GIT_DIR_FOR_CRON="/home/$USERNAME/collabora-online"
