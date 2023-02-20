#!/usr/bin/env bash

# shellcheck disable=SC1091
source src/config/setup_ssl.sh

remove_installation_artifacts() {
  sudo rmdir -f /usr/local/share/ca-certificates/$FIREFOX_CA_DIR
  # TODO: verify directory is deleted.
}
