#!/bin/bash

# Get API Gateway URL
API_URL=$(aws cloudformation describe-stacks --stack-name cloud-resume-backend --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" --output text)

if [ -z "$API_URL" ]; then
  echo "Error: Unable to retrieve API Gateway URL."
  exit 1
fi

echo "API Gateway URL: $API_URL"

# Set the API URL as an environment variable
export API_URL=$API_URL

# Run Cypress with the updated environment variable
npx cypress run --reporter mochawesome