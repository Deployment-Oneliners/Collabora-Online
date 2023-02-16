#!/usr/bin/env bash

# Print CLI usage options
print_usage() {
  printf "\n\nDefault usage, write:"
  printf "\nsrc/main.sh -cn -ct -i -nu <your Nextcloud username> -np\n                                      to set up a Nextcloud server over tor.\n"

  printf "\nSupported options:"
  printf "\n-ar | --android-reinstall <appname_0,app_name1,app_name2> \n                                      to remove and reinstall android apps."
  printf "\n-ac | --android-configure <appname_0,app_name1,app_name2> \n                                      to configure android apps to use Nextcloud."
  printf "\n-cn | --configure-nextcloud           to configure nextcloud with a default account."
  printf "\n-cs | --calendar-server               to enable the calendar app within snap Nextcloud on your pc."
  printf "\n-ct | --configure-tor                 to configure Tor with to facilitate nextcloud access over Tor."
  printf "\n-h | --https                          to support HTTPS for .onion domain on server, and make Firefox trust it."
  printf "\n-i | --install-tor-nextcloud          to install Tor and Nextcloud."
  printf "\n-no | --new-onion                     to create a new onion domain (e.g. if you accidentally shared your onion domain and/or private key.)."
  printf "\n-nu <your Nextcloud username> | --nextcloud-username <your Nextcloud username>\n                                      to pass your Nextcloud username."
  printf "\n-np | --nextcloud-password            to get a prompt for your Nextcloud password, so you don't have to wait to enter it manually."
  printf "\n-o | --get-onion                      to show your private .onion url."
  printf "\n-s | --start-tor                      to start tor."

  printf "\n\n\nNot yet supported:"
  printf "\n-ar | --android-reinstall <appname_0,app_name1,app_name2> \n                                      to configure android apps to sync with Nextcloud."
  printf "\n-b | --boot                           to configure a cronjob to run tor at boot."

  printf "\n\n\nyou can also combine the separate arguments in different orders, e.g. -nu -np.\n\n"
}
