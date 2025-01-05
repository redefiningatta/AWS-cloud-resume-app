#!/bin/bash

source ./scripts/common.sh

# Deploy ACM Certificate
log "Deploying ACM Certificate..."
CERTIFICATE_STACK_NAME="Acm-certificate"
aws cloudformation deploy \
  --template-file cloudformation/certificates/acm-certificate.yml \
  --stack-name $CERTIFICATE_STACK_NAME \
  --region $CERTIFICATE_REGION \
  --parameter-overrides DomainName=$DOMAIN_NAME

# Wait for Certificate stack
log "Waiting for ACM Certificate stack to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name $CERTIFICATE_STACK_NAME \
  --region $CERTIFICATE_REGION

# Fetch Certificate ARN
log "Fetching ACM Certificate ARN..."
CERTIFICATE_ARN=$(aws cloudformation describe-stacks \
  --stack-name $CERTIFICATE_STACK_NAME \
  --region $CERTIFICATE_REGION \
  --query "Stacks[0].Outputs[?OutputKey=='CertificateArn'].OutputValue" \
  --output text)

if [ -z "$CERTIFICATE_ARN" ]; then
    log "Failed to fetch ACM Certificate ARN. Exiting."
    exit 1
fi
log "Certificate ARN: $CERTIFICATE_ARN"
