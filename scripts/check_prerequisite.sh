#!/bin/bash

source ./scripts/common.sh

# Check for required tools
log "Checking for required tools..."
for cmd in aws zip; do
    if ! command -v $cmd &> /dev/null; then
        log "$cmd command not found. Please install $cmd."
        exit 1
    fi
done
