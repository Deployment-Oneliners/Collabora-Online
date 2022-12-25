#!/usr/bin/env bash

git rm --cached test/libs/bats
git rm --cached test/libs/bats-support
git rm --cached test/libs/bats-assert

rm -r test/libs
mkdir -p test/libs

git submodule add --force https://github.com/sstephenson/bats test/libs/bats
git submodule add --force https://github.com/ztombol/bats-support test/libs/bats-support
git submodule add --force https://github.com/ztombol/bats-assert test/libs/bats-assert
