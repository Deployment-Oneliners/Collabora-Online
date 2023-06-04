#!/usr/bin/env bash

assert_is_non_empty_string() {
  local string="$1"
  local description="$2"
  if [ "${string}" == "" ]; then
    red_msg "Error, the incoming string:$description was empty." "true"
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

manual_assert_dir_not_exists() {
  local dirpath="$1"
  if [ -d "$dirpath" ]; then
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

assert_element_one_before_two_in_csv() {
  local elem_one
  elem_one="$1"
  local elem_two
  elem_two="$2"
  local csv_array
  csv_array="$3"

  if [[ "$(element_one_before_two_in_csv "$elem_one" "$elem_two" "$csv_array")" != "BEFORE" ]]; then
    echo "Error, $elem_one not before $elem_two in: $csv_array"
    exit 6
  fi
}

element_one_before_two_in_csv() {
  local elem_one
  elem_one="$1"
  local elem_two
  elem_two="$2"
  local csv_array
  csv_array="$3"

  IFS=, read -r -a arr <<<"${csv_array}"
  local found_one
  local found_two

  assert_csv_array_contains_element "$elem_one" "$csv_array"
  assert_csv_array_contains_element "$elem_two" "$csv_array"

  for item in "${arr[@]}"; do
    if [[ $elem_one == "$item" ]]; then
      found_one="FOUND"
    fi
    if [[ $elem_two == "$item" ]]; then
      found_two="FOUND"
    fi

    if [[ "$found_two" == "FOUND" ]] && [[ "$found_one" != "FOUND" ]]; then
      echo "AFTER"
      break
    elif [[ "$found_one" == "FOUND" ]] && [[ "$found_two" != "FOUND" ]]; then
      echo "BEFORE"
      break
    fi
  done

}

assert_csv_array_contains_element() {
  local elem_one
  elem_one="$1"
  local csv_array
  csv_array="$2"

  if [[ "$(csv_array_contains_element "$elem_one" "$csv_array")" != "FOUND" ]]; then
    echo "Error, did not find element:$elem_one in: $csv_array"
    exit 6
  fi
}

csv_array_contains_element() {
  local elem_one
  elem_one="$1"
  local csv_array
  csv_array="$2"

  IFS=, read -r -a containing_arr <<<"${csv_array}"
  local found_one
  for item in "${containing_arr[@]}"; do
    if [[ "$elem_one" == "$item" ]]; then
      found_one="FOUND"
      echo "FOUND"
    fi
  done
  if [[ $found_one != "FOUND" ]]; then
    echo "NOTFOUND"
  fi
}

command_output_contains() {
  local substring="$1"
  shift
  # shellcheck disable=SC2124
  local command_output="$@"
  if grep -q "$substring" <<<"$command_output"; then
    #if "$command" | grep -q "$substring"; then
    echo "FOUND"
  else
    echo "NOTFOUND"
  fi
}
