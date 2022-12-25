#!/usr/bin/env bash
source src/install/install_apt.sh
source src/install/install_snap.sh

satisfy_nextcloud_prereq() {
  #ensure_apt_pkg tor 1
  ensure_snap_pkg nextcloud 1
}
