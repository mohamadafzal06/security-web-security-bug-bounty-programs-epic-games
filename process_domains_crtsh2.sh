#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if an input file containing the list of domains is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <list_of_domains_file>"
  echo "Example: $0 my_domains.txt"
  exit 1
fi

DOMAINS_FILE="$1"

# Read the domains file line by line
while IFS= read -r domain; do
  # Skip empty lines
  if [ -z "$domain" ]; then
    continue
  fi

  echo "Processing domain: $domain"

  # Define file names
  OUTPUT_FILE="${domain}.txt"
  TEMP_FILE=$(mktemp) # Create a temporary file with a unique name

  # Use trap to ensure the temporary file is deleted even if the script exits unexpectedly
  trap "rm -f \"$TEMP_FILE\"" EXIT

  # Step 1 & 2: Fetch certificate info and extract domain-like strings.
  curl -s "https://crt.sh/?q=$domain" | grep -oE '[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' > "$OUTPUT_FILE"

  # Step 3: Sort and unique the OUTPUT_FILE in place.
  sort -u -o "$OUTPUT_FILE" "$OUTPUT_FILE"

  # Step 4: Filter the OUTPUT_FILE and save to the temporary file.
  # Using -F for fixed string search is safer for domain names.
  ESCAPED_DOMAIN=$(echo "$domain" | sed 's/\./\\./g')
  grep "${ESCAPED_DOMAIN}$" "$OUTPUT_FILE" > "$TEMP_FILE"
  # Replace the original file with the temporary one.
  mv "$TEMP_FILE" "$OUTPUT_FILE"

  echo "Finished processing $domain. Results in $OUTPUT_FILE"
  echo "----------------------------------------------------"

  # Remove the trap for this iteration to prevent deleting the newly moved file
  trap - EXIT

done < "$DOMAINS_FILE"

echo "All domains processed."
