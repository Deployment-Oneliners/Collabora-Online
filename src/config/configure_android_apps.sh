#!/usr/bin/env bash

configure_orbot_apk() {
  local android_app_name="org.torproject.android"

  # Configure orbot.
  conda create -n "androidappcommander" python=3.10 -y
  eval "$(conda shell.bash hook)"
  conda deactivate && conda activate androidappcommander && pip install appcommander==0.0.27 && appcommander -a $android_app_name -v "16.6.3 RC 1" -t DAVx5
  echo "Done with Orbot"
}

configure_davx5_apk() {
  local nextcloud_username="$1"
  local nextcloud_password="$2"

  local android_app_name="at.bitfire.davdroid"

  local onion_address
  onion_address=$(sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname")
  # TODO: verify access to onion is available.
  # TODO: verify access to Nextcloud via this domain is trusted.
  # TODO: verify orbot has been configured after this app is installed.
  # otherwise, the orbot torrification of this app refers to a non-existing
  # app, meaning DAVx5 won't be able to find your Nextcloud server over tor
  # because DAVx5 is not torrified by orbot. As a bandaid, always run
  # -ar DAVx5,Orbot and -ac DAVx5,Orbot for both apps at once.

  # Configure DAVx5 app.
  conda create -n "androidappcommander" python=3.10 -y
  eval "$(conda shell.bash hook)"
  pip install appcommander
  conda deactivate && conda activate androidappcommander && pip install appcommander >=0.0.27 && appcommander -a "$android_app_name" -v "4.2.6" -nu "$nextcloud_username" -np "$nextcloud_password" -o "$onion_address"
  echo "Done with DAVx5"
}

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
