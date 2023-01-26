#!/usr/bin/env bash
# Parses the CLI arguments given to this file, and installs Nextcloud over Tor
# accordingly.

source src/cli_usage.sh
source src/process_args.sh
# shellcheck disable=SC1091
source src/uninstall/uninstaller.sh

# Get the positional arguments from the CLI.
POSITIONAL_ARGS=()

# Specify default argument values.
default_nextcloud_username="some_username"
default_nextcloud_password="some_password"

android_app_reinstall_flag='false'
android_app_configure_flag='false'
calendar_client_flag='false'
calendar_phone_flag='false'
calendar_server_flag='false'
configure_nextcloud_flag='false'
configure_tor_for_nextcloud_flag='false'
install_tor_nextcloud_flag='false'
get_onion_flag='false'
nextcloud_pwd_flag='false'
nextcloud_username_flag='false'
set_https_flag='false'
setup_boot_script_flag='false'
start_tor_flag='false'

uninstall_nextcloud_flag='false'
uninstall_tor_flag='false'

# Specify apps that are supported in this project.
# shellcheck disable=SC2034
SUPPORTED_APPS=("Orbot" "DAVx5")

# Print the usage if no arguments are given.
[ $# -eq 0 ] && {
  print_usage
  exit 1
}

# Parse CLI arguments and store configuration settings accordingly.
while [[ $# -gt 0 ]]; do
  case $1 in
    -ar | --android-reinstall)
      android_app_reinstall_flag='true'
      reinstall_app_list="$2"
      shift
      shift
      ;;
    -ac | --android-configure)
      android_app_configure_flag='true'
      configure_app_list="$2"
      shift
      shift
      ;;
    -b | --boot)
      setup_boot_script_flag='true'
      shift # past argument
      ;;
    -cc | --calendar-client)
      calendar_client_flag='true'
      shift # past argument
      ;;
    -cn | --configure-nextcloud)
      configure_nextcloud_flag='true'
      shift # past argument
      ;;
    -cp | --calendar-phone)
      calendar_phone_flag='true'
      shift # past argument
      ;;
    -cs | --calendar-server)
      calendar_server_flag='true'
      shift # past argument
      ;;
    -ct | --configure-tor)
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
    -un | --uninstall-nextcloud)
      uninstall_nextcloud_flag='true'
      shift # past argument
      ;;
    -ut | --uninstall-tor)
      uninstall_tor_flag='true'
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

setup_nextcloud "$configure_nextcloud_flag" "$default_nextcloud_username" "$default_nextcloud_password" "$install_tor_nextcloud_flag" "$nextcloud_pwd_flag" "$nextcloud_username_flag"
setup_tor_for_nextcloud "$configure_tor_for_nextcloud_flag" "$get_onion_flag"
start_tor "$setup_boot_script_flag" "$start_tor_flag" "$set_https_flag"

configure_calendar "$calendar_client_flag" "$calendar_phone_flag" "$calendar_server_flag"

reinstall_android_apps "$android_app_reinstall_flag" "$reinstall_app_list"
configure_android_apps "$android_app_configure_flag" "$configure_app_list"

uninstaller "$uninstall_nextcloud_flag" "$uninstall_tor_flag"
