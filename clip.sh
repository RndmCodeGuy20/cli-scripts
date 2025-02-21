#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 [-n start_line:end_line] [<file>]"
  echo "  -n start_line:end_line  Specify the range of lines to copy (inclusive)."
  echo "  If no file is provided, input is read from stdin (for piped commands)."
  exit 1
}

# Initialize variables
range=""
file=""

# Parse options using getopts
while getopts "n:" opt; do
  case $opt in
    n)
      range="$OPTARG"
      ;;
    *)
      usage
      ;;
  esac
done

# Shift past the processed options
shift $((OPTIND - 1))

# Check if a file argument is provided
if [ -n "$1" ]; then
  file="$1"

  # Check if the file exists
  if [ ! -f "$file" ]; then
    echo "File not found: $file"
    exit 1
  fi

  # Determine input source (file or stdin)
  input_source="$file"
else
  # No file provided, so assume stdin
  input_source="/dev/stdin"
fi


# If a range is specified, extract the lines; otherwise, copy the whole content
if [ -n "$range" ]; then
  # Convert ':' to ',' for sed range format
  range_sed="${range//:/,}"

  # Extract the lines and copy to clipboard.  Handle both file and stdin.
  if [[ "$input_source" == "/dev/stdin" ]]; then
      sed -n "${range_sed}p"  | pbcopy
  else
      sed -n "${range_sed}p" "$input_source" | pbcopy
  fi

else
  # Copy the entire content to the clipboard. Handle both file and stdin.
    if [[ "$input_source" == "/dev/stdin" ]]; then
        pbcopy
    else
        pbcopy < "$input_source"
    fi
fi