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
  local nextcloud_username
  nextcloud_username="$1"
  local nextcloud_password
  nextcloud_password="$2"
  local local_nextcloud_port
  local_nextcloud_port="$3"

  local android_app_name="at.bitfire.davdroid"

  local onion_address
  onion_address=$(sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname")
  assert_onion_is_available "$onion_address" "$local_nextcloud_port"
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
