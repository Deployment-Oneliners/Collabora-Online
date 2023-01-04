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

copy_file() {
  input_path="$1"
  output_path="$2"
  use_sudo="$3"
  manual_assert_file_exists "$input_path"

  if [ "$use_sudo" == "true" ]; then
    sudo cp "$input_path" "$output_path"
  else
    cp "$input_path" "$output_path"
  fi

  manual_assert_file_exists "$output_path"
}

#######################################
# Verifies a directory exists, throws error otherwise.
# Local variables:
#  dirpath
# Globals:
#  None.
# Arguments:
#  Relative folderpath of folder whose existence is verified.
# Returns:
#  0 If folder was found.
#  31 If the folder was not found.
# Outputs:
#  Nothing
#######################################
manual_assert_dir_exists() {
  local dirpath="$1"
  if [ ! -d "$dirpath" ]; then
    echo "The dir: $dirpath does not exist, even though one would expect it does."
    exit 31
  fi
}
