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
# IFS= prevents leading/trailing whitespace trimming
# -r prevents backslash escapes from being interpreted
while IFS= read -r domain; do
  # Skip empty lines in the input file
  if [ -z "$domain" ]; then
    continue
  fi

  echo "Processing domain: $domain"

  # Define the output file name for the current domain
  # This will be <domain_name>.txt (e.g., example.com.txt)
  OUTPUT_FILE="${domain}.txt"
  TEMP_FILE="${domain}_temp.txt" # Temporary file for safe overwriting

  # Step 1 & 2: Fetch certificate information from crt.sh and extract domain-like strings.
  # The output is redirected to the OUTPUT_FILE, overwriting it for each new domain.
  # -s: silent mode (suppresses progress meters and error messages from curl)
  # -oE: only print the matching part (o), using extended regular expressions (E)
  # The regex '[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' is used as per your request.
  curl -s "https://crt.sh/?q=$domain" | grep -oE '[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' > "$OUTPUT_FILE"

  # Step 3: Sort and unique the OUTPUT_FILE in place.
  # -u: unique lines (removes duplicates)
  # -o: output to the specified file (allows in-place sorting)
  sort -u -o "$OUTPUT_FILE" "$OUTPUT_FILE"

  # Step 4: Filter the OUTPUT_FILE to keep only lines ending with the current domain.
  # The filtered content is written to a temporary file, then moved to overwrite the original.
  # -F: interpret the pattern as a fixed string (not a regular expression), which is safer for domain names.
  # $: matches the end of the line, ensuring only exact matches at the end are kept.
  grep -F "${domain}$" "$OUTPUT_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$OUTPUT_FILE"

  echo "Finished processing $domain. Results in $OUTPUT_FILE"
  echo "----------------------------------------------------"

done < "$DOMAINS_FILE"

echo "All domains processed."
