#!/bin/bash

# Function to log messages with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to handle errors with line number
handle_error() {
    log "Error on line $1. Exiting."
    exit 1
}

# Ensure required tools are installed
if ! command -v zip &> /dev/null; then
    log "zip command not found. Please install Zip utility."
    exit 1
fi

# Define Lambda directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")
LAMBDA_DIR="$SCRIPT_DIR/../lambda"

# Validate Lambda directory
if [[ ! -d "$LAMBDA_DIR" ]]; then
    log "Lambda directory does not exist. Exiting."
    exit 1
fi

# Get current timestamp for versioning (or use Git commit hash)
TIMESTAMP=$(date '+%Y%m%d%H%M%S')
GIT_COMMIT_HASH=$(git rev-parse --short HEAD)
LAMBDA_ZIP="visitor_counter_${TIMESTAMP}_${GIT_COMMIT_HASH}.zip"

# Build Lambda Package
log "Building Lambda package: $LAMBDA_ZIP..."
cd "$LAMBDA_DIR" || handle_error $LINENO
if [[ ! -f "visitor_counter.py" ]]; then
    log "visitor_counter.py not found in Lambda directory."
    exit 1
fi
zip -r "$LAMBDA_ZIP" visitor_counter.py || handle_error $LINENO
cd - || handle_error $LINENO

# Ensure S3 bucket exists
log "Checking S3 bucket: $LAMBDA_CODE_BUCKET"
if ! aws s3api head-bucket --bucket "$LAMBDA_CODE_BUCKET" 2>/dev/null; then
    log "Creating S3 bucket: $LAMBDA_CODE_BUCKET"
    aws s3api create-bucket \
        --bucket "$LAMBDA_CODE_BUCKET" \
        --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION" || handle_error $LINENO
else
    log "Bucket $LAMBDA_CODE_BUCKET already exists."
fi

# Upload Lambda package to S3
log "Uploading Lambda package to S3..."
aws s3 cp "$LAMBDA_ZIP" "s3://$LAMBDA_CODE_BUCKET/" || handle_error $LINENO

# Validate upload
log "Validating Lambda package in S3..."
if ! aws s3 ls "s3://$LAMBDA_CODE_BUCKET/$LAMBDA_ZIP" > /dev/null; then
    log "Lambda package upload validation failed."
    exit 1
fi
log "Lambda package upload validated successfully."
