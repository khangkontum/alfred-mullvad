#!/bin/bash

# Arguments:
# $1 - Country code (required, e.g., "us", "se", "uk")
# $2 - City number (optional, defaults to 1)

if [ -z "$1" ]; then
    echo "Error: Country code required"
    exit 1
fi

country_code="$1"
city_num="${2:-1}"

# Set the relay location to the country code
echo "Setting relay location to $country_code..."
mullvad relay set location "$country_code"

if [ $? -ne 0 ]; then
    echo "Error: Failed to set location to '$country_code'"
    exit 1
fi

# Connect to VPN
echo "Connecting to Mullvad VPN..."
mullvad connect

# Wait a moment for connection to establish
sleep 2

# Get and display connection status
status=$(mullvad status)
echo ""
echo "$status"
