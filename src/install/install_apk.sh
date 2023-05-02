#!/usr/bin/env bash
#source src/uninstall/uninstall_apk.sh

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

  assert_phone_is_connected_via_adb

  # Check if the app is installed.
  local app_exists
  app_exists=$(adb shell pm list packages "$android_app_name")

  # Install app if it is not yet installed.
  if [ "$app_exists" != "package:$android_app_name" ]; then
    # TODO: if output = adb: failed to install <filename.apk>: suggest to user
    # this is most likely because of bad usb cable.
    adb install "$apk_filename"
  else
    echo "Removing app: $android_app_name"
    remove_android_app "$android_app_name" &>/dev/null
    wait_until_phone_is_connected_via_adb_and_online 60
    echo "Re-installing app."
    # TODO: if output = adb: failed to install <filename.apk>: suggest to user
    # this is most likely because of bad usb cable.
    adb install "$apk_filename"
  fi
  wait_until_phone_is_connected_via_adb_and_online 60
  assert_phone_is_connected_via_adb

  # Verify that the app was installed.
  app_exists=$(adb shell pm list packages "$android_app_name")
  if [ "$app_exists" != "package:$android_app_name" ]; then
    echo "Error, app: $android_app_name does not exist."
    return 9
  fi

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
    download_apk_file_from_link "$apk_filename" "$expected_md5" "$app_url" &>/dev/null
  fi

  # Check the MD5 checksum of the downloaded file.
  local actual_md5
  read -r -a actual_md5 <<<"$(md5sum "$apk_filename")"
  if [ "${actual_md5[0]}" != "$expected_md5" ]; then
    download_apk_file_from_link "$apk_filename" "$expected_md5" "$app_url" &>/dev/null
  fi

  # Check that the downloaded file is a valid APK file.
  if ! file "$apk_filename"; then
    return 10
  fi

  # Check the MD5 checksum of the downloaded file.
  read -r -a actual_md5 <<<"$(md5sum "$apk_filename")"
  if [ "${actual_md5[0]}" != "$expected_md5" ]; then
    download_apk_file_from_link "$apk_filename" "$expected_md5" "$app_url" &>/dev/null
  fi
}

download_apk_file_from_link() {
  local apk_filename="$1"
  local expected_md5="$2"
  local app_url="$3"

  # Download the app.
  # if ! wget "$app_url" -O "$apk_filename" ; then
  if ! wget "$app_url" -O "$apk_filename" &>/dev/null; then
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
