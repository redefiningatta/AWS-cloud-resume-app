#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function for error handling
handle_error() {
    log "Error occurred in script at line: ${1}."
    log "Exiting..."
    exit 1
}

# Set up error handling
trap 'handle_error $LINENO' ERR

# Define variables
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
LAMBDA_CODE_BUCKET="${AWS_ACCOUNT_ID}-lambda-code-bucket"
LAMBDA_ZIP="visitor_counter.zip"
AWS_REGION="eu-west-2"
CERTIFICATE_REGION="us-east-1"  # ACM certificates for CloudFront must be in us-east-1
DOMAIN_NAME="resume.iamatta.com"

# Check if 7z (7-Zip) is installed
if ! command -v 7z &> /dev/null; then
    log "7z command not found. Please install 7-Zip utility."
    exit 1
fi

# Zip Lambda function code
log "Zipping Lambda function..."
cd lambda || handle_error $LINENO
7z a -tzip $LAMBDA_ZIP visitor_counter.py
cd .. || handle_error $LINENO

# Create Lambda bucket if it doesn't already exist
if ! aws s3api head-bucket --bucket $LAMBDA_CODE_BUCKET 2>/dev/null; then
    log "Creating Lambda code S3 bucket..."
    aws s3api create-bucket --bucket $LAMBDA_CODE_BUCKET --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
else
    log "Bucket $LAMBDA_CODE_BUCKET already exists."
fi

# Upload Lambda function to S3
log "Uploading Lambda function to S3..."
aws s3 cp backend/lambda/$LAMBDA_ZIP s3://$LAMBDA_CODE_BUCKET/


# Deploy CloudFormation stacks
log "Deploying CloudFormation stacks..."

log "Deploying ACM Certificate..."
aws cloudformation deploy \ 
  --template-file cloudformation/certificates/acm-certificate.yml \
  --stack-name Acm-certificate \
  --region $CERTIFICATE_REGION \
  


log "Waiting for certificate validation..."

CERTIFICATE_ARN=$(aws cloudformation describe-stacks --stack-name $CERTIFICATE_STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='CertificateArn'].OutputValue" --output text)

aws acm wait certificate-validated --certificate-arn $CERTIFICATE_ARN --region $CERTIFICATE_REGION

log "Certificate successfully created and validated: $CERTIFICATE_ARN"

# Deploy backend resources (Lambda, API Gateway, DynamoDB)
log "Deploying backend stack..."
aws cloudformation deploy \
  --template-file backend/cloudformation/backend.yml \
  --stack-name cloud-resume-backend \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides LambdaCodeBucket=$LAMBDA_CODE_BUCKET

# Deploy frontend resources (S3, CloudFront)
log "Deploying frontend stack..."
aws cloudformation deploy \
  --template-file frontend/cloudformation/frontend.yml \
  --stack-name cloud-resume-frontend \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides DomainName=$DOMAIN_NAME CertificateArn=$CERTIFICATE_ARN

FRONTEND_BUCKET_NAME="$(aws cloudformation describe-stack-resources --stack-name cloud-resume-frontend --query "StackResources[?LogicalResourceId=='S3BucketFrontend'].PhysicalResourceId" --output text)"

# Get API Gateway URL
API_URL=$(aws cloudformation describe-stacks --stack-name cloud-resume-backend --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" --output text)

log "API Gateway URL: $API_URL"

log "Testing API endpoint..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $API_URL)

if [ $RESPONSE -eq 200 ]; then
    log "API test successful!"
else
    log "API test failed with status code: $RESPONSE"
    log "Check Lambda function logs for more details."
fi

# Function to update JavaScript file with API URL
update_js_file() {
    local js_file=$1
    local api_url=$2

    if [ -f "$js_file" ]; then
        log "Updating $js_file with API URL: $api_url"
        sed -i "s|{{API_URL}}|$api_url|" "$js_file"
    else
        log "File $js_file does not exist. Skipping update."
    fi
}

# Update JavaScript file with API URL
JS_FILE="./frontend/static/visitor-counter.js"  # Change this to your actual JavaScript file path
update_js_file "$JS_FILE" "$API_URL"

# Function to upload static files to S3
upload_static_files() {
    local static_dir=$1
    if [[ -d "$static_dir" ]]; then
        log "Uploading static files from $static_dir to S3 bucket $FRONTEND_BUCKET_NAME..."
        aws s3 sync "$static_dir" "s3://$FRONTEND_BUCKET_NAME" --delete #--acl public-read
    else
        log "Directory $static_dir does not exist. Skipping static file upload."
    fi
}

# Check if the static files directory exists and upload files
STATIC_FILES_DIR="./frontend/static"  # Change this to your static files directory
upload_static_files "$STATIC_FILES_DIR"

log "Deployment complete!" - 