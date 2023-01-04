#!/usr/bin/env bash

# Print CLI usage options
print_usage() {
  printf "\n\nDefault usage, write:"
  printf "\nsrc/main.sh -cn -ct -i -nu <your Nextcloud username> -np\n                                      to set up a Nextcloud server over tor.\n"

  printf "\nSupported options:"
  printf "\n-cn | --configure-nextcloud           to configure nextcloud with a default account."
  printf "\n-ct | --configure-tor                 to configure Tor with to facilitate nextcloud access over Tor."
  printf "\n-h | --https                          to support HTTPS for .onion domain on server."
  printf "\n-i | --install-tor-nextcloud          to install Tor and Nextcloud."
  printf "\n-nu <your Nextcloud username> | --nextcloud-username <your Nextcloud username>\n                                      to pass your Nextcloud username."
  printf "\n-np | --nextcloud-password            to get a prompt for your Nextcloud password, so you don't have to wait to enter it manually."
  printf "\n-s | --start-tor                      to start tor."

  printf "\n\n\nNot yet supported:"
  printf "\n-b | --boot                           to configure a cronjob to run tor at boot."

  printf "\n\n\nyou can also combine the separate arguments in different orders, e.g. -nu -np.\n\n"
}