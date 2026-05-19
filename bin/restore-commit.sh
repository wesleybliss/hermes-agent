#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    echo "USAGE: hermes-restore <image_tag>"
    echo "Example: hermes-restore hermes-backup:2026-05-19_20-44-08"
    exit 1
fi

IMAGE_TAG="$1"

# 1. Verify the backup image actually exists in Podman storage
if ! podman image exists "$IMAGE_TAG"; then
    echo "❌ Error: Backup image '$IMAGE_TAG' does not exist."
    exit 2
fi

echo "================================================================="
echo "⚠️  WARNING: This will DESTRUCTIVELY replace the active 'hermes'"
echo "   container with the backup snapshot: $IMAGE_TAG"
echo "================================================================="
read -p "Are you sure you want to proceed? (y/N): " CONFIRM

if [[ ! "${CONFIRM,,}" =~ ^(yes|y)$ ]]; then
    echo "Aborting restore operation."
    exit 0
fi

echo "Inspecting configuration of current container..."
# Dynamically capture ports, volumes, environment variables, and networks 
# so we don't have to guess or hardcode the original startup flags.
START_ARGS=$(podman container inspect hermes --format '{{range .Config.Env}}-e {{.}} {{end}}{{range .Mounts}}-v {{.Source}}:{{.Destination}}{{if .Mode}}:{{.Mode}}{{end}} {{end}}{{range $p, $conf := .NetworkSettings.Ports}}{{range $conf}}-p {{.HostIp}}:{{.HostPort}}:{{$p}} {{end}}{{end}}--network {{.HostConfig.NetworkMode}}')

echo "Removing the broken 'hermes' container..."
podman rm -f hermes

echo "Deploying restored container from backup image..."
# Re-run the container using the exact configuration extracted above
podman run -d --name hermes $START_ARGS "$IMAGE_TAG"

echo "-----------------------------------------------------------------"
echo "✅ 'hermes' has been successfully restored from $IMAGE_TAG"
echo "-----------------------------------------------------------------"
