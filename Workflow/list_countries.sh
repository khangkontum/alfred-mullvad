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

# Parse countries and cities with awk
locations=$(echo "$relay_output" | awk '
    /^[A-Z].*\([a-z]{2}\)$/ {
        # Extract country info
        line = $0
        gsub(/ \([a-z]{2}\)$/, "", line)
        country_name = line

        # Get country code from last 3 chars before )
        n = length($0)
        country_code = substr($0, n-2, 2)

        print "country|" country_code "|" country_name "||" country_name
    }
    /^\t[^\t].*\([a-z]{3}\) @/ {
        # Extract city info
        line = $0
        sub(/^\t/, "", line)
        sub(/ @.*$/, "", line)

        # Get city code (3 chars before closing paren)
        n = length(line)
        city_code = substr(line, n-3, 3)

        # Get city name
        sub(/ \([a-z]{3}\)$/, "", line)
        city_name = line

        print "city|" country_code "|" city_code "|" city_name "|" country_name
    }
')

# Filter by query if provided
if [ -n "$query" ]; then
    locations=$(echo "$locations" | grep -i "$query")
fi

# Build JSON output using jq for speed
items=$(echo "$locations" | while IFS='|' read -r type country_code city_code name parent_country; do
    [ -z "$type" ] && continue

    if [ "$type" = "country" ]; then
        printf '%s\n' "{\"title\":\"$city_code\",\"subtitle\":\"Country · Connect to $city_code ($country_code)\",\"arg\":\"$country_code\",\"autocomplete\":\"$city_code\",\"icon\":{\"path\":\"icon.png\"}}"
    else
        printf '%s\n' "{\"title\":\"$name\",\"subtitle\":\"City in $parent_country · Connect to $name ($city_code)\",\"arg\":\"$country_code $city_code\",\"autocomplete\":\"$name\",\"icon\":{\"path\":\"icon.png\"}}"
    fi
done | paste -sd ',' -)

if [ -z "$items" ]; then
    echo '{"items":[{"title":"No locations found","subtitle":"Try a different search term","valid":false}]}'
else
    echo "{\"items\":[$items]}"
fi
