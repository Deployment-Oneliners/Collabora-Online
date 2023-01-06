#!/usr/bin/env bash
source src/config/configure_orbot_app.sh
source src/install/install_apk.sh

# bash -c 'source src/install/install_android_apps.sh && setup_orbot_apk'
setup_orbot_apk() {
  local apk_filename="orbot.apk"
  local expected_md5="e9ed7a6386308d2995c2c1b2185e5ef0"
  local android_app_name="org.torproject.android"
  local app_url="https://github.com/guardianproject/orbot/releases/download/16.6.4-RC-1-tor.0.4.7.11/Orbot-16.6.4-RC-1-tor.0.4.7.11-fullperm-universal-release.apk"

  # (Re)-install orbot.
  install_android_app "$apk_filename" "$expected_md5" "$android_app_name" "$app_url"

  # Configure orbot.
  sleep 5
  start_orbot_service "$android_app_name"
  ask_user_orbot_is_started_successfully
}

# bash -c 'source src/install/install_android_apps.sh && setup_davx5_apk'
setup_davx5_apk() {
  local apk_filename="davx5.apk"
  local expected_md5="0186db8d28dc1166b40f8a1479343cf0"
  local android_app_name="at.bitfire.davdroid"

  local app_url="https://github.com/bitfireAT/davx5-ose/releases/download/v4.2.6-ose/davx5-ose-4.2.6-ose-release.apk"

  # (Re)-install orbot.
  install_android_app "$apk_filename" "$expected_md5" "$android_app_name" "$app_url"

}
