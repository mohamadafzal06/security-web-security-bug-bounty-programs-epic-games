#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the default output file name
OUTPUT_FILE="all_combined_domains.txt"

# Check if a directory path is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_path>"
  echo "Example: $0 /path/to/my/domain_files"
  exit 1
fi

INPUT_DIR="$1"

# Check if the provided path is a valid directory
if [ ! -d "$INPUT_DIR" ]; then
  echo "Error: Directory '$INPUT_DIR' not found or is not a directory."
  exit 1
fi

echo "Combining domain files from: $INPUT_DIR"
echo "Output will be saved to: $OUTPUT_FILE"
echo "----------------------------------------------------"

# Clear the output file if it already exists, or create it if it doesn't
> "$OUTPUT_FILE"

# Loop through all .txt files in the specified directory
# Using 'find' is more robust for handling filenames with spaces or special characters
find "$INPUT_DIR" -type f -name "*.txt" -print0 | while IFS= read -r -d $'\0' file; do
  echo "Appending content from: $file"
  # Append the content of the current file to the OUTPUT_FILE
  # Using 'cat' is efficient for this purpose
  cat "$file" >> "$OUTPUT_FILE"
done

# After combining all files, sort and unique the final output file
echo "Sorting and removing duplicate domains..."
sort -u -o "$OUTPUT_FILE" "$OUTPUT_FILE"

echo "----------------------------------------------------"
echo "All domain lines combined, sorted, and unique in: $OUTPUT_FILE"
