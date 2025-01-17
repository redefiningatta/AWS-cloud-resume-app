#!/bin/bash

source ./scripts/common.sh

# Check for required tools
log "Checking for required tools..."
for cmd in aws zip; do
    if ! command -v $cmd &> /dev/null; then
        log "$cmd command not found. Please install $cmd."
        exit 1
    fi
done

# Set LAMBDA_ZIP with a specific name
LAMBDA_ZIP="visitor_counter.zip"

log "Lambda zip file will be: $LAMBDA_ZIP"

# Check if (Zip) is installed
if ! command -v zip &> /dev/null; then
    log "zip command not found. Please install Zip utility."
    exit 1
fi

# Zip Lambda function code
log "Zipping Lambda function..."
cd lambda || handle_error $LINENO
if [ ! -f "visitor_counter.py" ]; then
    log "Error: visitor_counter.py not found in lambda directory."
    exit 1
fi
zip -r "$LAMBDA_ZIP" visitor_counter.py || handle_error $LINENO
log "Zip file created: $(ls -l "$LAMBDA_ZIP")"
cd .. || handle_error $LINENO

# Create Lambda bucket if it doesn't already exist
MAX_RETRIES=3
RETRY_DELAY=5
for ((i=1; i<=MAX_RETRIES; i++)); do
    if ! aws s3api head-bucket --bucket "$LAMBDA_CODE_BUCKET" 2>/dev/null; then
        log "Creating Lambda code S3 bucket (attempt $i)..."
        if aws s3api create-bucket --bucket "$LAMBDA_CODE_BUCKET" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"; then
            log "Bucket created successfully."
            break
        elif [[ $i -eq $MAX_RETRIES ]]; then
            log "Failed to create S3 bucket after $MAX_RETRIES attempts. Exiting."
            exit 1
        else
            log "Bucket creation failed due to contention. Retrying in $RETRY_DELAY seconds..."
            sleep $RETRY_DELAY
        fi
    else
        log "Bucket $LAMBDA_CODE_BUCKET already exists."
        break
    fi
done

# Upload Lambda function to S3
log "Uploading Lambda function to S3..."
if [ -f "lambda/$LAMBDA_ZIP" ]; then
    aws s3 cp "lambda/$LAMBDA_ZIP" "s3://$LAMBDA_CODE_BUCKET/" || handle_error $LINENO
    log "Lambda function uploaded successfully."
else
    log "Error: Lambda zip file not found at lambda/$LAMBDA_ZIP"
    exit 1
fi

# Verify upload
log "Verifying upload..."
if aws s3 ls "s3://$LAMBDA_CODE_BUCKET/$LAMBDA_ZIP" &> /dev/null; then
    log "Upload verified successfully."
else
    log "Error: Upload verification failed."
    exit 1
fi

# After successful upload and verification
log "Cleaning up local zip file..."
rm "lambda/$LAMBDA_ZIP" || log "Warning: Failed to remove local zip file"

log "Lambda function deployment completed successfully."
