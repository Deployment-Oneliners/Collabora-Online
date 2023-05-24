#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'
load '../libs/bats-file/load'

# Load the function that is to be tested.
source src/backup/exponential_backups.sh
BASE=2
MAX_POWER=16
WINDOW_FACTOR=4

# Create an empty dummy backup file directory.
dummy_backup_path="test/dummy_backups"

setup() {

  if [[ -d "$dummy_backup_path" ]]; then
    rm -rf "$dummy_backup_path"
  fi
  mkdir -p "$PWD/$dummy_backup_path"
  #
  if [[ ! -d "$dummy_backup_path/" ]]; then
    echo "Error, backup path:$dummy_backup_path not found."
    exit
  fi
  # TODO: assert dummy backup path is empty.

  # Create dummy backup files
  touch "$dummy_backup_path/20220524-015550.tar.gz"
  touch "$dummy_backup_path/20220524-016550.tar.gz"
  touch "$dummy_backup_path/20230510-016550.tar.gz"
  touch "$dummy_backup_path/20230511-016550.tar.gz"
  touch "$dummy_backup_path/20230512-016550.tar.gz"
  touch "$dummy_backup_path/20230513-016550.tar.gz"
  touch "$dummy_backup_path/20230514-016550.tar.gz"
  touch "$dummy_backup_path/20230515-016550.tar.gz"
  touch "$dummy_backup_path/20230516-016550.tar.gz"
  touch "$dummy_backup_path/20230517-016550.tar.gz"
  touch "$dummy_backup_path/20230518-016550.tar.gz"
  touch "$dummy_backup_path/20230519-016550.tar.gz"
  touch "$dummy_backup_path/20230520-016550.tar.gz"
  touch "$dummy_backup_path/20230521-016550.tar.gz"
  touch "$dummy_backup_path/20230522-016550.tar.gz"
  touch "$dummy_backup_path/20230523-016550.tar.gz"
  touch "$dummy_backup_path/20230524-015550.tar.gz"
  touch "$dummy_backup_path/20230524-016550.tar.gz"
  touch "$dummy_backup_path/20230524-016550.tar.gz"
  touch "$dummy_backup_path/20230525-016550.tar.gz"
  touch "$dummy_backup_path/20230526-016550.tar.gz"
  touch "$dummy_backup_path/20230527-016550.tar.gz"

}

@test "Creates dummy backup files and verifies delete_unwanted_backups in /src/backup/exponential_backups.sh deletes the unwanted dummy backup files." {

  local current_date="2023-05-25"
  local inverse="false"

  # Create the array with dates of backup files.
  local backup_dates
  get_backup_dates "$dummy_backup_path" "tar.gz" backup_dates
  declare -p backup_dates

  # Run function that is tested.
  run delete_unwanted_backups "$current_date" "$inverse" "$dummy_backup_path" "tar.gz" "${backup_dates[@]}"

  # Verify the backup files that were not within the exponential date, have been deleted.
  assert_file_not_exist "$dummy_backup_path/20220524-015550.tar.gz"
  assert_file_not_exist "$dummy_backup_path/20220524-016550.tar.gnot_z"

  assert_file_not_exist "$dummy_backup_path/20230510-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230511-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230512-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230513-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230514-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230515-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230516-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230517-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230518-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230519-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230520-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230521-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230522-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230523-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230524-015550.tar.gz"
  assert_file_exist "$dummy_backup_path/20230524-016550.tar.gz"
  assert_file_exist "$dummy_backup_path/20230524-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230525-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230526-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230527-016550.tar.gz"

  # Delete dummy backup directory.
  rm -r -f "$dummy_backup_path"
  if [[ -d "$dummy_backup_path" ]]; then
    echo "Error, backup path:$dummy_backup_path found after deletion."
    exit
  fi
}

@test "Creates dummy backup files and verifies delete_unwanted_backups in /src/backup/exponential_backups.sh deletes more files further into the future." {

  local current_date="2023-06-25"
  local inverse="false"

  # Create the array with dates of backup files.
  local backup_dates
  get_backup_dates "$dummy_backup_path" "tar.gz" backup_dates
  declare -p backup_dates

  # Run function that is tested.
  run delete_unwanted_backups "$current_date" "$inverse" "$dummy_backup_path" "tar.gz" "${backup_dates[@]}"

  # Verify the backup files that were not within the exponential date, have been deleted.
  assert_file_not_exist "$dummy_backup_path/20220524-015550.tar.gz"
  assert_file_not_exist "$dummy_backup_path/20220524-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230510-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230511-016550.tar.gz"

  assert_file_exist "$dummy_backup_path/20230512-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230513-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230514-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230515-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230516-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230517-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230518-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230519-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230520-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230521-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230522-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230523-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230524-015550.tar.gz"
  assert_file_not_exist "$dummy_backup_path/20230524-016550.tar.gz"
  assert_file_not_exist "$dummy_backup_path/20230524-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230525-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230526-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230527-016550.tar.gz"

  #
  # Delete dummy backup directory.
  rm -r -f "$dummy_backup_path"
  if [[ -d "$dummy_backup_path" ]]; then
    echo "Error, backup path:$dummy_backup_path found after deletion."
    exit
  fi
}

@test "Deleted as seen on current date 2024-06-25." {

  local current_date="2024-06-25"
  local inverse="false"

  # Create the array with dates of backup files.
  local backup_dates
  get_backup_dates "$dummy_backup_path" "tar.gz" backup_dates
  declare -p backup_dates

  # Run function that is tested.
  run delete_unwanted_backups "$current_date" "$inverse" "$dummy_backup_path" "tar.gz" "${backup_dates[@]}"

  # Verify the backup files that were not within the exponential date, have been deleted.
  assert_file_not_exist "$dummy_backup_path/20220524-015550.tar.gz"
  assert_file_not_exist "$dummy_backup_path/20220524-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230510-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230511-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230512-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230513-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230514-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230515-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230516-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230517-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230518-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230519-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230520-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230521-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230522-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230523-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230524-015550.tar.gz"
  assert_file_not_exist "$dummy_backup_path/20230524-016550.tar.gz"
  assert_file_not_exist "$dummy_backup_path/20230524-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230525-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230526-016550.tar.gz"

  assert_file_not_exist "$dummy_backup_path/20230527-016550.tar.gz"

  # Delete dummy backup directory.
  rm -r -f "$dummy_backup_path"
  if [[ -d "$dummy_backup_path" ]]; then
    echo "Error, backup path:$dummy_backup_path found after deletion."
    exit
  fi
}
