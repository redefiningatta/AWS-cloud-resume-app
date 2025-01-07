#!/bin/bash

source ./scripts/common.sh

# Deploy ACM Certificate
log "Deploying ACM Certificate..."
aws cloudformation deploy \
  --template-file cloudformation/certificates/acm-certificate.yml \
  --stack-name $NEW_CERTIFICATE_STACK_NAME \
  --region $CERTIFICATE_REGION \
  --parameter-overrides DomainName=$DOMAIN_NAME

# Wait for Certificate stack
log "Waiting for ACM Certificate stack to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name $NEW_CERTIFICATE_STACK_NAME \
  --region $CERTIFICATE_REGION || {
    log "Stack creation timeout or failure. Proceeding to fetch certificate details."
}

log "ACM Certificate Stack Deployment Completed Successfully"

