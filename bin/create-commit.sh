#!/usr/bin/env bash

set -e

TS=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_IMAGE="hermes-backup:$TS"

echo "================================================================="
echo "⚠️  WARNING: This script will STOP the 'hermes' container"
echo "   and create a local filesystem backup image."
echo "================================================================="
read -p "Are you sure you want to proceed? (y/N): " CONFIRM

if [[ ! "${CONFIRM,,}" =~ ^(yes|y)$ ]]; then
    echo "Aborting. No changes made."
    exit 0
fi

echo "Stopping 'hermes' container cleanly..."
podman stop hermes

echo "Creating backup image..."
echo "> $BACKUP_IMAGE"
podman commit hermes "$BACKUP_IMAGE"

echo "-----------------------------------------------------------------"
echo "✅ Backup image created successfully!"
echo "If your maintenance fails, you can restore by running:"
echo "  1. podman rm -f hermes"
echo "  2. podman run -d --name hermes [YOUR-STARTUP-FLAGS] $BACKUP_IMAGE"
echo "-----------------------------------------------------------------"

echo "Starting container back up for maintenance..."
podman start hermes

# If you are modifying files inside the container's root filesystem and
# just want a snapshot of the disk, you can commit the running container into a temporary image.
# 1. Commit the running container to a backup image
#podman commit my-container-name my-maintenance-backup-image

# 2. Perform your maintenance. 

# 3. CRITICAL FAILURE? Delete the broken container and spin up a new one from your backup image:
#podman rm -f my-container-name
#podman run -d --name my-container-name [YOUR-ORIGINAL-FLAGS] my-maintenance-backup-image


# If your maintenance involves upgrading Podman itself, upgrading the host OS,
# or anything that might require a reboot, you can export the container's entire filesystem to a tarball.
# 1. Export the container filesystem
#podman export my-container-name > /tmp/container-fs-backup.tar

# 2. CRITICAL FAILURE? Import it back as an image and deploy it
#podman import /tmp/container-fs-backup.tar my-restored-image
#podman run -d --name my-container-name [YOUR-ORIGINAL-FLAGS] my-restored-image
