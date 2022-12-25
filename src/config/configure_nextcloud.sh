#!/usr/bin/env bash

#Finish the installation of NextCloud and configuring the
#admin account credentials.
setup_admin_account_on_snap_nextcloud() {
  local admin_username
  local admin_pwd
  admin_username="$1"
  admin_pwd="$2"

  # Check if admin username and pwd are given.
  assert_is_non_empty_string "$admin_username"
  assert_is_non_empty_string "$admin_pwd"

  # TODO: Check if username and password are already set.
  green_msg "\n======================================================\n"
  green_msg "    Username:${admin_username}     Password:${admin_pwd}   "
  green_msg "\n======================================================\n"

  printf "\nApplying credentials values to NextCloud admin account...\n"

  local output
  output=$(sudo /snap/bin/nextcloud.manual-install "${admin_username}" "${admin_pwd}")
  sleep 5
  echo "output=$output"

  # TODO: verify the nextcloud server is live, and that the credentials work.
  verify_nextcloud_creds_are_set_correct
}

verify_nextcloud_creds_are_set_correct() {
  # Verify nextcloud configuration and username is set successfully.

  # Expected:
  # values to NextCloud admin account...
  # Nextcloud was successfully installed

  # Error if the username is already set:
  #Command "maintenance:install" is not defined.

  #Did you mean one of these?
  #app:install
  #maintenance:data-fingerprint
  #maintenance:mimetype:update-db
  #maintenance:mimetype:update-js
  #maintenance:mode
  #maintenance:repair
  #maintenance:repair-share-owner
  #maintenance:theme:update
  #maintenance:update:htaccess
  echo "TODO: verify nextcloud cred setting."
}

#Configure the NextCloud port to be used.
set_nextcloud_port() {
  local nextcloud_port
  nextcloud_port="$1"

  yellow_msg "\nConfiguring NextCloud, please wait...\n"
  sudo snap set nextcloud ports.http="${nextcloud_port}"

  # TODO: verify nextcloud port is set successfully.
}
