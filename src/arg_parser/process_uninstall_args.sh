#!/usr/bin/env bash
uninstall_calendar_client() {
  local uninstall_calendar_client_flag="$1"

  if [ "$uninstall_calendar_client_flag" == "true" ]; then
    apt_remove "vdirsyncer"

    # Remove configuration files.
    rm -r "$VDIRSYNCER_CONFIG_PATH"

    # Assert dir does not exist.
    manual_assert_dir_not_exists "$VDIRSYNCER_CONFIG_PATH"

    # Remove Khal
    apt_remove "khal"

    rm -r "$VDIRSYNCER_CONTACTS_PATH"
    manual_assert_dir_not_exists "$VDIRSYNCER_CONTACTS_PATH"
    rm -r "$VDIRSYNCER_CALENDAR_PATH"
    manual_assert_dir_not_exists "$VDIRSYNCER_CALENDAR_PATH"
    rm -r "$KHAL_CONFIG_PATH"
    manual_assert_dir_not_exists "$KHAL_CONFIG_PATH"
  fi
}
