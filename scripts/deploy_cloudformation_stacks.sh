#!/bin/bash

source ./scripts/common.sh

# Fetch Certificate ARN
log "Fetching ACM Certificate ARN..."
CERTIFICATE_ARN=$(aws cloudformation describe-stacks \
  --stack-name $NEW_CERTIFICATE_STACK_NAME \
  --region $CERTIFICATE_REGION \
  --query "Stacks[0].Outputs[?OutputKey=='CertificateArn'].OutputValue" \
  --output text)

if [ -z "$CERTIFICATE_ARN" ]; then
    log "Failed to fetch ACM Certificate ARN. Proceeding with subsequent steps may not work."
    exit 1
fi
    
log "Certificate ARN: $CERTIFICATE_ARN"

# Deploy Frontend Stack
log "Deploying frontend stack..."
aws cloudformation deploy \
  --template-file cloudformation/frontend/frontend.yml \
  --stack-name cloud-resume-frontend \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides DomainName=$DOMAIN_NAME AcmCertificateArn=$CERTIFICATE_ARN

# Deploy Backend Stack
log "Deploying backend stack..."
aws cloudformation deploy \
  --template-file cloudformation/backend/backend.yml \
  --stack-name cloud-resume-backend \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides LambdaCodeBucket=$LAMBDA_CODE_BUCKET
