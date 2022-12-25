#!/usr/bin/env bash

# 0.a Install prerequisites for Nextcloud.
# 0.b Verify prerequisites for Nextcloud are installed.
snap_remove() {
  local snap_package_name="$1"
  yellow_msg "Removing ${snap_package_name}...\\n"
  sudo snap remove --purge "$snap_package_name"

  verify_snap_removed "$snap_package_name"
}

# Verifies snap package is removed.
verify_snap_removed() {
  local snap_package_name="$1"

  # Determine if snap package is installed or not.
  local snap_pckg_exists
  snap_pckg_exists=$(snap list | grep "${snap_package_name}")

  # Throw error if snap package is not yet installed.
  if [ "$snap_pckg_exists" == "" ]; then
    printf "==========================\\n"
    green_msg "Verified the snap package ${snap_package_name} is removed.\\n"
    printf "==========================\\n\\n"
  else
    printf "======================\\n"
    red_msg "Error, the snap package ${snap_package_name} is still installed.\\n"
    printf "======================\\n"
    exit 3 # TODO: update exit status.
  fi
}
