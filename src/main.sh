#!/usr/bin/env bash
# Parses the CLI arguments given to this file, and installs Nextcloud over Tor
# accordingly.

# Load used functions, from path relative to this main.sh.
# shellcheck source=/dev/null
source src/cli_logger.sh
source src/helper.sh
source src/config/configure_nextcloud.sh
source src/config/configure_tor.sh
source src/config/helper_tor_parsing.sh
source src/install/install_apt.sh
source src/install/install_snap.sh
source src/install/prereq_nextcloud.sh
source src/run_tor/ensure_tor_runs.sh

# Get the positional arguments from the CLI.
POSITIONAL_ARGS=()

# Specify default argument values.
default_nextcloud_username="some_username"
default_nextcloud_password="some_password"
configure_nextcloud_flag='false'
configure_tor_for_nextcloud_flag='false'
install_tor_nextcloud_flag='false'
get_onion_flag='false'
nextcloud_pwd_flag='false'
nextcloud_username_flag='false'
set_https_flag='false'
setup_boot_script_flag='false'
start_tor_flag='false'

# Tor configuration settings
#Setup variables (change values if you need)

TOR_SERVICE_DIR=/var/lib/tor
NEXTCLOUD_HIDDEN_SERVICE_DIR=nextcloud
NEXTCLOUD_HIDDEN_SERVICE_PATH="$TOR_SERVICE_DIR/$NEXTCLOUD_HIDDEN_SERVICE_DIR/"
HIDDEN_SERVICE_PORT=8080
LOCAL_NEXTCLOUD_PORT=81
TORRC_FILEPATH=/etc/tor/torrc

# Print CLI usage options
print_usage() {
  printf "\n\nDefault usage, write:"
  printf "\nsrc/main.sh -cn -ct -i -nu <your Nextcloud username> -np\n                                      to set up a Nextcloud server over tor.\n"

  printf "\nSupported options:"
  printf "\n-cn | --configure-nextcloud           to configure nextcloud with a default account."
  printf "\n-ct | --configure-tor                 to configure Tor with to facilitate nextcloud access over Tor."
  printf "\n-h | --https                          to support HTTPS for .onion domain on server."
  printf "\n-i | --install-tor-nextcloud          to install Tor and Nextcloud."
  printf "\n-nu <your Nextcloud username> | --nextcloud-username <your Nextcloud username>\n                                      to pass your Nextcloud username."
  printf "\n-np | --nextcloud-password            to get a prompt for your Nextcloud password, so you don't have to wait to enter it manually."

  printf "\n\n\nNot yet supported:"
  printf "\n-b | --boot                           to configure a cronjob to run tor at boot."

  printf "\n\n\nyou can also combine the separate arguments in different orders, e.g. -nu -np.\n\n"
}

# Print the usage if no arguments are given.
[ $# -eq 0 ] && {
  print_usage
  exit 1
}

# Parse CLI arguments and store configuration settings accordingly.
while [[ $# -gt 0 ]]; do
  case $1 in
    -b | --boot)
      setup_boot_script_flag='true'
      shift # past argument
      ;;
    -cn | --configure-nextcloud)
      configure_nextcloud_flag='true'
      shift # past argument
      ;;
    -ct | --configure_tor)
      configure_tor_for_nextcloud_flag='true'
      shift # past argument
      ;;
    -h | --https)
      set_https_flag='true'
      shift # past argument
      ;;
    -i | --install-tor-nextcloud)
      install_tor_nextcloud_flag='true'
      shift # past argument
      ;;
    -nu | --nextcloud-username)
      nextcloud_username_flag='true'
      nextcloud_username="$2"
      assert_is_non_empty_string "${nextcloud_username}"
      shift # past argument
      shift
      ;;
    -np | --nextcloud-password)
      nextcloud_pwd_flag='true'
      #nextcloud_pwd="$2" # Don't allow vissibly typing pwd in command line.
      shift # past argument
      ;;

    -o | --get-onion)
      get_onion_flag='true'
      shift # past argument
      ;;
    -s | --start-tor)
      start_tor_flag='true'
      shift # past argument
      ;;
    -*)
      echo "Unknown option $1"
      print_usage
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift                   # past argument
      ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
if [[ -n $1 ]]; then
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 "$1"
fi

# Set Nextcloud password without displaying it in terminal.
# Used if the user passes: -np or --nextcloud-password to CLI.
if [ "$nextcloud_pwd_flag" == "true" ]; then
  echo -n Nextcloud Password:
  read -r -s nextcloud_password
  echo
  assert_is_non_empty_string "${nextcloud_password}"
fi

# Install Tor and Nextcloud.
# Used if the user passes: -i or --install-tor-nextcloud to CLI.
if [ "$install_tor_nextcloud_flag" == "true" ]; then
  install_tor_and_nextcloud
fi

# Configure Nextcloud
# Used if the user passes: -cn or --configure-nextcloud to CLI.
if [ "$configure_nextcloud_flag" == "true" ]; then

  # Get the nextcloud username and password.
  if [ "$nextcloud_username_flag" == "false" ]; then
    # Specify variable defaults
    nextcloud_username="$default_nextcloud_username"
  fi
  if [ "$nextcloud_pwd_flag" == "false" ]; then
    # Specify variable defaults
    nextcloud_password="$default_nextcloud_password"
  fi

  setup_admin_account_on_snap_nextcloud "$nextcloud_username" "$nextcloud_password"
  set_nextcloud_port "$LOCAL_NEXTCLOUD_PORT"
fi

# TODO: Ensure onion service and nextcloud start at boot.
# Used if the user passes: -b or --boot to CLI.
if [ "$setup_boot_script_flag" == "true" ]; then
  echo "TODO: setup_boot_script_flag"
fi

# 6.a Proxify calendar app to go over tor to Nextcloud on client.
# 6.b Verify calendar app goes over tor to Nextcloudon client.

# 7.a Install calendar app on android.
# 7.b Verify calendar app is installed on android.
# 7.c Proxify calendar app to go over tor to Nextcloud on Android.
# 7.b Verify calendar app goes over tor to Nextcloud on Android.

# Configure tor to create and host onion domain for nextcloud.
# Used if the user passes: -ct or --configure_tor to CLI.
if [ "$configure_tor_for_nextcloud_flag" == "true" ]; then
  configure_tor "$HIDDEN_SERVICE_PORT" "$LOCAL_NEXTCLOUD_PORT" "$NEXTCLOUD_HIDDEN_SERVICE_PATH" "$TORRC_FILEPATH"

  # TODO: ensure onion address is created before adding it to Nextcloud.
  # This can be done by starting tor for the first time.
  ONION_ADDRESS=$(sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname")
  add_onion_to_nextcloud_trusted_domain "$ONION_ADDRESS"
fi

# Used if the user passes: -o or --get-onion to CLI.
if [ "$get_onion_flag" == "true" ]; then
  sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname"
fi

if [ "$set_https_flag" == "true" ]; then
  ONION_ADDRESS=$(sudo cat "$NEXTCLOUD_HIDDEN_SERVICE_PATH/hostname")
  setup_tor_ssl "$ONION_ADDRESS"
fi

# Start tor.
if [ "$start_tor_flag" == "true" ]; then
  start_and_monitor_tor_connection
fi
