#!/usr/bin/env bash
parse_args() {
  # The incoming function arguments are the cli arguments.

  # Specify default argument values.
  # Specify default argument values.
  default_nextcloud_username="root"
  default_nextcloud_password="some_password"

  android_app_reinstall_flag='false'
  android_app_configure_flag='false'
  calendar_client_flag='false'
  calendar_phone_flag='false'
  calendar_server_flag='false'
  configure_nextcloud_flag='false'
  configure_tor_for_nextcloud_flag='false'
  get_onion_flag='false'
  nextcloud_pwd_flag='false'
  nextcloud_username_flag='false'

  uninstall_nextcloud_flag='false'

  # $# gives the length/number of the incoming function arguments.
  # the shift command eats the first element of that array, making it shorter.
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
      -ep | --external-nextcloud-port)
        local external_nextcloud_port="$2"
        shift
        shift
        ;;
      -lp | --local-nextcloud-port)
        local local_nextcloud_port="$2"
        shift
        shift
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
      -sp | --ssl-password)
        ssl_password="$2"
        shift # past argument
        shift
        ;;
      -un | --uninstall-nextcloud)
        uninstall_nextcloud_flag='true'
        shift # past argument
        ;;
      -v | --verbose)
        # shellcheck disable=SC2034
        VERBOSE='true'
        shift
        ;;
      -*)
        echo "Unknown option $1"
        print_usage
        exit 1
        ;;
    esac
  done

  if [ "$nextcloud_username" != "root" ] && [ "$nextcloud_username" != "" ]; then
    echo "Error, nextcloud_username other than:root is not yet supported because"
    echo "of mysql, which requires a root username, and needs to have the same "
    echo "username as Nextcloud."
    exit 5
  fi

  setup_nextcloud "$configure_nextcloud_flag" "$local_nextcloud_port" "$default_nextcloud_username" "$default_nextcloud_password" "$nextcloud_pwd_flag" "$nextcloud_username_flag"
  setup_tor_for_nextcloud "$configure_tor_for_nextcloud_flag" "$get_onion_flag" "$external_nextcloud_port" "$local_nextcloud_port" "$ssl_password"

  configure_calendar "$calendar_client_flag" "$calendar_phone_flag" "$calendar_server_flag"

  reinstall_android_apps "$android_app_reinstall_flag" "$reinstall_app_list"
  configure_android_apps "$android_app_configure_flag" "$nextcloud_username" "$configure_app_list"

  uninstaller "$uninstall_nextcloud_flag"
}