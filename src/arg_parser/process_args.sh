#!/usr/bin/env bash
# Parses the CLI arguments given to this file, and installs Nextcloud over Tor
# accordingly.

# Load used functions, from path relative to this main.sh.
# shellcheck source=/dev/null

# Installs and partially sets up Nextcloud and Tor.
setup_nextcloud() {
  local configure_nextcloud_flag="$1"
  local local_nextcloud_port="$2"
  local nextcloud_password="$3"
  local nextcloud_username="$4"

  if [ "$configure_nextcloud_flag" == "true" ]; then
    install_tor_and_nextcloud
    verify_snap_installed "nextcloud"
    setup_admin_account_on_snap_nextcloud "$nextcloud_username" "$nextcloud_password"
    set_nextcloud_port "$local_nextcloud_port"
  fi
}

setup_tor_for_nextcloud() {
  local configure_tor_for_nextcloud_flag="$1"
  local get_onion_flag="$2"
  local external_nextcloud_port="$3"
  local local_nextcloud_port="$4"
  local ssl_password="$5"

  # 6.a Proxify calendar app to go over tor to Nextcloud on client.
  # 6.b Verify calendar app goes over tor to Nextcloudon client.

  # 7.a Install calendar app on android.
  # 7.b Verify calendar app is installed on android.
  # 7.c Proxify calendar app to go over tor to Nextcloud on Android.
  # 7.b Verify calendar app goes over tor to Nextcloud on Android.

  # Configure tor to create and host onion domain for nextcloud.
  # Used if the user passes: -ct or --configure_tor to CLI.
  if [ "$configure_tor_for_nextcloud_flag" == "true" ]; then
    # TODO: call SSL4Tor

    call_ssl4tor "$external_nextcloud_port" "$local_nextcloud_port" "$ssl_password"
  fi

  # Used if the user passes: -o or --get-onion to CLI.
  if [ "$get_onion_flag" == "true" ]; then
    verify_apt_installed "tor"
    sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname"
  fi
}

configure_calendar() {
  local calendar_client_flag="$1"
  local calendar_phone_flag="$2"
  local calendar_server_flag="$3"

  verify_snap_installed "nextcloud"

  if [ "$calendar_server_flag" == "true" ]; then
    enable_calendar_app_in_nextcloud
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
    assert_phone_is_connected_via_adb

    IFS=, read -r -a arr <<<"${csv_app_list}"
    for app_name in "${arr[@]}"; do
      if [ "$app_name" == "Orbot" ]; then
        echo "(Re)-Installing: $app_name"
        re_install_orbot_apk
      fi
      if [ "$app_name" == "DAVx5" ]; then
        echo "(Re)-Installing: $app_name"
        re_install_davx5_apk
      fi
    done
  fi
}

configure_android_apps() {
  local android_app_configure_flag
  android_app_configure_flag="$1"
  local nextcloud_username
  nextcloud_username="$2"
  local csv_app_list
  csv_app_list="$3"

  if [ "$android_app_configure_flag" == "true" ]; then
    apps_are_supported "$csv_app_list"
    assert_phone_has_internet_connection

    # Get the Nextcloud password to configure Android apps with it.
    echo -n Nextcloud Password:
    #read -r -s nextcloud_password
    echo
    assert_is_non_empty_string "${nextcloud_password}" "nextcloud_password"

    # Configure the selected apps.
    IFS=, read -r -a arr <<<"${csv_app_list}"

    for app_name in "${arr[@]}"; do
      if [ "$app_name" == "Orbot" ]; then
        echo "(Re)-Configuring: $app_name"
        configure_orbot_apk
      elif [ "$app_name" == "DAVx5" ]; then

        # Acquire sudo permission to configure DAVx5 through adb and appcommander.
        sudo echo

        # Verify orbot has been configured after this app is installed.
        # otherwise, the orbot torrification of this app refers to a non-existing
        # app, meaning DAVx5 won't be able to find your Nextcloud server over tor
        # because DAVx5 is not torrified by orbot. As a bandaid, always run
        # -ar DAVx5,Orbot and -ac DAVx5,Orbot for both apps at once.
        assert_element_one_before_two_in_csv "Orbot" "DAVx5" "$csv_app_list"

        echo "(Re)-Configuring: $app_name"
        configure_davx5_apk "$nextcloud_username" "$nextcloud_password"
      fi
    done
  fi
}
