#!/usr/bin/env bash

# Run with:
# bash -c 'source src/uninstall/uninstall_apk.sh && remove_android_app "org.torproject.android"'
remove_android_app() {
  local android_app_name="$1"

  # Check if adb is available and if a device is connected.
  if ! command -v adb &>/dev/null || ! adb devices | grep -q "^[^*]*device$"; then
    return 7
  fi

  # Check if the app is installed.
  local app_exists
  app_exists=$(adb shell pm list packages "$android_app_name")

  # Install app if it is not yet installed.
  if [ "$app_exists" == "package:$android_app_name" ]; then
    adb uninstall "$android_app_name"
    wait_until_phone_is_connected_via_adb_and_online 60
  fi

  # Verify that the app was installed.
  app_exists=$(adb shell pm list packages "$android_app_name")
  if [ "$app_exists" == "package:$android_app_name" ]; then
    echo "Error, app:$android_app_name still exists on phone."
    return 9
  fi

  return 0
}
