#!/usr/bin/env bash

# shellcheck disable=SC1091
source src/uninstall/remove_snap.sh
source src/uninstall/cleanup.sh

uninstaller() {
  local uninstall_nextcloud_flag="$1"
  local uninstall_tor_flag="$2"

  if [ "$uninstall_nextcloud_flag" == "true" ]; then
    snap_remove "nextcloud" 1
    remove_installation_artifacts
  fi

  if [ "$uninstall_tor_flag" == "true" ]; then
    snap_remove "tor" 1
  fi
}
