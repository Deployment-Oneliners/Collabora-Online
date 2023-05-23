#!/usr/bin/env bash

#Finish the installation of NextCloud and configuring the
#admin account credentials.
setup_admin_account_on_snap_nextcloud() {
  local admin_username="$1"
  local admin_pwd="$2"

  # Check if admin username and pwd are given.
  assert_is_non_empty_string "$admin_username" "admin_username"
  assert_is_non_empty_string "$admin_pwd" "admin_pwd"

  # TODO: Check if username and password are already set.
  green_msg "\n======================================================\n"
  green_msg "    Username:${admin_username}     Password:${admin_pwd}   "
  green_msg "\n======================================================\n"

  printf "\nApplying credentials values to NextCloud admin account...\n"

  echo "Only do this when it is not yet done."
  # local output
  #output=$(sudo /snap/bin/nextcloud.manual-install "${admin_username}" "${admin_pwd}")
  # sleep 5
  #echo "output=$output"

  # Remove mysql
  #sudo systemctl stop mysql -y
  sudo systemctl stop mysql
  #sudo apt-get purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-* -y
  apt_remove mysql-server
  apt_remove mysql-client
  apt_remove mysql-common
  apt_remove "mysql-server-core-*"
  apt_remove "mysql-client-core-*"
  sudo rm -rf /etc/mysql /var/lib/mysql
  sudo apt autoremove -y >>/dev/null 2>&1
  sudo apt autoclean >>/dev/null 2>&1

  # Re-install mysql
  # sudo apt install mysql-server -y
  ensure_apt_pkg "mysql-server"
  sudo systemctl start mysql.service

  # Set mysql pwd
  read -p "Before change password"
  sudo mysql --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'mysql_password';"

  # Install and configure Nextcloud.
  # TODO: verify it is not: --database-host="127.0.01" \
  sudo nextcloud.occ maintenance:install \
    --database="mysql" \
    --database-name="nextcloud" \
    --database-user="root" \
    --database-host="127.0.0.1" \
    --database-pass="mysql_password" \
    --data-dir="/var/snap/nextcloud/common/nextcloud/data" \
    --admin-user="root" \
    --admin-pass="mysql_password"

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
  local nextcloud_port="$1"
  local use_https="$2"

  if [[ "$use_https" == "true" ]]; then
    yellow_msg "\nConfiguring https NextCloud:${nextcloud_port} port, please wait...\n"
    sudo snap set nextcloud ports.https="${nextcloud_port}"
  else
    yellow_msg "\nConfiguring http NextCloud:${nextcloud_port} port, please wait...\n"
    sudo snap set nextcloud ports.http="${nextcloud_port}"
  fi
  # TODO: verify nextcloud port is set successfully.

  #The website should display:
  #Secure Connection Failed

  #An error occurred during a connection to localhost:81. SSL received a
  # record that exceeded the maximum permissible length.

  # Error code: SSL_ERROR_RX_RECORD_TOO_LONG

}
