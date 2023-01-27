#!/usr/bin/env bash

#######################################
# Manually sends keystrokes start the Tor service of orbot.
#
# Local variables:
#
# Globals:
#  None.
# Arguments:
#
# Returns:
#  0 if the service was started without error.
#  1 if the BIND_VPN_SERVICE permission was not granted.
#  5 if an unknown error is thrown.
#  None.
#######################################
start_orbot_service() {
  local android_app_name="$1"

  adb shell monkey -p "$android_app_name" 1 &>/dev/null
  sleep 5

  # TODO: verify Orbot is launched.

  # TODO: Verify Orbot requests for vpn permission.

  # Set VPN permission.
  adb shell input keyevent 20 # Arrow Down
  sleep 1
  adb shell input keyevent 22 # Arrow Right
  sleep 1
  adb shell input keyevent 66 # Enter
  sleep 2

  # Proceed to main screen.
  adb shell input keyevent 22 # Arrow Right
  sleep 1
  adb shell input keyevent 22 # Arrow Right
  sleep 1
  adb shell input keyevent 22 # Arrow Right
  sleep 1
  adb shell input keyevent 22 # Arrow Right
  sleep 1
  adb shell input keyevent 66 # Enter
  sleep 1

  # TODO: verify orbot is connected to tor.
}

ask_user_orbot_is_started_successfully() {
  local prompt
  read -r -d '' prompt <<EndOfMessage
Did orbot start successfully, and is the Onion yellow?

If not, please manually start orbot, grant it the permissions it requests, and
press enter.
EndOfMessage
  echo ""
  read -r -p "$prompt"
}

torify_davx5_apk() {
  echo "hi"
}
