#!/usr/bin/env bash
# Parses the CLI arguments given to this file, and installs Nextcloud over Tor
# accordingly.

source src/cli_usage.sh
source src/process_args.sh
# shellcheck disable=SC1091
source src/uninstall/uninstaller.sh

# print the usage if no arguments are given
[ $# -eq 0 ] && {
  print_usage
  exit 1
}
parse_args "$@"







# Parse CLI arguments and store configuration settings accordingly.


