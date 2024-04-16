#!/usr/bin/bash

VCLUSTER_NAME=$1
CF_ZONE_ID=$2
CF_API_TOKEN=$3

# The domain of the CNAME record
DOMAIN="$VCLUSTER_NAME.tekanaid.com"

# Cloudflare API URL to list DNS records
CF_API_LIST_URL="https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?type=CNAME&name=$DOMAIN"

# Cloudflare API URL to delete DNS records
CF_API_DELETE_URL="https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records"

# Get the DNS record ID
record_id=$(curl -s -X GET "$CF_API_LIST_URL" \
     -H "Authorization: Bearer $CF_API_TOKEN" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')

# Check if the record ID was found
if [ "$record_id" != "null" ] && [ ! -z "$record_id" ]; then
    # Make the API call to delete the DNS record
    delete_response=$(curl -s -X DELETE "$CF_API_DELETE_URL/$record_id" \
         -H "Authorization: Bearer $CF_API_TOKEN" \
         -H "Content-Type: application/json")

    # Check if the API call was successful
    echo $delete_response | grep -q "\"success\":true"
    if [ $? -eq 0 ]; then
        echo "CNAME record deleted successfully."
    else
        echo "Failed to delete CNAME record."
        echo "Response: $delete_response"
    fi
else
    echo "DNS record not found or could not retrieve record ID."
fi
