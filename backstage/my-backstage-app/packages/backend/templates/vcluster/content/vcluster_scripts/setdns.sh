#!/usr/bin/bash

VCLUSTER_NAME=$1
CF_ZONE_ID=$2
CF_API_TOKEN=$3
TARGET_DOMAIN=$4
HOSTCLUSTERTYPE=$5

# The domain
DOMAIN="$VCLUSTER_NAME.tekanaid.com"

# Cloudflare API URL
CF_API_URL="https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records"

# Function to create DNS record
create_dns_record() {
    local type=$1
    local name=$2
    local content=$3
    local ttl=$4
    local proxied=$5

    response=$(curl -s -X POST "$CF_API_URL" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$type\",\"name\":\"$name\",\"content\":\"$content\",\"ttl\":$ttl,\"proxied\":$proxied}")

    echo $response | grep -q "\"success\":true"
    if [ $? -eq 0 ]; then
        echo "$type record created successfully for $name."
    else
        echo "Failed to create $type record for $name."
        echo "Response: $response"
    fi
}

# Choose DNS record type based on cluster type
case $HOSTCLUSTERTYPE in
    eks)
        create_dns_record "CNAME" "$DOMAIN" "$TARGET_DOMAIN" 1 false
        ;;
    gke)
        create_dns_record "A" "$DOMAIN" "$TARGET_DOMAIN" 1 false
        ;;
    aks)
        # Placeholder for AKS, adjust as needed
        echo "AKS configuration not implemented yet."
        ;;
    *)
        echo "Unsupported HOSTCLUSTERTYPE: $HOSTCLUSTERTYPE"
        ;;
esac
