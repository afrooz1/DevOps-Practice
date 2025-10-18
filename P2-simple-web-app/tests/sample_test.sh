#!/bin/bash
# Check if Docker container is running
CONTAINER_NAME="webapp"

if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
    echo "✅ Container $CONTAINER_NAME is running."
    exit 0
else
    echo "❌ Container $CONTAINER_NAME is NOT running."
    exit 1
fi
