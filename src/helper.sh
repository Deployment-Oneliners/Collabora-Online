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

# Returns 0 if an array contains a string, 1 otherwise.
# Case sensitive.
# Allows for spaces
#
# Usage:
# supported_apps=( "Orbot with spaces" DAVx5 )
# find_in_array Orbot "${supported_apps[@]}"
# result="$?"
# echo "result=$result"
# does not match (returns 1 in results)

# find_in_array "Orbot with spaces" "${supported_apps[@]}"
# does match (returns 0 in results)
find_in_array() {
  local word=$1
  shift
  for e in "$@"; do [[ "$e" == "$word" ]] && return 0; done
  return 1
}

# Throws error if an app in csv_app_list is not supported by this repository.
apps_are_supported() {
  local csv_app_list
  csv_app_list="$1"

  IFS=, read -r -a arr <<<"${csv_app_list}"
  echo "${arr[@]}"
  for i in "${arr[@]}"; do
    find_in_array "$i" "${SUPPORTED_APPS[@]}"
    result="$?"
    if [ "$result" -eq 1 ]; then
      echo "Error, app:$i is not yet supported:$SUPPORTED_APPS"
      exit 1
    fi
  done
}
