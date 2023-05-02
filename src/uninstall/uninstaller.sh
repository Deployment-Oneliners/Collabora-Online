#!/usr/bin/env bash

# shellcheck disable=SC1091
source src/uninstall/remove_snap.sh
source src/uninstall/cleanup.sh

uninstaller() {
  local uninstall_nextcloud_flag="$1"

  if [ "$uninstall_nextcloud_flag" == "true" ]; then
    snap_remove "nextcloud" 1
    remove_installation_artifacts
  fi
}
