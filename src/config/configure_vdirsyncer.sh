#!/usr/bin/env bash

create_vdirsyncer_config() {
  local nextcloud_username="$1"
  local nextcloud_password="$2"
  local onion_address="$3"
  local vdirsyncer_config_filename="$4"
  local vdirsyncer_config_path="$5"
  local vdirsyncer_calendar_path="$6"
  local vdirsyncer_contacts_path="$7"
  local vdirsyncer_status_path="$8"
  local external_nextcloud_port="$9"

  local vdirsyncer_config_filepath
  vdirsyncer_config_filepath="$vdirsyncer_config_path/$vdirsyncer_config_filename"

  create_vdirsyncer_dirs "$vdirsyncer_config_path" "$vdirsyncer_calendar_path" "$vdirsyncer_contacts_path" "$vdirsyncer_status_path" "$ROOT_CA_PEM_PATH"
  # TODO: Verify Nextcloud username and password work before setting it to config.

  # Modify the vdirsyncer config template.
  create_vdirsyncer_config_file "$nextcloud_username" "$nextcloud_password" "$onion_address" "$vdirsyncer_config_filepath" "$vdirsyncer_calendar_path" "$vdirsyncer_contacts_path" "$vdirsyncer_status_path" "$ROOT_CA_PEM_PATH" "$external_nextcloud_port"
  manual_assert_file_exists "$vdirsyncer_config_filepath"

}

# TODO: write method to update Nextcloud username and password.
# TODO: instead of writing username and password to txt file use safer method.

create_vdirsyncer_dirs() {
  local vdirsyncer_config_path="$1"
  local vdirsyncer_calendar_path="$2"
  local vdirsyncer_contacts_path="$3"
  local vdirsyncer_status_path="$4"
  local ROOT_CA_PEM_PATH="$5"

  manual_assert_file_exists "$ROOT_CA_PEM_PATH"

  mkdir -p "$vdirsyncer_config_path"
  manual_assert_dir_exists "$vdirsyncer_config_path"
  mkdir -p "$vdirsyncer_calendar_path"
  manual_assert_dir_exists "$vdirsyncer_calendar_path"
  mkdir -p "$vdirsyncer_contacts_path"
  manual_assert_dir_exists "$vdirsyncer_contacts_path"
  mkdir -p "$vdirsyncer_status_path"
  manual_assert_dir_exists "$vdirsyncer_status_path"
}

#######################################
# Replaces each line in a file that starts with "verify = " with an incoming line.
#
# Local variables:
#  input_path: the file path of the input file
#  incoming_line: the incoming line to be added to the file
#
# Globals:
#  None.
# Arguments:
#  $1: the input file path
#  $2: the incoming line to be added to the file
#
# Returns:
#  0 if successful
#  7 if an error occurred
# Outputs:
#  None.
#######################################
replace_line_in_file() {
  local input_path="$1"
  local incoming_line="$2"

  if ! test -f "$input_path"; then
    echo "Error: file not found at $input_path"
    return 7
  fi

  # Replace each line in the file that starts with "verify = " with the incoming line
  sed -i "s/^verify =.*/$incoming_line/" "$input_path"

  return 0
}

get_sha256_fingerprint() {
  local onion_address="$1"
  local external_nextcloud_port="$2"

  local fingerprint_output
  fingerprint_output="$(echo -n | torify openssl s_client -connect "$onion_address:$external_nextcloud_port" | openssl x509 -noout -fingerprint -sha256)"

  local sha_fingerprint_identifier='SHA256 Fingerprint='
  if [[ "$fingerprint_output" != "$sha_fingerprint_identifier"* ]]; then
    echo "Error, did not find SHA256 fingerprint."
    exit
  fi

  # Remove the identifier, to get the pure fingerprint.
  local sha256_fingerprint="${fingerprint_output:19}"
  echo "$sha256_fingerprint"

  # Regular expression pattern for SHA256 fingerprint
  # local pattern="^[0-9a-f]{64}$"
  # local pattern="^([0-9a-f]{2}:){31}[0-9a-f]{2}$"
  # if [[ "$sha256_fingerprint" =~ "$pattern" ]]; then
  # echo "String is a valid SHA256 fingerprint."
  # else
  # echo "String is not a valid SHA256 fingerprint."
  # exit
  # fi
}

create_vdirsyncer_config_file() {
  local nextcloud_username="$1"
  local nextcloud_password="$2"
  local onion_address="$3"
  local vdirsyncer_config_filepath="$4"
  local vdirsyncer_calendar_path="$5"
  local vdirsyncer_contacts_path="$6"
  local vdirsyncer_status_path="$7"
  local ROOT_CA_PEM_PATH="$8"
  local external_nextcloud_port="$9"

  cat >"$vdirsyncer_config_filepath" <<-EndOfMessage
[general]
status_path = "$vdirsyncer_status_path"

[pair my_contacts]
a = "my_contacts_local"
b = "my_contacts_remote"
collections = ["from a", "from b"]
conflict_resolution = "b wins"

[storage my_contacts_local]
type = "filesystem"
path = "$vdirsyncer_contacts_path"
fileext = ".vcf"

[storage my_contacts_remote]
type = "carddav"
verify = "$PWD/ssl4tor/certificates/root/$CA_PUBLIC_KEY_FILENAME"

# We can simplify this URL here as well. In theory it shouldn't matter.
url = "https://localhost:$external_nextcloud_port"
username = "$nextcloud_username"
password = "$nextcloud_password"

[pair my_calendar]
a = "my_calendar_local"
b = "my_calendar_remote"
collections = ["from a", "from b"]
conflict_resolution = "b wins"

[storage my_calendar_local]
type = "filesystem"
path = "$vdirsyncer_calendar_path"
fileext = ".ics"

[storage my_calendar_remote]
type = "caldav"
verify = "$PWD/ssl4tor/certificates/root/$CA_PUBLIC_KEY_FILENAME"

# We can simplify this URL here as well. In theory it shouldn't matter.
url = "https://localhost:$external_nextcloud_port"
username = "$nextcloud_username"
password = "$nextcloud_password"
EndOfMessage
}

create_vdirsyncer_config_file_to_onion() {
  local nextcloud_username="$1"
  local nextcloud_password="$2"
  local onion_address="$3"
  local vdirsyncer_config_filepath="$4"
  local vdirsyncer_calendar_path="$5"
  local vdirsyncer_contacts_path="$6"
  local vdirsyncer_status_path="$7"
  local ROOT_CA_PEM_PATH="$8"
  local external_nextcloud_port="$9"

  local sha256_fingerprint
  sha256_fingerprint=$(get_sha256_fingerprint "$onion_address" "$external_nextcloud_port")
  # TODO: verify SHA256 format.
  if [[ "$sha256_fingerprint" == "" ]]; then
    echo "Error, fingerprint not found."
    exit
  fi

  cat >"$vdirsyncer_config_filepath" <<-EndOfMessage
[general]
status_path = "$vdirsyncer_status_path"

[pair my_contacts]
a = "my_contacts_local"
b = "my_contacts_remote"
collections = ["from a", "from b"]
conflict_resolution = "b wins"

[storage my_contacts_local]
type = "filesystem"
path = "$vdirsyncer_contacts_path"
fileext = ".vcf"

[storage my_contacts_remote]
type = "carddav"
verify_fingerprint = "$sha256_fingerprint"

# We can simplify this URL here as well. In theory it shouldn't matter.
url = "https://$onion_address:$external_nextcloud_port"
username = "$nextcloud_username"
password = "$nextcloud_password"

[pair my_calendar]
a = "my_calendar_local"
b = "my_calendar_remote"
collections = ["from a", "from b"]
conflict_resolution = "b wins"

[storage my_calendar_local]
type = "filesystem"
path = "$vdirsyncer_calendar_path"
fileext = ".ics"

[storage my_calendar_remote]
type = "caldav"
verify_fingerprint = "$sha256_fingerprint"

# We can simplify this URL here as well. In theory it shouldn't matter.
url = "https://$onion_address:$external_nextcloud_port"
username = "$nextcloud_username"
password = "$nextcloud_password"
EndOfMessage
}
