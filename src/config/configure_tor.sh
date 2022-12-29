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
  # # NextCloud hidden service configuration." \
  # HiddenServiceDir $tor_service_dir/nextcloud/" \
  # HiddenServicePort $hidden_service_port 127.0.0.1:$NEXTCLOUD_PORT\n" \
  # Local example:
  # append ssh service to torrc
  # first_line="HiddenServiceDir $HIDDENSERVICEDIR_SSH$HIDDENSERVICENAME_SSH/"
  # second_line_option_I="HiddenServicePort 22"
  # second_line_option_II="HiddenServicePort 22 127.0.0.1:22"
  # (For shh which has ports 22,23)
  # C.0 So it is either:
  # HiddenServiceDir /var/lib/tor/nextcloud/
  # HiddenServicePort 80 127.0.0.1:81
  # C.1 Or:
  # HiddenServiceDir /var/lib/tor/nextcloud/
  # HiddenServicePort 80
  # C.2 Or:
  # HiddenServiceDir /var/lib/tor/nextcloud/
  # HiddenServicePort 80 127.0.0.1:80
  # C.3 Or (not verified manually):
  # HiddenServiceDir /var/lib/tor/nextcloud/
  # HiddenServicePort 80 127.0.0.1:81
  # C.4 Or (not verified manually):
  # HiddenServiceDir /var/lib/tor/nextcloud/
  # HiddenServicePort 81 127.0.0.1:80
  # C.5 Or (not verified manually):
  # HiddenServiceDir /var/lib/tor/nextcloud/
  # HiddenServicePort 81 127.0.0.1:81

  # So try C.2:
  # https://stackoverflow.com/a/38797241/7437143
  # Proxy tor port hidden_service_port to local_nextcloud_port
  local torrc_line_1
  torrc_line_1="HiddenServiceDir $nextcloud_hidden_service_path"
  local torrc_line_2
  torrc_line_2="HiddenServicePort $hidden_service_port 127.0.0.1:$local_nextcloud_port"

  # E. If that content is not in the torrc file, append it at file end.
  append_lines_if_not_found "$torrc_line_1" "$torrc_line_2" "$torrc_filepath"

  # F. Verify that content is in the file.
  verify_has_two_consecutive_lines "$torrc_line_1" "$torrc_line_2" "$torrc_filepath"
}
