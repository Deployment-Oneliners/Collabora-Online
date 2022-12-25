#!/usr/bin/env bash
source src/cli_logger.sh
source src/helper_parsing.sh
source src/config/configure_nextcloud.sh

POSITIONAL_ARGS=()

# Specify default argument values.
default_nextcloud_username="some_username"
default_nextcloud_password="some_password"
nextcloud_port=81
nextcloud_pwd_flag='false'
nextcloud_username_flag='false'
configure_nextcloud_flag='false'

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

# print the usage if no arguments are given
[ $# -eq 0 ] && {
  print_usage
  exit 1
}

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
    -tw | --tor_website)
      set_up_tor_website_for_nextcloud_flag='true'
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
    -p | --prereq)
      prerequistes_only_flag='true'
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

#echo "setup_boot_script_flag                   = ${setup_boot_script_flag}"
#echo "set_up_tor_website_for_nextcloud_flag= ${set_up_tor_website_for_nextcloud_flag}"

if [[ -n $1 ]]; then
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 "$1"
fi

# Set GitLab password without displaying it in terminal.
if [ "$prerequistes_only_flag" == "true" ]; then
  ensure_prerequisites_compliance
fi

# Set GitHub password without displaying it in terminal.
if [ "$nextcloud_pwd_flag" == "true" ]; then
  echo -n Nextcloud Password:
  read -r -s nextcloud_password
  echo
  assert_is_non_empty_string "${nextcloud_password}"
fi

# TODO: add boot script.
if [ "$setup_boot_script_flag" == "true" ]; then
  echo "TODO: setup_boot_script_flag"
fi

# TODO: add boot script.
if [ "$set_up_tor_website_for_nextcloud_flag" == "true" ]; then
  echo "TODO: set_up_tor_website_for_nextcloud_flag"
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
