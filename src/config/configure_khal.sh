#!/usr/bin/env bash

enable_calendar_app_in_nextcloud() {
  sudo /snap/bin/nextcloud.occ app:install calendar
}

create_khal_config() {
  local khal_config_filename="$1"
  local khal_config_path="$2"
  local vdirsyncer_calendar_path="$3"
  local vdirsyncer_contacts_path="$4"

  local khal_config_filepath
  khal_config_filepath="$khal_config_path/$khal_config_filename"

  create_khal_dirs "$khal_config_path" "$vdirsyncer_calendar_path" "$vdirsyncer_contacts_path"

  # Modify the vdirsyncer config template.
  create_khal_config_file "$khal_config_filepath" "$vdirsyncer_calendar_path" "$vdirsyncer_contacts_path"
  manual_assert_file_exists "$khal_config_filepath"
}

# TODO: write method to update Nextcloud username and password.
# TODO: instead of writing username and password to txt file use safer method.

create_khal_dirs() {
  local khal_config_path="$1"
  local vdirsyncer_calendar_path="$2"
  local vdirsyncer_contacts_path="$3"

  mkdir -p "$khal_config_path"
  manual_assert_dir_exists "$khal_config_path"
  mkdir -p "$vdirsyncer_calendar_path"
  manual_assert_dir_exists "$vdirsyncer_calendar_path"
  mkdir -p "$vdirsyncer_contacts_path"
  manual_assert_dir_exists "$vdirsyncer_contacts_path"
}

create_khal_config_file() {
  local khal_config_filepath="$1"
  local vdirsyncer_calendar_path="$2"
  local vdirsyncer_contacts_path="$3"

  cat >"$khal_config_filepath" <<-EndOfMessage
[calendars]

[[my_calendar_local]]
path = $vdirsyncer_calendar_path*
type = discover

[[my_contacts_local]]
path = $vdirsyncer_contacts_path*
type = discover

[locale]
timeformat = %H:%M
dateformat = %Y-%m-%d
longdateformat = %Y-%m-%d
datetimeformat = %Y-%m-%d %H:%M
longdatetimeformat = %Y-%m-%d %H:%M

[default]
highlight_event_days = True
show_all_days = True

[view]
frame = color
theme = dark

[highlight_days]
color = ''
default_color = yellow
method = foreground
multiple = ''
EndOfMessage
}
