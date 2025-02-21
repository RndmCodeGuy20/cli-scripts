#!/bin/bash

# Usage:
# ./simulator.sh run [--device <device_type>]
# ./simulator.sh stop [--device <device_type>]
# ./simulator.sh status [--device <device_type>]
# ./simulator.sh list
# ./simulator.sh killall
# ./simulator.sh erase [--device <device_type>]
# ./simulator.sh create <simulator_name> [--device <device_type>] [--runtime <runtime>]
# ./simulator.sh delete <simulator_name>

usage() {
  echo "Usage: $0 {run|stop|status|list|killall|erase|create|delete} [options]"
  echo "  run: Starts the specified simulator (default: iPhone 15 Pro)."
  echo "  stop: Stops the specified simulator (default: iPhone 15 Pro)."
  echo "  status: Shows the status of the specified simulator (default: iPhone 15 Pro)."
  echo "  list: Lists all available simulators."
  echo "  killall: Kills all running simulators."
  echo "  erase: Erases the specified simulator (default: iPhone 15 Pro)."
  echo "  create <simulator_name>: Creates a new simulator."
  echo "  delete <simulator_name>: Deletes a simulator."
  echo "  --device <device_type>: Specify the device type (e.g., iPhone 15 Pro, iPad Pro (12.9-inch) (6th generation))."
  echo "  --runtime <runtime>: Specify the runtime (e.g., com.apple.CoreSimulator.SimRuntime.iOS-17-beta)."
  exit 1
}

simulator_name="iPhone 15 Pro"  # Default simulator name
device_type=""
runtime=""

get_simulator_id() {
  local name="$1"
  local result=$(xcrun simctl list devices | grep "$name")
  if [[ -z "$result" ]]; then
    echo "Simulator '$name' not found."
    return 1
  fi

  IFS=' ' read -r -a split_result <<< "$result"
  local id=${split_result[3]}
  id=${id//[\(\)]/}
  echo "$id"
  return 0
}

run_simulator() {
  local id=$(get_simulator_id "$simulator_name")
  if [[ $? -eq 1 ]]; then return 1; fi
  xcrun simctl boot "$id"
  open -a Simulator
  echo "Simulator '$simulator_name' (ID: $id) is booting."
}

stop_simulator() {
  local id=$(get_simulator_id "$simulator_name")
  if [[ $? -eq 1 ]]; then return 1; fi
  xcrun simctl shutdown "$id"
  echo "Simulator '$simulator_name' (ID: $id) is shutting down."
}

status() {
  local id=$(get_simulator_id "$simulator_name")
  if [[ $? -eq 1 ]]; then return 1; fi
  echo "Simulator '$simulator_name' (ID: $id) Status: $(xcrun simctl get_state "$id")"
}

list_simulators() {
  xcrun simctl list devices
}

killall_simulators() {
  xcrun simctl shutdown_all
  echo "All simulators shut down."
}

erase_simulator() {
  local id=$(get_simulator_id "$simulator_name")
  if [[ $? -eq 1 ]]; then return 1; fi
  xcrun simctl erase "$id"
  echo "Simulator '$simulator_name' (ID: $id) erased."
}

create_simulator() {
  if [[ -z "$2" ]]; then
    echo "Usage: $0 create <simulator_name> [--device <device_type>] [--runtime <runtime>]"
    return 1
  fi
  local new_simulator_name="$2"
  shift 2

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --device)
        device_type="$2"
        shift 2
        ;;
      --runtime)
        runtime="$2"
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done

  local device_arg=""
  local runtime_arg=""
  if [[ -n "$device_type" ]]; then device_arg="--device \"$device_type\""; fi
  if [[ -n "$runtime" ]]; then runtime_arg="--runtime \"$runtime\""; fi

  local id=$(xcrun simctl create "$new_simulator_name" $device_arg $runtime_arg)
  echo "Simulator '$new_simulator_name' (ID: $id) created."
}

delete_simulator() {
  if [[ -z "$2" ]]; then
    echo "Usage: $0 delete <simulator_name>"
    return 1
  fi
  local sim_to_delete="$2"
  local id=$(get_simulator_id "$sim_to_delete")
  if [[ $? -eq 1 ]]; then return 1; fi
  xcrun simctl delete "$id"
  echo "Simulator '$sim_to_delete' (ID: $id) deleted."
}


# Main logic
if [[ "$1" == "run" || "$1" == "stop" || "$1" == "status" || "$1" == "erase" ]]; then
  command="$1"
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --device)
        simulator_name="$2"
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done

  case "$command" in
    run) run_simulator ;;
    stop) stop_simulator ;;
    status) status ;;
    erase) erase_simulator ;;
  esac

elif [[ "$1" == "list" ]]; then
  list_simulators
elif [[ "$1" == "killall" ]]; then
  killall_simulators
elif [[ "$1" == "create" ]]; then
  create_simulator "$@"
elif [[ "$1" == "delete" ]]; then
  delete_simulator "$@"
else
  usage
fi