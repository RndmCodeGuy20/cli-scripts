#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 [-n start_line:end_line] <file>"
  echo "  -n start_line:end_line  Specify the range of lines to copy (inclusive)."
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

# The remaining argument should be the filename
if [ -n "$1" ]; then
  file="$1"
else
  echo "Error: No file provided."
  usage
fi

# Check if the file exists
if [ ! -f "$file" ]; then
  echo "File not found: $file"
  exit 1
fi

# If a range is specified, extract the lines; otherwise, copy the whole file
if [ -n "$range" ]; then
  # Convert ':' to ',' for sed range format
  range_sed="${range//:/,}"

  # Extract the lines and copy to clipboard
  sed -n "${range_sed}p" "$file" | pbcopy
else
  # Copy the entire file content to the clipboard
  pbcopy < "$file"
fi
