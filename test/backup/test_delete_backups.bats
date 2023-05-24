#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "Creates dummy backup files and verifies the get_backup_dates function in /src/backup/exponential_backups.sh finds them." {
  # Load the function that is to be tested.
  source src/backup/exponential_backups.sh

  # Create an empty dummy backup file directory.
  local dummy_backup_path="test/dummy_backups"
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
  touch "$dummy_backup_path/20230524-015550.tar.gz"
  touch "$dummy_backup_path/20230524-016550.tar.gz"
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
  touch "$dummy_backup_path/20230524-016550.tar.gz"
  touch "$dummy_backup_path/20230525-016550.tar.gz"
  touch "$dummy_backup_path/20230526-016550.tar.gz"
  touch "$dummy_backup_path/20230527-016550.tar.gz"

  # Run function that is tested.
  run find_and_delete_unwanted_backups "$dummy_backup_path" "tar.gz"

  # Verify result is as expected.
  assert_output "20230510"

  # Delete dummy backup directory.
  rm -r -f "$dummy_backup_path"
  # TODO: assert dummy backup path does not exists.
}
