#!/bin/bash

# Arguments:
# $1 - Location code (e.g., "us" for country, "us nyc" for city)

if [ -z "$1" ]; then
    echo "Error: Location code required"
    exit 1
fi

location="$1"

# Set the relay location (handles both "us" and "us nyc" formats)
echo "Setting relay location to $location..."
mullvad relay set location $location

if [ $? -ne 0 ]; then
    echo "Error: Failed to set location to '$location'"
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
