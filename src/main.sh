#!/usr/bin/env bash
# Parses the CLI arguments given to this file, and installs Nextcloud over Tor
# accordingly.

source src/cli_usage.sh
source src/arg_parser/arg_parser.sh
source src/arg_parser/process_args.sh
source src/GLOBAL_VARS.sh
source src/cli_logger.sh
source src/config/configure_android_apps.sh
source src/config/configure_khal.sh
source src/config/configure_nextcloud.sh
source src/config/configure_tor.sh
source src/config/configure_vdirsyncer.sh
source src/config/helper_tor_parsing.sh
source src/connectivity_checks.sh
source src/helper.sh
source src/install/install_android_apps.sh
source src/install/install_apk.sh
source src/install/install_apt.sh
source src/install/install_pip.sh
source src/install/install_snap.sh
source src/install/prereq_nextcloud.sh
source src/run_tor/ensure_tor_runs.sh
source src/uninstall/uninstall_apk.sh
source src/verification/assert_tor_settings.sh
source src/uninstall/uninstaller.sh

# print the usage if no arguments are given
[ $# -eq 0 ] && {
  print_usage
  exit 1
}
parse_args "$@"

# Parse CLI arguments and store configuration settings accordingly.
