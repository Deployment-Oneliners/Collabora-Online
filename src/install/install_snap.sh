#!/usr/bin/env bash

# Usage: ensure_snap_pkg <PKG>
# Takes the name of a snap package to install if not already installed.
ensure_snap_pkg() {
  local snap_package_name
  snap_package_name="${1}"

  # printf "\\n\\n Checking ${snap_package_name} in the system...\\n\\n\\n"
  printf '\\n\\n Checking %s in the system...\\n\\n\\n' "${snap_package_name}".

  # Determine if snap package is installed or not.
  local snap_pckg_exists
  snap_pckg_exists=$(snap list | grep "${snap_package_name}")

  # Install snap package if snap package is not yet installed.
  if [ "$snap_pckg_exists" == "" ]; then
    printf "=============================\\n"
    red_msg " ${snap_package_name} is not installed. Installing now.\\n"
    printf "==============================\\n\\n"
    sudo snap install "${snap_package_name}"
  else
    printf "=========================\\n"
    yellow_msg " ${snap_package_name} is installed\\n"
    printf "=========================\\n"
  fi

  verify_snap_installed "${snap_package_name}"
}

# Verifies snap package is installed.
verify_snap_installed() {
  local snap_package_name="$1"

  # Determine if snap package is installed or not.
  local snap_pckg_exists
  snap_pckg_exists=$(snap list | grep "${snap_package_name}")

  # Throw error if snap package is not yet installed.
  if [ "$snap_pckg_exists" == "" ]; then
    printf "==========================\\n"
    red_msg "Error, the snap package ${snap_package_name} is not installed.\\n"
    printf "==========================\\n\\n"
    exit 3 # TODO: update exit status.
  else
    printf "======================\\n"
    green_msg "Verified snap package ${snap_package_name} is installed.\\n"
    printf "======================\\n"
  fi
}
