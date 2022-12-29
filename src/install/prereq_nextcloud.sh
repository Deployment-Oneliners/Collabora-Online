#!/usr/bin/env bash

install_tor_and_nextcloud() {
  ensure_apt_pkg tor 1
  ensure_snap_pkg nextcloud 1
}
