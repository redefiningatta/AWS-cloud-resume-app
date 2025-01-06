#!/bin/bash

source ./scripts/common.sh

# Set LAMBDA_ZIP with a specific name
LAMBDA_ZIP="visitor_counter_$(date +%Y%m%d%H%M%S).zip"

log "Lambda zip file will be: $LAMBDA_ZIP"

# Check if (Zip) is installed
if ! command -v zip &> /dev/null; then
    log "zip command not found. Please install Zip utility."
    exit 1
fi

# Zip Lambda function code
log "Zipping Lambda function..."
cd ../lambda || handle_error $LINENO
if [ ! -f "visitor_counter.py" ]; then
    log "Error: visitor_counter.py not found in lambda directory."
    exit 1
fi
zip -r "$LAMBDA_ZIP" visitor_counter.py || handle_error $LINENO
log "Zip file created: $(ls -l "$LAMBDA_ZIP")"
cd .. || handle_error $LINENO

# Create Lambda bucket if it doesn't already exist
if ! aws s3api head-bucket --bucket "$LAMBDA_CODE_BUCKET" 2>/dev/null; then
    log "Creating Lambda code S3 bucket..."
    aws s3api create-bucket --bucket "$LAMBDA_CODE_BUCKET" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION" || handle_error $LINENO
else
    log "Bucket $LAMBDA_CODE_BUCKET already exists."
fi

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
