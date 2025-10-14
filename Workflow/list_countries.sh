#!/bin/bash

query="$1"

# Get relay list from mullvad
relay_output=$(mullvad relay list 2>&1)

if [ $? -ne 0 ]; then
    cat <<EOF
{
  "items": [
    {
      "title": "Error: Could not get relay list",
      "subtitle": "Make sure Mullvad is installed and you're logged in",
      "valid": false
    }
  ]
}
EOF
    exit 0
fi

# Parse countries from relay list
# Format: "Country Name (code)"
countries=$(echo "$relay_output" | grep -E "^[A-Z].*\([a-z]{2}\)" | sed -E 's/^(.+) \(([a-z]{2})\)$/\2|\1/')

# Filter by query if provided
if [ -n "$query" ]; then
    countries=$(echo "$countries" | grep -i "$query")
fi

# Build JSON output
echo '{"items":['

first=true
while IFS='|' read -r code name; do
    [ -z "$code" ] && continue

    if [ "$first" = true ]; then
        first=false
    else
        echo ","
    fi

    cat <<EOF
    {
      "title": "$name",
      "subtitle": "Connect to $name (code: $code)",
      "arg": "$code",
      "autocomplete": "$name",
      "icon": {
        "path": "icon.png"
      }
    }
EOF
done <<< "$countries"

if [ "$first" = true ]; then
    cat <<EOF
    {
      "title": "No countries found",
      "subtitle": "Try a different search term",
      "valid": false
    }
EOF
fi

echo ']}'
