#!/bin/bash

# Ensure required packages are installed
sudo apt-get update
sudo apt-get install -y curl jq

# Load DiCentral and TrueCommerce configurations
DICENTRAL_CONFIG_FILE="configs/dicentral_config.json"
TRUECOMMERCE_CONFIG_FILE="configs/truecommerce_config.json"

if [ ! -f "$DICENTRAL_CONFIG_FILE" ] || [ ! -f "$TRUECOMMERCE_CONFIG_FILE" ]; then
  echo "Configuration files not found!"
  exit 1
fi

DICENTRAL_API_URL=$(jq -r '.dicentral.api_url' "$DICENTRAL_CONFIG_FILE")
DICENTRAL_API_KEY=$(jq -r '.dicentral.api_key' "$DICENTRAL_CONFIG_FILE")
TRUECOMMERCE_API_URL=$(jq -r '.truecommerce.api_url' "$TRUECOMMERCE_CONFIG_FILE")
TRUECOMMERCE_API_KEY=$(jq -r '.truecommerce.api_key' "$TRUECOMMERCE_CONFIG_FILE")

# Function to migrate data from DiCentral to TrueCommerce
migrate_data() {
  echo "Fetching data from DiCentral..."
  dicentral_data=$(curl -s -X GET -H "Authorization: Bearer $DICENTRAL_API_KEY" "$DICENTRAL_API_URL/data")

  echo "Migrating data to TrueCommerce..."
  curl -s -X POST -H "Authorization: Bearer $TRUECOMMERCE_API_KEY" -H "Content-Type: application/json" -d "$dicentral_data" "$TRUECOMMERCE_API_URL/data"

  echo "Migration completed successfully!"
}

# Call the function to start migration
migrate_data
