#!./test/libs/bats/bin/bats

load '../libs/bats-support/load'
load '../libs/bats-assert/load'

@test "Creates dummy backup files and verifies the get_backup_dates function in /src/backup/exponential_backups.sh finds them." {
  # Load the function that is to be tested.
  source src/backup/exponential_backups.sh

  # Create an empty dummy backup file directory.
  local list_of_dates=("20230508" "20230509" "20230510" "20230511" "20230512" "20230513" "20230514" "20230515" "20230516" "20230517" "20230518" "20230519" "20230520" "20230522" "20230523" "20230524" "20230525" "20230526" "20230527" "20230528" "20230529" "20230530" "20230610")
  local current_date="2023-05-25"
  local inverse="false"

  # Run function that is tested.
  run get_backup_dates_to_keep_or_delete "$current_date" "$inverse" "${list_of_dates[@]}"

  # Verify result is as expected.
  assert_output """20230512
20230516
20230518
20230520
20230522
20230523
20230524
20230525
20230526
20230527
20230528
20230529
20230530
20230610"""

  # Simulate moving further into the future.
  local current_date="2023-06-25"
  # Run function that is tested.
  run get_backup_dates_to_keep_or_delete "$current_date" "$inverse" "${list_of_dates[@]}"

  # Verify less backups are kept from the predetermined range.
  assert_output """20230512
20230528"""

}
