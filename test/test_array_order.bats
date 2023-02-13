#!./test/libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

@test "element_one_before_two_in_csv returns BEFORE for correct found order." {
  source ./src/helper.sh

  # Run function that is tested.
  run element_one_before_two_in_csv "two" "three" "one,two,three,four"
  assert_output "BEFORE"

}

@test "element_one_before_two_in_csv returns AFTER for switched order." {
  source ./src/helper.sh

  run element_one_before_two_in_csv "three" "two" "one,two,three,four"
  assert_output "AFTER"
}

@test "element_one_before_two_in_csv raises error if first element is missing." {
  source ./src/helper.sh

  run element_one_before_two_in_csv "banana" "two" "one,two,three,four"
  assert_failure
  assert_output -p "Error, did not find element:banana in: one,two,three,four"
}

@test "element_one_before_two_in_csv raises error if second element is missing." {
  source ./src/helper.sh

  run element_one_before_two_in_csv "four" "banana" "one,two,three,four"
  assert_failure
  assert_output -p "Error, did not find element:banana in: one,two,three,four"
}
