#!/bin/bash

# Function to check and update DHCP
check_and_update() {
    # Load environment variables
    : "${DEVICE:?DEVICE is not set}"
    : "${AUTH_TOKEN:?AUTH_TOKEN is not set}"

    # Define the API URL and headers
    API_URL="https://api.clg.nos.pt/nosnet/router-manager-api/api/v3/device/$DEVICE/settings/dhcps?interfaceName=Lan1"
    AUTH_HEADER="Authorization: Bearer $AUTH_TOKEN"

    # Perform the GET request and parse the JSON response
    response=$(curl --location --silent --header "$AUTH_HEADER" "$API_URL")

    # Extract the "Enabled" field from the JSON response
    enabled=$(echo "$response" | jq -r '.[0].Enabled')

    # Check if the "Enabled" field is false
    if [ "$enabled" = "true" ]; then
        echo "DHCP is enabled. Disabling it now..."

        # Define the PUT request URL and data
        PUT_URL="https://api.clg.nos.pt/nosnet/router-manager-api/api/v3/device/$DEVICE/settings/dhcps?poolId=1%0A"
        PUT_DATA='{"Enabled":false,"Pool":"1","PoolStart":"192.168.1.2","PoolEnd":"192.168.1.100","Netmask":"255.255.254.0","Gateway":"192.168.1.1","LeaseTime":120,"PrimDns":"192.168.1.1"}'

        # Perform the PUT request
        curl --location --request PUT "$PUT_URL" \
            --header "Content-Type: application/json" \
            --header "$AUTH_HEADER" \
            --data "$PUT_DATA" \
            -s -o /dev/null 
    elif [ "$enabled" = "false" ]; then
        echo "DHCP is already disabled."
    else
        echo "Unexpected Error "
        exit 1
    fi
}

# Load the REFRESH variable with a default of 10 minutes
REFRESH="${REFRESH:-600}"

# Infinite loop with a delay
while true; do
    check_and_update
    sleep "$REFRESH"
done



