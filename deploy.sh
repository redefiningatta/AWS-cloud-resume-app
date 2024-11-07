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
# LAMBDA_ZIP="visitor_counter.zip"
# AWS_REGION="eu-west-2"
# CERTIFICATE_REGION="us-east-1"  # ACM certificates for CloudFront must be in us-east-1
# DOMAIN_NAME="resume.iamatta.com"

# Check if 7z (7-Zip) is installed
if ! command -v zip &> /dev/null; then
    log "zip command not found. Please install Zip utility."
    exit 1
fi

# Zip Lambda function code
log "Zipping Lambda function..."
cd lambda || handle_error $LINENO
zip -r $LAMBDA_ZIP visitor_counter.py
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
aws s3 cp lambda/$LAMBDA_ZIP s3://$LAMBDA_CODE_BUCKET/


# Deploy CloudFormation stacks
log "Deploying CloudFormation stacks..."

log "Deploying ACM Certificate..."
aws cloudformation deploy \
  --template-file cloudformation/certificates/acm-certificate.yml \
  --stack-name Acm-certificate \
  --region $CERTIFICATE_REGION \
  --parameter-overrides DomainName=$DOMAIN_NAME
  


log "Waiting for certificate validation..."

CERTIFICATE_ARN=$(aws cloudformation describe-stacks --stack-name $CERTIFICATE_STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='CertificateArn'].OutputValue" --output text)

aws acm wait certificate-validated --certificate-arn $CERTIFICATE_ARN --region $CERTIFICATE_REGION

log "Certificate successfully created and validated: $CERTIFICATE_ARN"

# Deploy backend resources (Lambda, API Gateway, DynamoDB)
log "Deploying backend stack..."
aws cloudformation deploy \
  --template-file cloudformation/backend/backend.yml \
  --stack-name cloud-resume-backend \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides LambdaCodeBucket=$LAMBDA_CODE_BUCKET

# Deploy frontend resources (S3, CloudFront)
log "Deploying frontend stack..."
aws cloudformation deploy \
  --template-file cloudformation/frontend/frontend.yml \
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
JS_FILE=".assets/static/scripts.js"  # Change this to your actual JavaScript file path
update_js_file "$JS_FILE" "$API_URL"

# Function to upload static files to S3
upload_static_files() {
    local source_dir=$1
    local dest_path=$2  # This allows specifying a subpath in the S3 bucket

    if [[ -d "$source_dir" ]]; then
        log "Uploading files from $source_dir to s3://$FRONTEND_BUCKET_NAME/$dest_path..."
        aws s3 sync "$source_dir" "s3://$FRONTEND_BUCKET_NAME/$dest_path" --delete
    else
        log "Directory $source_dir does not exist. Skipping upload for $source_dir."
    fi
}

# Define the directories for static files and images
STATIC_FILES_DIR="./assets/static"  # Path to static files
IMAGES_DIR="./assets/images"        # Path to images

# Upload static files and images to S3, ensuring correct subpaths
upload_static_files "$STATIC_FILES_DIR" "static"   # Sync assets/static to s3://bucket-name/static
upload_static_files "$IMAGES_DIR" "images"         # Sync assets/images to s3://bucket-name/images


log "Deployment complete!" - 