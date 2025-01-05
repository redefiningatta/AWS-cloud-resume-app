#!/bin/bash

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Error handling function
handle_error() {
    log "Error occurred at line: ${1}. Command: '${BASH_COMMAND}' failed."
    exit 1
}
trap 'handle_error $LINENO' ERR

# Derived variables
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
LAMBDA_CODE_BUCKET="${AWS_ACCOUNT_ID}-lambda-code-bucket-gh"
