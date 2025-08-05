#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if a domain argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <domain_name>"
  echo "Example: $0 example.com"
  exit 1
fi

domain="$1" # Assign the first command-line argument directly to the domain variable

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
# We escape the dots in the domain to ensure they are treated literally by grep's regex.
ESCAPED_DOMAIN=$(echo "$domain" | sed 's/\./\\./g')
grep "${ESCAPED_DOMAIN}$" "$OUTPUT_FILE" > "$TEMP_FILE"

# Replace the original file with the temporary one.
mv "$TEMP_FILE" "$OUTPUT_FILE"

echo "Finished processing $domain. Results in $OUTPUT_FILE"
echo "----------------------------------------------------"

# Remove the trap as the script is about to exit cleanly for a single domain
trap - EXIT

echo "Domain processing complete."
