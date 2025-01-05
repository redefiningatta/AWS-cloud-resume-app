#!/bin/bash

source ./scripts/common.sh

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

# Check if LAMBDA_ZIP is passed as an environment variable
if [[ -z "$LAMBDA_ZIP" ]]; then
    TIMESTAMP=$(date '+%Y%m%d%H%M%S')
    GIT_COMMIT_HASH=$(git rev-parse --short HEAD)
    LAMBDA_ZIP="visitor_counter_${TIMESTAMP}_${GIT_COMMIT_HASH}.zip"
fi

# Log the intended Lambda zip filename
log "Building Lambda package: $LAMBDA_ZIP..."

# Change to the Lambda directory
cd "$LAMBDA_DIR" || handle_error $LINENO

# Check for the visitor_counter.py file
if [[ ! -f "visitor_counter.py" ]]; then
    log "visitor_counter.py not found in Lambda directory."
    exit 1
fi
log "Found visitor_counter.py, proceeding with zip."

# Check if the zip file already exists
if [[ -f "$LAMBDA_ZIP" ]]; then
    log "Lambda zip file already exists, removing old zip file: $LAMBDA_ZIP"
    rm "$LAMBDA_ZIP" || handle_error $LINENO
fi

# Create the zip package
log "Starting zip creation..."
zip -r "$LAMBDA_ZIP" visitor_counter.py -v || handle_error $LINENO

# Ensure that the zip file was created
if [[ ! -f "$LAMBDA_ZIP" ]]; then
    log "Lambda package $LAMBDA_ZIP not created successfully."
    exit 1
fi

# Change back to the previous directory
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
log "Uploading Lambda package: $LAMBDA_ZIP to S3..."
aws s3 cp "$LAMBDA_ZIP" "s3://$LAMBDA_CODE_BUCKET/" || handle_error $LINENO

# Validate upload
log "Validating Lambda package in S3..."
if ! aws s3 ls "s3://$LAMBDA_CODE_BUCKET/$LAMBDA_ZIP" > /dev/null; then
    log "Lambda package upload validation failed."
    exit 1
fi
log "Lambda package upload validated successfully."
