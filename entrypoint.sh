#!/bin/bash
set -e

# Copy runner configuration from persistent volume if it exists
if [ -f "/runner-data/.runner" ]; then
    echo "Found existing runner configuration, copying from persistent storage..."
    cp -r /runner-data/.runner* /actions-runner/ 2>/dev/null || true
    cp -r /runner-data/_work /actions-runner/ 2>/dev/null || true
fi

if [ "$1" = "config" ]; then
    shift
    echo "Configuring GitHub Actions runner..."
    ./config.sh "$@"
    
    # Save configuration to persistent volume
    echo "Saving runner configuration to persistent storage..."
    cp -r .runner* /runner-data/ 2>/dev/null || true
    mkdir -p /runner-data/_work
    
elif [ "$1" = "run" ]; then
    echo "Starting GitHub Actions runner..."
    # Ensure we have the latest config from persistent storage
    if [ -f "/runner-data/.runner" ]; then
        cp -r /runner-data/.runner* /actions-runner/ 2>/dev/null || true
    fi
    
    # Create _work directory if it doesn't exist
    mkdir -p _work
    
    # Run the runner
    ./run.sh
    
else
    exec "$@"
fi
