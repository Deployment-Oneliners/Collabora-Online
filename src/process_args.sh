#!/usr/bin/env bash
# Parses the CLI arguments given to this file, and installs Nextcloud over Tor
# accordingly.

# Load used functions, from path relative to this main.sh.
# shellcheck source=/dev/null
source src/cli_logger.sh
source src/config/configure_khal.sh
source src/config/configure_nextcloud.sh
source src/config/configure_tor.sh
source src/config/configure_vdirsyncer.sh
source src/config/helper_tor_parsing.sh
source src/config/setup_ssl.sh
source src/helper.sh
source src/install/install_android_apps.sh
source src/install/install_apk.sh
source src/install/install_apt.sh
source src/install/install_pip.sh
source src/install/install_snap.sh
source src/install/prereq_nextcloud.sh
source src/run_tor/ensure_tor_runs.sh
source src/uninstall/uninstall_apk.sh
source src/verification/assert_tor_settings.sh

# Tor configuration settings
#Setup variables (change values if you need)
TOR_SERVICE_DIR=/var/lib/tor
NEXTCLOUD_HIDDEN_SERVICE_DIR=nextcloud
NEXTCLOUD_HIDDEN_SERVICE_PATH="$TOR_SERVICE_DIR/$NEXTCLOUD_HIDDEN_SERVICE_DIR"
HIDDEN_SERVICE_PORT=443
LOCAL_NEXTCLOUD_PORT=81
TORRC_FILEPATH=/etc/tor/torrc
TOR_LOG_FILEPATH="tor_log.txt"

USERNAME=$(whoami)
ROOT_CA_DIR="/home/$USERNAME"
ROOT_CA_PEM_PATH="$ROOT_CA_DIR/$CA_PUBLIC_KEY_FILENAME"
VDIRSYNCER_CONFIG_PATH="/home/$USERNAME/.config/vdirsyncer"
VDIRSYNCER_CONFIG_FILENAME="config"
VDIRSYNCER_STATUS_PATH="/home/$USERNAME/.config/vdirsyncer/status/"
VDIRSYNCER_CONTACTS_PATH="/home/$USERNAME/Documents/Contacts/"
VDIRSYNCER_CALENDAR_PATH="/home/$USERNAME/Documents/Calendar/"
KHAL_CONFIG_PATH="/home/$USERNAME/.config/khal"
KHAL_CONFIG_FILENAME="config"

# Installs and partially sets up Nextcloud and Tor.
setup_nextcloud() {
  local configure_nextcloud_flag="$1"
  local default_nextcloud_username="$2"
  local default_nextcloud_password="$3"
  local install_tor_nextcloud_flag="$4"
  local nextcloud_pwd_flag="$5"
  local nextcloud_username_flag="$6"

  # Set Nextcloud password without displaying it in terminal.
  # Used if the user passes: -np or --nextcloud-password to CLI.
  if [ "$nextcloud_pwd_flag" == "true" ] || [ "$calendar_client_flag" == "true" ]; then
    echo -n Nextcloud Password:
    read -r -s nextcloud_password
    echo
    assert_is_non_empty_string "${nextcloud_password}"
  fi

  # Install Tor and Nextcloud.
  # Used if the user passes: -i or --install-tor-nextcloud to CLI.
  if [ "$install_tor_nextcloud_flag" == "true" ]; then
    install_tor_and_nextcloud
  fi

  # Configure Nextcloud
  # Used if the user passes: -cn or --configure-nextcloud to CLI.
  if [ "$configure_nextcloud_flag" == "true" ] || [ "$calendar_client_flag" == "true" ]; then

    # Get the nextcloud username and password.
    if [ "$nextcloud_username_flag" == "false" ]; then
      # Specify variable defaults
      nextcloud_username="$default_nextcloud_username"
    fi
    if [ "$nextcloud_pwd_flag" == "false" ] && [ "$calendar_client_flag" == "false" ]; then
      # Specify variable defaults
      nextcloud_password="$default_nextcloud_password"
    fi
  fi
  if [ "$configure_nextcloud_flag" == "true" ]; then
    verify_snap_installed "nextcloud"
    setup_admin_account_on_snap_nextcloud "$nextcloud_username" "$nextcloud_password"
    set_nextcloud_port "$LOCAL_NEXTCLOUD_PORT"
  fi
}

setup_tor_for_nextcloud() {
  local configure_tor_for_nextcloud_flag="$1"
  local get_onion_flag="$2"

  # 6.a Proxify calendar app to go over tor to Nextcloud on client.
  # 6.b Verify calendar app goes over tor to Nextcloudon client.

  # 7.a Install calendar app on android.
  # 7.b Verify calendar app is installed on android.
  # 7.c Proxify calendar app to go over tor to Nextcloud on Android.
  # 7.b Verify calendar app goes over tor to Nextcloud on Android.

  # Configure tor to create and host onion domain for nextcloud.
  # Used if the user passes: -ct or --configure_tor to CLI.
  if [ "$configure_tor_for_nextcloud_flag" == "true" ]; then
    verify_apt_installed "tor"
    configure_tor "$HIDDEN_SERVICE_PORT" "$LOCAL_NEXTCLOUD_PORT" "$NEXTCLOUD_HIDDEN_SERVICE_PATH" "$TORRC_FILEPATH"

    # Ensures an onion url is created for Nextcloud.
    start_tor_and_check_onion_url "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname" "$TOR_LOG_FILEPATH"
    assert_onion_url_exists_in_hostname "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname"
    local onion_address
    onion_address=$(sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname")

    add_onion_to_nextcloud_trusted_domain "$onion_address"
  fi

  # Used if the user passes: -o or --get-onion to CLI.
  if [ "$get_onion_flag" == "true" ]; then
    verify_apt_installed "tor"
    sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname"
  fi
}

start_tor() {
  local setup_boot_script_flag="$1"
  local start_tor_flag="$2"
  local set_https_flag="$3"

  # Verify tor is installed.
  verify_apt_installed "tor"

  # Order is important.
  if [ "$set_https_flag" == "true" ]; then
    assert_onion_url_exists_in_hostname "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname"

    local onion_address
    onion_address=$(sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname")
    setup_tor_ssl "$onion_address"
  fi

  # Start tor.
  if [ "$start_tor_flag" == "true" ]; then
    # TODO: make this a background process after which the code can continue.
    start_and_monitor_tor_connection
  fi

  # Used if the user passes: -b or --boot to CLI.
  if [ "$setup_boot_script_flag" == "true" ]; then
    echo "TODO: setup_boot_script_flag"
  fi
}

configure_calendar() {
  local calendar_client_flag="$1"
  local calendar_phone_flag="$2"
  local calendar_server_flag="$3"

  verify_snap_installed "nextcloud"

  if [ "$calendar_server_flag" == "true" ]; then
    enable_calendar_app
  fi

  if [ "$calendar_client_flag" == "true" ]; then
    # Install vdirsyncer.
    ensure_pip_pkg "vdirsyncer"

    # Install khal.
    ensure_apt_pkg "khal"

    # Get the onion url for vdirsyncer.
    assert_onion_url_exists_in_hostname "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname"
    local onion_address
    onion_address=$(sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname")

    # Configure vdirsyncer.
    create_vdirsyncer_config "$nextcloud_username" "$nextcloud_password" "$onion_address" "$VDIRSYNCER_CONFIG_FILENAME" "$VDIRSYNCER_CONFIG_PATH" "$VDIRSYNCER_CALENDAR_PATH" "$VDIRSYNCER_CONTACTS_PATH" "$VDIRSYNCER_STATUS_PATH" "$ROOT_CA_PEM_PATH"

    # Configure khal.
    create_khal_config "$KHAL_CONFIG_FILENAME" "$KHAL_CONFIG_PATH" "$VDIRSYNCER_CALENDAR_PATH" "$VDIRSYNCER_CONTACTS_PATH"
  fi

  if [ "$calendar_phone_flag" == "true" ]; then
    echo "TODO: setup phone automatically."
  fi
}

reinstall_android_apps() {
  local android_app_reinstall_flag
  android_app_reinstall_flag="$1"
  local csv_app_list
  csv_app_list="$2"

  if [ "$android_app_reinstall_flag" == "true" ]; then
    apps_are_supported "$csv_app_list"

    IFS=, read -r -a arr <<<"${csv_app_list}"
    echo "${arr[@]}"
    for app_name in "${arr[@]}"; do
      if [ "$app_name" == "Orbot" ]; then
        echo "(Re)-Installing: $app_name"
        re_install_orbot_apk
      elif [ "$app_name" == "DAVx5" ]; then
        echo "(Re)-Installing: $app_name"
        re_install_davx5_apk
      fi
    done
  fi
}

configure_android_apps() {
  local android_app_configure_flag
  android_app_configure_flag="$1"
  local csv_app_list
  csv_app_list="$2"

  if [ "$android_app_configure_flag" == "true" ]; then
    apps_are_supported "$csv_app_list"

    # Get the Nextcloud password to configure Android apps with it.
    echo -n Nextcloud Password:
    read -r -s nextcloud_password
    echo
    assert_is_non_empty_string "${nextcloud_password}"
    echo "TODO: call Android configure with Nextcloud."

    # Configure the selected apps.
    IFS=, read -r -a arr <<<"${csv_app_list}"
    echo "${arr[@]}"
    for app_name in "${arr[@]}"; do
      if [ "$app_name" == "Orbot" ]; then
        echo "TODO: (Re)-Configuring: $app_name"
      elif [ "$app_name" == "DAVx5" ]; then
        echo "TODO: (Re)-Configuring: $app_name"
      fi
    done
  fi
}
