#!/bin/bash
# Configures tor to make nextcloud accessible over tor.

verify_has_two_consecutive_lines() {
  local torrc_line_1="$1"
  local torrc_line_2="$2"
  local torrc_filepath="$3"

  local found_lines
  found_lines="$(has_two_consecutive_lines "$torrc_line_1" "$torrc_line_2" "$torrc_filepath")"
  if [ "$found_lines" != "FOUND" ]; then
    printf "==========================\\n"
    red_msg "Error, did not found expected two lines:"
    red_msg "$torrc_line_1"
    red_msg "$torrc_line_2"
    red_msg "in:"
    red_msg "$torrc_filepath"
    printf "==========================\\n\\n"
    exit 3 # TODO: update exit status.
  fi
}

configure_tor() {
  local hidden_service_port="$1"
  local local_nextcloud_port="$2"
  local nextcloud_hidden_service_path="$3"
  local torrc_filepath="$4"

  # A. Get torr config filename.
  # B. Verify torr configuration file exists.
  manual_assert_file_exists "$torrc_filepath"

  # C. Specify what the desired content of that file is. External example:
  # # NextCloud hidden service configuration."

  # So try C.2:
  # https://stackoverflow.com/a/38797241/7437143
  # Proxy tor port hidden_service_port to local_nextcloud_port
  local torrc_line_1
  torrc_line_1="HiddenServiceDir $nextcloud_hidden_service_path/"
  local torrc_line_2
  torrc_line_2="HiddenServicePort $hidden_service_port 127.0.0.1:$local_nextcloud_port"

  # E. If that content is not in the torrc file, append it at file end.
  append_lines_if_not_found "$torrc_line_1" "$torrc_line_2" "$torrc_filepath"

  # F. Verify that content is in the file.
  verify_has_two_consecutive_lines "$torrc_line_1" "$torrc_line_2" "$torrc_filepath"

  # Initiate tor once to create the onion domain.
  start_tor_and_check_onion_url "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname" "$TOR_LOG_FILEPATH" "true"
}

#!/usr/bin/env bash

#######################################
# Function to start "sudo tor" in the background and check if the onion URL exists in the hostname.
# If the onion URL exists, the function terminates the "sudo tor" process. If the onion URL does not exist,
# the function waits for 5 seconds and checks again, for a maximum duration of 2 minutes. If the onion URL
# still does not exist after 2 minutes, the function raises an exception.
#
# Local variables:
#  start_time: a local variable to store the start time of the function.
#  elapsed_time: a local variable to store the elapsed time from the start of the function.
#
# Globals:
#  None.
# Arguments:
#  None.
# Returns:
#  0 if the onion URL exists in the hostname within 2 minutes.
#  7 if the onion URL does not exist in the hostname after 2 minutes.
# Outputs:
#  None.
#######################################
start_tor_and_check_onion_url() {
  local hostname_filepath="$1"
  local tor_log_filepath="$2"
  local new_onion_flag="$3"

  if [ "$new_onion_flag" == "true" ]; then
    read -p "Before deleting"
    rm -f "$hostname_filepath"
    read -p "after deleting"
  fi

  # Make root owner of tor directory.
  sudo chown -R root /var/lib/tor
  sudo chmod 700 /var/lib/tor/nextcloud

  # Start "sudo tor" in the background
  sudo tor | tee "$tor_log_filepath" >/dev/null

  # Set the start time of the function
  start_time=$(date +%s)

  # Check if the onion URL exists in the hostname every 5 seconds, until 2 minutes have passed
  while true; do
    local onion_exists
    onion_exists=$(check_onion_url_exists_in_hostname "$hostname_filepath")

    # Check if the onion URL exists in the hostname
    if [[ "$onion_exists" -eq 0 ]]; then
      # If the onion URL exists, terminate the "sudo tor" process and return 0
      pkill -f "sudo tor"
      return 0
    fi

    sleep 1

    # Calculate the elapsed time from the start of the function
    elapsed_time=$(($(date +%s) - start_time))

    # If 2 minutes have passed, raise an exception and return 7
    if ((elapsed_time > 120)); then
      pkill -f "sudo tor"
      echo >&2 "Error: Onion URL does not exist in hostname after 2 minutes."
      return 7
    fi

    # Wait for 5 seconds before checking again
    sleep 5
  done
}

# Returns "FOUND" if an onion was available on the first try.
# TODO: allow for retries in parsing ping output.
onion_is_available() {
  local onion="$1"
  local port="$2"

  local address
  if [ "$port" == "" ]; then
    address="$onion"
  else
    address="$onion:$port"
  fi

  local ping_output
  ping_output=$(torsocks httping --count 1 "$address")
  if [[ "$ping_output" == *"100,00% failed"* ]]; then
    echo "NOTFOUND"
  elif [[ "$ping_output" == *"1 connects, 1 ok, 0,00% failed, time"* ]]; then
    echo "FOUND"
  else
    echo "Error, did not find status."
    exit 5
  fi
}

assert_onion_is_available() {
  local onion="$1"
  local port="$2"

  if [ "$(onion_is_available "$onion" "$port")" != "FOUND" ]; then
    echo "Error, was not able to connect to:$onion"
    exit 5
  fi

}
