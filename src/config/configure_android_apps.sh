#!/usr/bin/env bash

configure_orbot_apk() {
  local android_app_name="org.torproject.android"

  # Configure orbot.
  if [[ "$(conda_env_exists androidappcommander)" == "FOUND" ]]; then
    conda create -n "androidappcommander" python=3.10 -y
    exit 5
  fi

  eval "$(conda shell.bash hook)"
  conda deactivate && conda activate androidappcommander && pip install "appcommander>=0.0.31" && appcommander -a $android_app_name -v "16.6.3 RC 1" -t DAVx5
  echo "Done with Orbot"
}

configure_davx5_apk() {
  local nextcloud_username="$1"
  local nextcloud_password="$2"

  local android_app_name="at.bitfire.davdroid"

  local onion_address
  onion_address=$(sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname")
  echo "Verifying your onion domain is online at:https://$onion_address"
  # TODO: determine why assert at port does not work.
  assert_onion_is_available "https://$onion_address"

  # TODO: verify access to Nextcloud via this domain is trusted.

  if [[ "$(conda_env_exists androidappcommander)" == "FOUND" ]]; then
    conda create -n "androidappcommander" python=3.10 -y
    exit 5
  fi

  # Configure DAVx5 app.

  eval "$(conda shell.bash hook)"
  conda deactivate && conda activate androidappcommander && pip install "appcommander>=0.0.31" && appcommander -a "$android_app_name" -v "4.2.6" -nu "$nextcloud_username" -np "$nextcloud_password" -o "$onion_address"
  echo "Done with DAVx5"
}

conda_env_exists() {
  local env_name="$1"

  local relevant_line
  relevant_line=$(! conda info --envs | grep "$env_name")

  found_env_name="${relevant_line:0:${#env_name}}"

  if [[ "$relevant_line" == "" ]]; then
    echo "NOTFOUND"
  elif [[ "$env_name" == "$found_env_name" ]]; then
    echo "FOUND"
  else
    echo "Error, did not find expected output from check if env:$env_name exists."
    exit 5
  fi
}
