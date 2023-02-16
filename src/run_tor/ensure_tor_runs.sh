#!/bin/bash
get_tor_status() {
  tor_status=$(curl --socks5 localhost:9050 --socks5-hostname localhost:9050 -s https://check.torproject.org/ | cat | grep -m 1 Congratulations | xargs)
  echo "$tor_status"
}

connect_tor() {
  tor_connection=$(nohup sudo tor >sudo_tor.out &)
  sleep 10 3>- &
  echo "$tor_connection"
}

# Starts the tor service such that onion domain is available.
start_tor() {
  local setup_boot_script_flag="$1"
  local start_tor_flag="$2"
  local set_https_flag="$3"
  local ssl_password="$4"

  # Verify tor is installed.
  verify_apt_installed "tor"

  # First ensure onion domain exists, then create SSL certificates for tor.
  if [ "$set_https_flag" == "true" ]; then
    assert_onion_url_exists_in_hostname "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname"

    local onion_address
    onion_address=$(sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname")
    setup_tor_ssl "$onion_address" "$ssl_password"

    # TODO: add certificate to computer and/or Firefox.
  fi

  # Start tor.
  if [ "$start_tor_flag" == "true" ]; then
    # TODO: make this a background process after which the code can continue.
    start_and_monitor_tor_connection
  fi

  # Used if the user passes: -b or --boot to CLI.
  if [ "$setup_boot_script_flag" == "true" ]; then
    echo "TODO: setup_boot_script_flag"
  fi
}

start_and_monitor_tor_connection() {
  # TODO: verify the tor script and sites have been deployed before proceeding, send message otherwise

  # Start infinite loop that keeps system connected to tor
  while true; do
    # Get tor connection status
    tor_status_outside=$(get_tor_status)
    echo "tor_status_outside=$tor_status_outside" >&2
    sleep 10

    # Reconnect tor if the system is disconnected.
    if [[ "$tor_status_outside" != *"Congratulations"* ]]; then
      echo "Is Disconnected"

      # Stop all previous tor processes.
      sudo killall tor
      sleep 10

      # Create new tor connection.
      connect_tor
    elif [[ "$tor_status_outside" == *"Congratulations"* ]]; then
      echo "Is connected"
    fi
  done
}
