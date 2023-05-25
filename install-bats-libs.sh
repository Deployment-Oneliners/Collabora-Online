#!/usr/bin/env bash

# Remove the submodules if they were still in the repo.
git rm --cached test/libs/bats
git rm --cached test/libs/bats-assert
git rm --cached test/libs/bats-file
git rm --cached test/libs/bats-support

# Remove and re-create the submodule directory.
rm -r test/libs
mkdir -p test/libs

# (Re) add the BATS submodules to this repository.
git submodule add --force https://github.com/sstephenson/bats test/libs/bats
git submodule add --force https://github.com/ztombol/bats-assert test/libs/bats-assert
git submodule add --force https://github.com/ztombol/bats-file test/libs/bats-file
git submodule add --force https://github.com/ztombol/bats-support test/libs/bats-support
