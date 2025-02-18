#!/bin/bash

# usage
# ./simulator.sh run
# ./simulator.sh stop

usage() {
  echo "Usage: $0 {run|stop}"
  exit 1
}

function run_simulator() {
  result=$(xcrun simctl list devices | grep "iPhone 15 Pro")

  IFS=' ' read -r -a split_result <<< "$result"

  simulator_id=${split_result[3]}
  simulator_id=${simulator_id//[\(\)]/}

  xcrun simctl boot "$simulator_id"
  open -a Simulator

  echo "Simulator ID: $simulator_id is booting."
}

function stop_simulator() {
  result=$(xcrun simctl list devices | grep "iPhone 15 Pro")

  IFS=' ' read -r -a split_result <<< "$result"

  simulator_id=${split_result[3]}
  simulator_id=${simulator_id//[\(\)]/}

  xcrun simctl shutdown "$simulator_id"

  echo "Simulator ID: $simulator_id is shutting down."
}

function status() {
  result=$(xcrun simctl list devices | grep "iPhone 15 Pro")

  IFS=' ' read -r -a split_result <<< "$result"

  simulator_id=${split_result[3]}
  simulator_id=${simulator_id//[\(\)]/}

  echo "Simulator ID: $simulator_id"
}

if [ "$1" == "run" ]; then
  run_simulator
elif [ "$1" == "stop" ]; then
  stop_simulator
elif [ "$1" == "status" ]; then
  status
else
  echo "Usage: $0 {run|stop|status}"
fi
