#!/bin/bash
# Configures tor and helps you copy the onion address.

# Ensure the SSH service is contained in the tor configuration.
has_two_consecutive_lines() {
  local first_line=$1
  local second_line=$2
  local rel_filepath=$3

  if [ "$(file_contains_string "$first_line" "$rel_filepath")" == "FOUND" ]; then
    if [ "$(file_contains_string "$second_line" "$rel_filepath")" == "FOUND" ]; then
      # get line_nr first_line
      local first_line_line_nr
      first_line_line_nr="$(get_line_nr "$first_line" "$rel_filepath")"

      # get next line number
      local next_line_number
      next_line_number=$((first_line_line_nr + 1))

      # get next line
      local next_line
      next_line=$(get_line_by_nr "$next_line_number" "$rel_filepath")

      # verify next line equals the second line
      if [ "$next_line" == "$second_line" ]; then
        echo "FOUND"
      else
        echo "NOTFOUND"
      fi
    fi
  else
    echo "NOTFOUND"
  fi
}

# TODO: remove
has_either_block_of_two_consecutive_lines() {
  local first_line=$1
  local second_line_option_I=$2
  local second_line_option_II=$3
  local rel_filepath=$4

  local has_first_block
  has_first_block=$(has_two_consecutive_lines "$first_line" "$second_line_option_I" "$rel_filepath")
  #echo "has_first_block=$has_first_block"

  local has_second_block
  has_second_block=$(has_two_consecutive_lines "$first_line" "$second_line_option_II" "$rel_filepath")
  #echo "has_second_block=$has_second_block"
  if [ "$has_first_block" == "FOUND" ] || [ "$has_second_block" == "FOUND" ]; then
    echo "FOUND"
  else
    if [ "$(file_contains_string "$first_line" "$rel_filepath")" == "FOUND" ]; then
      echo "ERROR"
    else
      echo "NOTFOUND"
    fi
  fi
}

append_lines_if_not_found() {
  local first_line=$1
  local second_line=$2
  local rel_filepath=$3

  local has_block
  has_block=$(has_two_consecutive_lines "$first_line" "$second_line" "$rel_filepath")

  if [ "$has_block" == "NOTFOUND" ]; then
    echo "$first_line" | sudo tee -a "$rel_filepath"
    echo "$second_line" | sudo tee -a "$rel_filepath"
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
# TODO(a-t-0): change root with Global variable.
#######################################
# Structure:Parsing
# allows a string with spaces, hence allows a line
file_contains_string() {
  STRING=$1
  relative_filepath=$2

  if grep -q "$STRING" "$relative_filepath"; then
    echo "FOUND"
  else
    echo "NOTFOUND"
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
# TODO(a-t-0): change root with Global variable.
#######################################
# Structure:Parsing
get_line_nr() {
  #eval STRING="$1"
  local string="$1"
  relative_filepath=$2
  local line_nr
  line_nr="$(grep -n "$string" "$relative_filepath" | head -n 1 | cut -d: -f1)"
  echo "$line_nr"
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
# TODO(a-t-0): change root with Global variable.
#######################################
# Structure:Parsing
get_line_by_nr() {
  number=$1
  relative_filepath=$2
  #read -p "number=$number"
  #read -p "relative_filepath=$relative_filepath"
  the_line=$(sed "${number}q;d" "$relative_filepath")
  echo "$the_line"
}
