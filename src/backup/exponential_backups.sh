#!/bin/bash
#
# (Original) Written by Aaron Lindsay <aaron@aclindsay.com>

# These knobs control which backups to keep, and how long to keep them for. A
# backup is kept if its distance from the UNIX epoch in days divides (with zero
# remainder) by BASE^power (where power is some integer 0 < MAX_POWER), and it
# is less than WINDOW_FACTOR*BASE^power days old.
BASE=2
MAX_POWER=16
WINDOW_FACTOR=4
# It can be noted that the base**power creates a fixed range of numbers, e.g.
# 2,4,8,16,32. "Somehow", by dividing the list of day numbers of the backups,
# with this fixed list and only keeping the days that have a zero remainder,
# you get a list of fixed dates from any day back into the past. Because that
# list of backup dates to keep, is fixed, it does not erase all preserved
# backups the next day. If you move far enough into the future, the list does
# not shift, instead, some of the entries in the list drop out, to preserve the
# exponential steps/backup. # This is experimentally validated.

inverse="false"
current_date=$(date -I)
input="/dev/stdin"

# Returns output if the date passed in as the first argument is not in a format
# 'date' can understand
function invalid_date() {
  date -d "$1 + 1 min" +"%s" &>/dev/null
  # shellcheck disable=SC2181
  if [[ $? -ne 0 ]]; then
    echo "invalid"
  fi
}

# Return the number of days which passed between the UNIX epoch and the first
# argument
function days_since_epoch() {
  echo $(($(date -d "$1" +"%s") / (60 * 60 * 24)))
}

# Prints "keep" if the backup with the indicated date should be kept
function keep_backup() {
  local current_day_count="$1"
  local backup_day_count="$2"
  local difference=$((current_day_count - backup_day_count))
  for ((power = 0; power <= MAX_POWER; power++)); do
    # Exponential factor based on the power and base
    local factor=$((BASE ** power))
    # Remainder of backup day count divided by the factor
    local remainder=$((backup_day_count % factor))

    # Check if the remainder is zero and the difference is within the window factor
    if [[ $remainder -eq 0 ]] && [[ $difference -le $((factor * WINDOW_FACTOR)) ]]; then
      echo "true" # Print "true" indicating the backup should be kept.
      return
    fi
  done
  echo "false"
}

function get_backup_dates() {
  local backup_path="$1"
  local extension_without_dot="$2"

  if [[ ! -d "$backup_path" ]]; then
    echo "Error, backup directory:$backup_path not found."
    exit
  fi

  for filepath in "$backup_path"/*."$extension_without_dot"; do
    if [ -f "$filepath" ]; then

      local filename
      filename=$(basename "$filepath")
      local filename_without_extension
      filename_without_extension="${filename%%."$extension_without_dot"}"

      # Split format:20230524-015550 into: 20230524 to get the date.
      IFS="-" read -ra parts <<<"$filename_without_extension"
      local date_nrs="${parts[0]}"

      # If the date is numeric, echo it.
      if [[ "$(is_numeric "$date_nrs")" == "true" ]]; then
        echo "$date_nrs"
      fi
    fi
  done

}

is_numeric() {
  local input="$1"
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Echos the backups to keep or delete.
function get_backup_dates_to_keep_or_delete() {
  local current_date="$1"
  local inverse="$2"
  shift
  shift
  local list_of_dates=("$@")

  # Convert the current day into a day count/nr.
  current_days=$(days_since_epoch "$current_date")

  # IFS=, read -r -a arr <<<"${list_of_dates}"
  # echo "arr=${arr[@]}"
  for some_backup_date in "${list_of_dates[@]}"; do

    # Verify the found backup date has a valid format.
    if [[ $(invalid_date "$some_backup_date") ]]; then
      echo "Error: \"$some_backup_date\" is not a valid date" 1>&2
      exit 1
    fi
    # Convert the backup date to a day count/nr.
    backup_days=$(days_since_epoch "$some_backup_date")

    # Determine whether this number is in the exponential range of days to keep.
    local keep
    keep="$(keep_backup "$current_days" "$backup_days")"

    # Echo the backup days to keep (or delete if inverse is true)
    if [[ "$inverse" == "false" ]] && [[ "$keep" == "true" ]]; then
      echo "$some_backup_date"
    elif [[ "$inverse" == "true" ]] && [[ "$keep" == "false" ]]; then
      echo "$some_backup_date"
    fi
  done
}

function usage() {
  cat <<EOF
Usage: $0 options

Print the backups which should (or should not with -r) be kept from a list of
dates passed via stdin.

OPTIONS:
   -h       Show this message
   -i FILE  Read candidate backup dates from FILE instead of stdin
   -d DATE  Calculate which backups should be kept from this date instead of
            today
   -r       Reverse which dates are displayed (show those which should be
            deleted instead of kept)
EOF
}

while getopts "hrd:i:" OPTION; do
  case $OPTION in
    i)
      input=$OPTARG
      if [[ ! -f $input ]]; then
        echo "Error: \"$input\" is not a file" 1>&2
        usage
        exit 1
      fi
      ;;
    d)
      current_date=$OPTARG
      if [[ $(invalid_date "$current_date") ]]; then
        echo "Error: \"$current_date\" is not a valid date" 1>&2
        usage
        exit 1
      fi
      ;;
    r)
      inverse="true"
      ;;
    h)
      usage
      exit
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done

get_backup_dates_to_keep_or_delete "$current_date" "$inverse" "${list_of_dates[@]}"

#get_backup_dates
