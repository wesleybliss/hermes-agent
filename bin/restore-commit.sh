#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "USAGE: hermes-restore-checkpoint <filename.tar>"
    exit 1
fi

URI="/root/checkpoints/$1"

if [ ! -f "$URI" ]; then
    echo "Backup $URI does not exist"
    exit 2
fi

podman container restore --import="$URI"
