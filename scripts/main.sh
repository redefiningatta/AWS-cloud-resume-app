#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source common functions
source ./scripts/common.sh

# Execute modules
./scripts/check_prerequisites.sh
./scripts/build_lambda.sh
./scripts/deploy_acm_certificate.sh
./scripts/deploy_cloudformation_stacks.sh
./scripts/update_frontend.sh

# Deployment Completed
log "Deployment complete!"
