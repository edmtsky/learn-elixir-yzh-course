#!/usr/bin/env bash
#
# This is the simplest replacement of `mix test` for a simple study projects
# Purpose:
#   - just compile and run all tests
#   - stops at the first failed test and does not go further
#
# Observations:
#   - while running all the tests with one command has not worked out,
#     this method does not work:
#
#     elixir -pa "$BUILD_DIR" $TESTS
#

# same tmp structure used by mix just for compatibility it can be i.g. _build
BUILD_DIR="_build"
SRC_DIR="./"
TEST_DIR="./"

# list of source files *.ex to compile befor testing
LIST=""

# compile
mkdir -p ${BUILD_DIR}
for file in "$SRC_DIR"*.ex; do
  LIST="$LIST $file"
done

echo "# Compile..."
echo elixir $LIST -o $BUILD_DIR
elixirc $LIST -o $BUILD_DIR

echo -e "\n# Testing..."

I="0"
HR="\n================================================================\n"

for testfile in "$TEST_DIR"*_test.exs; do
  echo -e "$HR$testfile"
  elixir -pa "$BUILD_DIR" $testfile
  if [[ $? != 0 ]]; then
    echo "Stopped on Failured test $testfile"
    exit 1;
  fi
  let I="$I+1"
done

if [[ $I -gt 0 ]]; then
  echo "[SUCCESS] All test-files[$I] passed successfully!"
elif [[ $I -eq 0 ]]; then
  echo "[WARNING] No tests found!"
  exit 1
fi
