#!/bin/bash

# Set default values for the input and output files
input_file=""
output_file="/dev/null"

# Parse the options
while getopts "l:o:" opt; do
  case "$opt" in
    l) input_file="$OPTARG"
       ;;
    o) output_file="$OPTARG"
       ;;
    :) echo "$(tput setaf 1)🚫 Option -$OPTARG requires an argument.$(tput sgr0)" >&2
       exit 1
       ;;
    \?) echo "$(tput setaf 1)🚫 Invalid option -$OPTARG$(tput sgr0)" >&2
       exit 1
       ;;
  esac
done

# Check if an input file was specified
if [ -z "$input_file" ]; then
  echo "$(tput setaf 1)🚫 No input file specified. Please use the -l option to specify an input file.$(tput sgr0)"
  exit 1
fi

# Check if the input file exists and is readable
if [ ! -f "$input_file" ] || [ ! -r "$input_file" ]; then
  echo "$(tput setaf 1)🚫 The input file does not exist or is not readable.$(tput sgr0)"
  exit 1
fi

# Create the output file if it does not exist
if [ ! -f "$output_file" ]; then
  touch "$output_file"
fi

# Check if the output file is writable
if [ ! -w "$output_file" ]; then
  echo "$(tput setaf 1)🚫 The output file is not writable.$(tput sgr0)"
  exit 1
fi

# Extract the URLs from the input file and save them to the output file
grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" "$input_file" > "$output_file"

# Print the extracted URLs with colors and emojis
while read -r url; do
  printf "🔗 %s\n" "$(tput setaf 6)$url$(tput sgr0)"
done < <(grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" "$input_file")
