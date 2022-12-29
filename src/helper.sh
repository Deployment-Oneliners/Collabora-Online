#!/usr/bin/env bash

assert_is_non_empty_string() {
  local string="$1"
  if [ "${string}" == "" ]; then
    echo "Error, the incoming string was empty."
    exit 70
  fi
}

#######################################
#
# Local variables:
#
# Globals:
#  None.
# Arguments:
#
# Returns:
#  0 if
#  7 if
# Outputs:
#  None.
# TODO(a-t-0):
#######################################
# Structure:file_edit
file_exists() {
  local filepath="$1"

  if test -f "$filepath"; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi

}

#######################################
# Verifies a file exists, throws error otherwise.
# Local variables:
#  filepath
# Globals:
#  None.
# Arguments:
#  Relative filepath of file whose existence is verified.
# Returns:
#  0 If file was found.
#  29 If the file was not found.
# Outputs:
#  Nothing
#######################################
manual_assert_file_exists() {
  local filepath="$1"
  if [ ! -f "$filepath" ]; then
    echo "The file: $filepath does not exist."
    exit 29
  fi
}
