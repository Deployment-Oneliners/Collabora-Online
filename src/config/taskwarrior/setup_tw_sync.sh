#!/usr/bin/env bash
# Sets up taskwarrior sync with Nextcloud.
taskwarrior_sync() {
  local taskwarrior_sync_flag="$1"
  local local_https_nextcloud_port="$2"
  local nextcloud_password="$3"
  local nextcloud_username="$4"

  if [ "$taskwarrior_sync_flag" == "true" ]; then
    assert_is_non_empty_string "${local_https_nextcloud_port}" "local_https_nextcloud_port"
    assert_is_non_empty_string "${nextcloud_password}" "nextcloud_password"
    assert_is_non_empty_string "${nextcloud_username}" "nextcloud_username"

    ensure_pip_pkg "syncall"
    ensure_pip_pkg "caldav"
    ensure_pip_pkg "syncall[caldav,tw]"

    export CALDAV_PASSWD="$nextcloud_password"

    tw_caldav_sync \
      --taskwarrior-all-tasks \
      --caldav-calendar taskwarrior \
      --caldav-url "https://localhost:$local_https_nextcloud_port" \
      --caldav-user "$nextcloud_username" \
      --caldav-passwd "$nextcloud_password"
  fi
}
