#!/usr/bin/env bash

#######################################
# Checks that a file exists and that its content is an onion URL in the correct format.
#
# Local variables:
#  - filepath: path to the file to verify
#
# Globals:
#  None.
# Arguments:
#  - $1: filepath to verify
#
# Returns:
#  0 if the file exists and has a valid onion URL as its content
#  7 if the file does not exist
#  8 if the file exists, but its content is not a valid onion URL
# Outputs:
#  None.
#######################################
check_onion_url_exists_in_hostname() {
  local filepath="$1"

  local file_content
  file_content=$(sudo cat "$filepath")

  # Verify that the file exists
  if sudo test -f "$filepath"; then
    # Verify that the file's content is a valid onion URL
    if [[ "$file_content" =~ ^[a-z0-9]{56}\.onion$ ]]; then
      return 0 # file exists and has valid onion URL as its content
    else
      return 8 # file exists, but has invalid onion URL as its content
    fi
  else
    return 7 # file does not exist
  fi
}
