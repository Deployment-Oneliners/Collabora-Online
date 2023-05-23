#!/usr/bin/env bash

#######################################
# Asserts that a file exists and that its content is an onion URL in the correct format.
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
#  None.
#######################################
assert_onion_url_exists_in_hostname() {
  local filepath="$1"

  local result
  check_onion_url_exists_in_hostname "$filepath"
  result=$?
  if [ "$result" -eq 7 ]; then
    echo "Error: $filepath does not exist." >&2
    exit 1
  elif [ "$result" -eq 8 ]; then
    echo "Error: $filepath exists, but it does not contain a valid onion:" >&2
    sudo cat "$filepath"
    exit 1
  fi
}
