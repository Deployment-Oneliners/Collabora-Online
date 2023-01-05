#!/usr/bin/env bash
source src/config/configure_orbot_app.sh
source src/uninstall/uninstall_apk.sh

#######################################
# Installs an Android app from a URL onto a connected device.
#
# Local variables:
#  app_url: URL from which to download the app.
#  app_file: Local file path for the downloaded app.
#  expected_md5: Expected MD5 checksum of the app.
#
# Globals:
#  None.
# Arguments:
#  $1: URL from which to download the app.
#  $2: Expected MD5 checksum of the app.
#
# Returns:
#  0 if the app was successfully installed.
#  7 if adb is not available or if the device is not connected.
#  8 if the app could not be downloaded.
#  9 if the app could not be installed on the device.
#  10 if the downloaded file is not a valid APK file.
#  11 if the downloaded file's checksum does not match the expected value.
# Outputs:
#  None.
#######################################
# Run with:
# bash -c 'source src/install/install_android.sh && install_android_app "orbot.apk" "e9ed7a6386308d2995c2c1b2185e5ef0" "org.torproject.android" "https://github.com/guardianproject/orbot/releases/download/16.6.4-RC-1-tor.0.4.7.11/Orbot-16.6.4-RC-1-tor.0.4.7.11-fullperm-universal-release.apk"'
install_android_app() {
  local apk_filename="$1"
  local expected_md5="$2"
  local android_app_name="$3"
  local app_url="$4"

  # Ensure the .apk file exists.
  ensure_apk_is_downloaded_from_some_link "$apk_filename" "$expected_md5" "$app_url"

  # Check if adb is available and if a device is connected.
  if ! command -v adb &>/dev/null || ! adb devices | grep -q "^[^*]*device$"; then
    return 7
  fi

  # Check if the app is installed.
  local app_exists
  app_exists=$(adb shell pm list packages "$android_app_name")

  # Install app if it is not yet installed.
  if [ "$app_exists" != "package:$android_app_name" ]; then
    adb install "$apk_filename"
  else
    echo "Removing app."
    remove_android_app "$android_app_name"
    echo "Re-installing app."
    adb install "$apk_filename"
  fi

  # Verify that the app was installed.
  app_exists=$(adb shell pm list packages "$android_app_name")
  if [ "$app_exists" != "package:$android_app_name" ]; then
    echo "error, app does not exist."
    return 9
  fi

  # Configure orbot
  #configure_orbot "$apk_filename" "$expected_md5" "$android_app_name" "$app_url"
  sleep 5
  start_orbot_service "$android_app_name"
  ask_user_orbot_is_started_successfully

  return 0
}

# Run with:
# bash -c 'source src/install/install_android.sh && ensure_apk_is_downloaded_from_some_link "orbot.apk" "e9ed7a6386308d2995c2c1b2185e5ef0" "https://github.com/guardianproject/orbot/releases/download/16.6.4-RC-1-tor.0.4.7.11/Orbot-16.6.4-RC-1-tor.0.4.7.11-fullperm-universal-release.apk"'
ensure_apk_is_downloaded_from_some_link() {
  local apk_filename="$1"
  local expected_md5="$2"
  local app_url="$3"

  # Check that the downloaded file is a valid APK file.
  if ! file "$apk_filename"; then
    download_apk_file_from_link "$apk_filename" "$expected_md5" "$app_url"
  fi

  # Check the MD5 checksum of the downloaded file.
  local actual_md5
  read -r -a actual_md5 <<<"$(md5sum "$apk_filename")"
  if [ "${actual_md5[0]}" != "$expected_md5" ]; then
    download_apk_file_from_link "$apk_filename" "$expected_md5" "$app_url"
  fi

  # Check that the downloaded file is a valid APK file.
  if ! file "$apk_filename"; then
    return 10
  fi

  # Check the MD5 checksum of the downloaded file.
  read -r -a actual_md5 <<<"$(md5sum "$apk_filename")"
  if [ "${actual_md5[0]}" != "$expected_md5" ]; then
    download_apk_file_from_link "$apk_filename" "$expected_md5" "$app_url"
  fi
}

download_apk_file_from_link() {
  local apk_filename="$1"
  local expected_md5="$2"
  local app_url="$3"

  # Download the app.
  echo "GETTING URL"
  if ! wget "$app_url" -O "$apk_filename"; then
    return 8
  fi

  manual_assert_file_exists "$apk_filename"

  # Check the MD5 checksum of the downloaded file.
  #actual_md5=($(md5sum "$apk_filename"))
  read -r -a actual_md5 <<<"$(md5sum "$apk_filename")"
  if [ "${actual_md5[0]}" != "$expected_md5" ]; then
    return 11
  fi

}

# Configure Davx 5

# https://github.com/guardianproject/orbot/releases/download/16.6.4-RC-1-tor.0.4.7.11/Orbot-16.6.4-RC-1-tor.0.4.7.11-fullperm-universal-release.apk
# https://github.com/bitfireAT/davx5-ose/releases/download/v4.2.6-ose/davx5-ose-4.2.6-ose-release.apk
