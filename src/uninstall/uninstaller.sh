#!/usr/bin/env bash

uninstaller() {
  local uninstall_nextcloud_flag="$1"

  if [ "$uninstall_nextcloud_flag" == "true" ]; then
    snap_remove "nextcloud" 1
  fi
}
