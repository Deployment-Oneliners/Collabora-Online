#!/usr/bin/env bash
# Parses the CLI arguments given to this file, and installs Nextcloud over Tor
# accordingly.

# Load used functions, from path relative to this main.sh.
# shellcheck source=/dev/null
source src/cli_logger.sh
source src/helper.sh
source src/config/configure_nextcloud.sh
source src/install/prereq_nextcloud.sh
source src/install/install_apt.sh
source src/install/install_snap.sh

# Get the positional arguments from the CLI.
POSITIONAL_ARGS=()

# Specify default argument values.
default_nextcloud_username="some_username"
default_nextcloud_password="some_password"
nextcloud_port=81
nextcloud_pwd_flag='false'
nextcloud_username_flag='false'
configure_nextcloud_flag='false'

# Print CLI usage options
print_usage() {
  printf "\nDefault usage, write:"
  printf "\nsrc/main.sh -nu <your GitHub username> -np <your Nextcloud password>\n                                       set up a Nextcloud server over tor."

  printf "\nSupported options:"
  # TODO: verify if the user can set the value of the GitHub personal access
  # token, or whether the value is given/set by GitHub automatically.
  # If it is given by GitHub automatically, change this into a boolean decision
  # that indicates whether or not the user will set the commit build statuses
  # on GitHub or not.

  printf "\n\n-nu <your Nextcloud username> | --nextcloud-username <your Nextcloud username>\n                                       to pass your GitHub username, to prevent having to wait until you can                                          enter it in the website."
  printf "\n-np | --nextcloud-password                to get a prompt for your Nextcloud password, so you don't have to wait to enter it manually."
  printf "\n-cn | --configure-nextcloud               to configure nextcloud with a default account."

  printf "\n\nNot yet supported:"
  printf "\n-p | --prereq                          to verify prerequisites."
  printf "\n-r | --nextcloud                       to do an installation of Nextcloud."
  printf "\n-s | --create-domain                   to create a new onion domain."
  printf "\n-s | --get-domain                      to get your current onion domain."

  printf "\n\nyou can also combine the separate arguments in different orders, e.g. -nu -np.\n\n"
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
    -i | --install-tor-nextcloud)
      install_tor_nextcloud_flag='true'
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
if [ "$nextcloud_pwd_flag" == "true" ]; then
  echo -n Nextcloud Password:
  read -r -s nextcloud_password
  echo
  assert_is_non_empty_string "${nextcloud_password}"
fi

# Install Tor and Nextcloud if the user passes: -p or --prereq to CLI.
if [ "$install_tor_nextcloud_flag" == "true" ]; then
  install_tor_and_nextcloud
fi

# Configure Nextcloud
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
  set_nextcloud_port "$nextcloud_port"
fi

# TODO: Ensure onion service and nextcloud start at boot.
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
if [ "$configure_tor_for_nextcloud_flag" == "true" ]; then
  echo "TODO: configure_tor_for_nextcloud_flag"
fi

# Start tor.
