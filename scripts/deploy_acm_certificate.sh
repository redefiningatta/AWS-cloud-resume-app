#!/bin/bash

source ./scripts/common.sh

CERTIFICATE_STACK_NAME="Acm-certificate"

# Deploy ACM Certificate
log "Deploying ACM Certificate..."
aws cloudformation deploy \
  --template-file cloudformation/certificates/acm-certificate.yml \
  --stack-name $CERTIFICATE_STACK_NAME \
  --region $CERTIFICATE_REGION \
  --parameter-overrides DomainName=$DOMAIN_NAME

# Wait for Certificate stack
log "Waiting for ACM Certificate stack to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name $CERTIFICATE_STACK_NAME \
  --region $CERTIFICATE_REGION || {
    log "Stack creation timeout or failure. Proceeding to fetch certificate details."
}

# Fetch Certificate ARN
log "Fetching ACM Certificate ARN..."
CERTIFICATE_ARN=$(aws cloudformation describe-stacks \
  --stack-name $CERTIFICATE_STACK_NAME \
  --region $CERTIFICATE_REGION \
  --query "Stacks[0].Outputs[?OutputKey=='CertificateArn'].OutputValue" \
  --output text)

if [ -z "$CERTIFICATE_ARN" ]; then
    log "Failed to fetch ACM Certificate ARN. Proceeding with subsequent steps may not work."
else
    log "Certificate ARN: $CERTIFICATE_ARN"
    echo "CERTIFICATE_ARN=$CERTIFICATE_ARN" >> $GITHUB_ENV
fi

# Poll for certificate status if ARN is available
if [[ -n "$CERTIFICATE_ARN" ]]; then
    MAX_RETRIES=30
    RETRY_INTERVAL=10  # seconds
    log "Checking ACM Certificate status..."
    for ((i = 1; i <= MAX_RETRIES; i++)); do
        CERT_STATUS=$(aws acm describe-certificate \
            --certificate-arn "$CERTIFICATE_ARN" \
            --region "$CERTIFICATE_REGION" \
            --query "Certificate.Status" \
            --output text)
        
        if [[ "$CERT_STATUS" == "ISSUED" ]]; then
            log "ACM Certificate issued successfully."
            break
        elif [[ "$i" -eq "$MAX_RETRIES" ]]; then
            log "Certificate issuance timeout. Proceeding with the pipeline."
        else
            log "Certificate status: $CERT_STATUS. Retrying in $RETRY_INTERVAL seconds..."
            sleep $RETRY_INTERVAL
        fi
    done
else
    log "Certificate ARN not available. Skipping status checks."
fi

