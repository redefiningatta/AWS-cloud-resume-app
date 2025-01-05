#!/bin/bash

source ./scripts/common.sh

# Build Phase: Zip Lambda function
log "Building Lambda package..."
cd lambda || handle_error $LINENO
zip -r $LAMBDA_ZIP visitor_counter.py
cd .. || handle_error $LINENO

# Create S3 bucket if not exists
if ! aws s3api head-bucket --bucket $LAMBDA_CODE_BUCKET 2>/dev/null; then
    log "Creating S3 bucket: $LAMBDA_CODE_BUCKET"
    aws s3api create-bucket \
        --bucket $LAMBDA_CODE_BUCKET \
        --region $AWS_REGION \
        --create-bucket-configuration LocationConstraint=$AWS_REGION
else
    log "Bucket $LAMBDA_CODE_BUCKET already exists."
fi

# Upload Lambda function to S3
log "Uploading Lambda package to S3..."
aws s3 cp lambda/$LAMBDA_ZIP s3://$LAMBDA_CODE_BUCKET/

# Test Phase: Validate Lambda Package Upload
log "Validating Lambda package in S3..."
if ! aws s3 ls s3://$LAMBDA_CODE_BUCKET/$LAMBDA_ZIP > /dev/null; then
    log "Lambda package upload validation failed."
    exit 1
fi
log "Lambda package upload validated."
