#!/usr/bin/env bash

install_tor_and_nextcloud() {
  ensure_apt_pkg "tor"
  ensure_apt_pkg "httping"
  ensure_apt_pkg "torsocks"
  ensure_snap_pkg "nextcloud" 1
}
