#!/bin/bash

source ./scripts/common.sh

# Deploy Frontend Stack
log "Deploying frontend stack..."
aws cloudformation deploy \
  --template-file cloudformation/frontend/frontend.yml \
  --stack-name cloud-resume-frontend \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides DomainName=$DOMAIN_NAME CertificateArn=$CERTIFICATE_ARN

# Deploy Backend Stack
log "Deploying backend stack..."
aws cloudformation deploy \
  --template-file cloudformation/backend/backend.yml \
  --stack-name cloud-resume-backend \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides LambdaCodeBucket=$LAMBDA_CODE_BUCKET
