#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "Creates dummy backup files and verifies the get_backup_dates function in /src/backup/exponential_backups.sh finds them." {
  # Load the function that is to be tested.
  source src/backup/exponential_backups.sh
  BASE=2
  MAX_POWER=16
  WINDOW_FACTOR=4

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
  touch "$dummy_backup_path/20230524-016550.tar.gz"
  touch "$dummy_backup_path/20220524-015550.tar.gz"
  touch "$dummy_backup_path/20230524-015550.tar.gz"
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
  local backup_dates
  # run get_backup_dates "$dummy_backup_path" "tar.gz" backup_dates
  get_backup_dates "$dummy_backup_path" "tar.gz" backup_dates
  declare -p backup_dates

  # Verify result is as expected.
  assert_equal "${backup_dates[0]}" "20220524"
  assert_equal "${backup_dates[1]}" "20220524"
  assert_equal "${backup_dates[2]}" "20230510"
  assert_equal "${backup_dates[3]}" "20230511"
  assert_equal "${backup_dates[4]}" "20230512"
  assert_equal "${backup_dates[5]}" "20230513"
  assert_equal "${backup_dates[6]}" "20230514"
  assert_equal "${backup_dates[7]}" "20230515"
  assert_equal "${backup_dates[8]}" "20230516"
  assert_equal "${backup_dates[9]}" "20230517"
  assert_equal "${backup_dates[10]}" "20230518"
  assert_equal "${backup_dates[11]}" "20230519"
  assert_equal "${backup_dates[12]}" "20230520"
  assert_equal "${backup_dates[13]}" "20230521"
  assert_equal "${backup_dates[14]}" "20230522"
  assert_equal "${backup_dates[15]}" "20230523"
  assert_equal "${backup_dates[16]}" "20230524"
  assert_equal "${backup_dates[17]}" "20230524"
  assert_equal "${backup_dates[18]}" "20230525"
  assert_equal "${backup_dates[19]}" "20230526"
  assert_equal "${backup_dates[20]}" "20230527"
  assert_equal "${backup_dates[21]}" ""

  # Delete dummy backup directory.
  rm -r -f "$dummy_backup_path"
  # TODO: assert dummy backup path does not exists.
}
