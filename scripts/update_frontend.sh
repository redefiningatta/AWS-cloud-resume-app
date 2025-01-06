#!/bin/bash

source ./scripts/common.sh

# Fetch Frontend Bucket Name
log "Fetching Frontend S3 bucket name..."
FRONTEND_BUCKET_NAME=$(aws cloudformation describe-stack-resources \
  --stack-name cloud-resume-frontend \
  --query "StackResources[?LogicalResourceId=='S3BucketFrontend'].PhysicalResourceId" \
  --output text)

if [ -z "$FRONTEND_BUCKET_NAME" ]; then
    log "Failed to fetch Frontend S3 bucket name. Exiting."
    exit 1
fi

# Fetch API Gateway URL
log "Fetching API Gateway URL..."
API_URL=$(aws cloudformation describe-stacks \
  --stack-name cloud-resume-backend \
  --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" \
  --output text)

if [ -z "$API_URL" ]; then
    log "Failed to fetch API Gateway URL. Exiting."
    exit 1
fi
log "API Gateway URL: $API_URL"

# Update JavaScript file with API URL
JS_FILE="assets/js/main.js" 
log "Updating JavaScript file with API URL..."
if [ -f "$JS_FILE" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|{{API_URL}}|$API_URL|" "$JS_FILE"
    else
        sed -i.bak "s|{{API_URL}}|$API_URL|" "$JS_FILE"
    fi
    log "Updated $JS_FILE with API URL."
else
    log "JavaScript file $JS_FILE not found. Skipping."
fi

# Function to upload files to S3
upload_static_files() {
    local source_dir=$1
    local dest_path=$2

    if [[ ! -d "$source_dir" || -z "$(ls -A "$source_dir")" ]]; then
        log "Directory $source_dir is empty or does not exist. Skipping."
        return 1
    fi

    log "Uploading $source_dir to s3://$FRONTEND_BUCKET_NAME/$dest_path..."
    aws s3 sync "$source_dir" "s3://$FRONTEND_BUCKET_NAME/$dest_path" --delete --exact-timestamps
}

# Upload CSS files
log "Uploading CSS files..."
upload_static_files "assets/css" "css"

# Upload Images
log "Uploading images..."
upload_static_files "assets/images/icons" "images/icons"
upload_static_files "assets/images/photoswipe" "images/photoswipe"
upload_static_files "assets/images/portfolio" "images/portfolio"
upload_static_files "assets/images" "images"

# Upload JS files
log "Uploading JavaScript files..."
upload_static_files "assets/js" "js"

# Upload other static assets
log "Uploading other static assets..."
upload_static_files "assets" ""

# Final log
log "Static asset upload complete!"
