#!/bin/bash

# Check current Mullvad status
status=$(mullvad status)

if echo "$status" | grep -q "Connected"; then
    # Currently connected, so disconnect
    mullvad disconnect
    echo "Disconnected from Mullvad VPN"
else
    # Currently disconnected, so connect
    mullvad connect
    echo "Connected to Mullvad VPN"
fi
