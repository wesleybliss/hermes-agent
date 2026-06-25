#!/usr/bin/env bash

# Exit immediately if a command fails
set -e

CONTAINER_NAME="hermes"

# Check if the container exists and is running
IS_RUNNING=$(podman container inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null || echo "false")

if [ "$IS_RUNNING" = "true" ]; then
    echo "================================================================="
    echo "⚠️  WARNING: The '$CONTAINER_NAME' container is currently running."
    echo "   Upgrading will stop the service and disrupt active sessions."
    echo "================================================================="
    read -p "Do you want to proceed with the upgrade? (y/N): " CONFIRM

    # Convert answer to lowercase and evaluate
    if [[ ! "${CONFIRM,,}" =~ ^(yes|y)$ ]]; then
        echo "Upgrade aborted. Container left running."
        exit 0
    fi
    echo "Proceeding with upgrade..."
else
    echo "Container '$CONTAINER_NAME' is not running. Starting build flow..."
fi

# 1. Pull the absolute newest 'nousresearch/hermes-agent:latest' base layer
echo "Pulling latest upstream base image..."
# podman compose pull hermes
podman pull nousresearch/hermes-agent:latest

# 2. Rebuild the image. 
# We use --no-cache to force the container engine to run the "pip install" layer 
# fresh, guaranteeing you fetch the newest pip package releases.
echo "Rebuilding custom image layer without cache..."
podman compose build --no-cache hermes

# 3. Re-create and restart the services in the background
echo "Bringing the updated container stack online..."
podman compose up -d

echo "-----------------------------------------------------------------"
echo "✅ Upgrade complete! Run 'podman compose logs -f' to verify status."
echo "-----------------------------------------------------------------"
