#!/usr/bin/bash

VCLUSTER_NAME=$1
CF_ZONE_ID=$2
CF_API_TOKEN=$3
TARGET_DOMAIN=$4

# The domain and the target CNAME record
DOMAIN="$VCLUSTER_NAME.tekanaid.com"

# Cloudflare API URL
CF_API_URL="https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records"

# Make the API call to create the CNAME record
response=$(curl -s -X POST "$CF_API_URL" \
     -H "Authorization: Bearer $CF_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"CNAME\",\"name\":\"$DOMAIN\",\"content\":\"$TARGET_DOMAIN\",\"ttl\":1,\"proxied\":false}")

# Check if the API call was successful
echo $response | grep -q "\"success\":true"
if [ $? -eq 0 ]; then
    echo "CNAME record created successfully."
else
    echo "Failed to create CNAME record."
    echo "Response: $response"
fi
