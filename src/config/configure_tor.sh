#!/bin/bash
# Configures tor to make nextcloud accessible over tor.
source src/helper.sh
source src/config/helper_tor_parsing.sh

#Setup variables (change values if you need)
TORRC_ROOT=/etc/tor
HSDIR_ROOT=/var/lib/tor
HS_PORT=80
#NEXTCLOUD_PORT=81
TOR_CONFIG_LOCATION=$TORRC_ROOT/torrc

# A. Get torr config filename.
# B. Verify torr configuration file exists.
manual_assert_file_exists "$TOR_CONFIG_LOCATION"

# C. Specify what the desired content of that file is. External example:
# # NextCloud hidden service configuration." \
# HiddenServiceDir $HSDIR_ROOT/nextcloud/" \
# HiddenServicePort $HS_PORT 127.0.0.1:$NEXTCLOUD_PORT\n" \
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
torrc_line_1="HiddenServiceDir $HSDIR_ROOT/nextcloud/"
torrc_line_2="HiddenServicePort $HS_PORT 127.0.0.1:$HS_PORT"

verify_has_two_consecutive_lines() {
  local torrc_line_1="$1"
  local torrc_line_2="$2"
  local tor_config_location="$3"

  local found_lines
  found_lines="$(has_two_consecutive_lines "$torrc_line_1" "$torrc_line_2" "$tor_config_location")"
  if [ "$found_lines" != "FOUND" ]; then
    printf "==========================\\n"
    red_msg "Error, did not found expected two lines:"
    red_msg "$torrc_line_1"
    red_msg "$torrc_line_2"
    red_msg "in:"
    red_msg "$tor_config_location"
    printf "==========================\\n\\n"
    exit 3 # TODO: update exit status.
  fi
}

# D. Check if that content is in the file or not.
has_two_consecutive_lines "$torrc_line_1" "$torrc_line_2" "$TOR_CONFIG_LOCATION"

# E. If that content is not available, put it in the file.
append_lines_if_not_found "$torrc_line_1" "$torrc_line_2" "$TOR_CONFIG_LOCATION"

# F. Verify that content is in the file.
verify_has_two_consecutive_lines "$torrc_line_1" "$torrc_line_2" "$TOR_CONFIG_LOCATION"

# G. Restart tor.
sudo killall tor
systemctl stop tor
sleep 10

# H. Verify tor is running.
# I. Verify tor website is available.
# J. Verify nextcloud is available.

# TODO: set up cronjob that starts tor service upon boot.
# TODO: start cronjob manually
# TODO: verify tor is started
# TODO: verify one can ssh into the server over tor
# TODO: share ssh key

echo "To get the onion domain to ssh into, run:"
echo "sudo cat /var/lib/tor/nextcloud/hostname"

# 3.a Detect tor configuration.
# 3.b Modify tor configuration based on detected config.
# 3.c Verify tor config is modified correctly.

# 4.a Restart tor.
# 4.b Verify tor is restarted successfully.

# 5.a Get onion domain.
# 5.b. Restart tor.
# 5.c Verify tor is restarted successfully.
# 5.d Verify onion domain is accessible.
