#!/usr/bin/env bash

install_tor_and_nextcloud() {
  ensure_apt_pkg "tor" 1
  ensure_apt_pkg "httping" 1
  ensure_apt_pkg "torsocks" 1
  ensure_snap_pkg "nextcloud" 1
}
