#!/usr/bin/env bash

assert_phone_is_connected_via_adb() {
  # Assert phone is connected through adb.
  if ! command -v adb &>/dev/null || ! adb devices | grep -q "^[^*]*device$"; then
    echo "Error, please make sure your phone is connected through adb."
    exit 7
  fi
}

wait_until_phone_is_connected_via_adb_and_online() {
  local max_wait_sec="$1"
  local wait_sec
  wait_sec=0
  while true;
  do
    if [[ "$wait_sec" -gt "$max_wait_sec" ]]; then
      echo "Timout error, device did not come back online via adb. Please retry."
      exit 5
    fi

    # Assert phone is connected through adb.
    if ! command -v adb &>/dev/null || ! adb devices | grep -q "^[^*]*device$"; then

      let wait_sec=wait_sec+1
      echo "Please wait untill your phone ADB connection is online again [$wait_sec/$max_wait_sec])"
      adb devices
      sleep 1
    else
      echo "(Re-)Established adb phone connection:"
      adb devices
      break
    fi
  done
}

assert_phone_has_internet_connection() {
  
  # Assert phone is connected through adb.
  assert_phone_is_connected_via_adb

  # Assert phone has internet access (to github.com).
  adb shell ping -c1 github.com &>/dev/null
  if [ $? -eq 0 ]
  then 
    echo "Phone has internet access."
  else
    echo "Please ensure your phone has internet access, and try again."
    exit 5
  fi
}



wait_untill_phone_has_internet_acces() {
while true;
do
  adb shell ping -c1 github.com &>/dev/null
  if [ $? -eq 0 ]
  then 
    echo "FOUND"
    break
  else
    echo "Please ensure your phone has internet access (and just wait, code will retry)."
    sleep 2
  fi
done
}