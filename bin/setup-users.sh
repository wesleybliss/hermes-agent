#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
    echo "Sets up shared permissions between $USER and a hermes user"
    echo "This script must be run as root or with sudo"
    echo "USAGE: sudo $0 <hermes-username>"
    exit
fi

if [ -z "$1" ] || [ "$1" == "--help" ]; then
    echo "Sets up shared permissions between $USER and a hermes user"
    echo "USAGE: sudo $0 <hermes-username>"
    exit
fi

if [ ! -f "./extras/hermes.service.template" ]; then
    echo "./extras/hermes.service.template not found. Run from repo root."
    exit
fi

confirm() {
    printf "%s [y/N] " "$1"
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

if confirm "Do you want to continue?"; then
    echo "Setting up user access..."
else
    echo "Aborted"
    exit
fi

if [ -d "/home/$1" ]; then
    echo "User $1 already exists, skipping create"
else
    sudo useradd -r -m -d /home/$1 -s /bin/bash $1
fi

echo "Adding $USER to $1 group"
sudo usermod -aG $1 $USER

if [ ! -d "/home/$1/.hermes" ]; then
    echo "Hermes not installed. Install or move it to /home/$1/.hermes and run this script again."
    exit
fi

echo "Owning & modding /home/$1"
sudo chown -R $1:$1 /home/$1/.hermes
sudo chmod -R 2775 /home/$1   # setgid + rwxrwxr-x

echo "Adding $1 to docker & ollama groups"
sudo usermod -aG docker,ollama $1

echo "Setting SELinux shared directory permissions"
sudo setfacl -R -m g:$1:rwx /home/$1
sudo setfacl -R -d -m g:$1:rwx /home/$1

SERVICE_EXISTS=0

if ls /etc/systemd/system/*hermes* 2>/dev/null | grep -q .; then
    echo "⚠️  Found files matching 'hermes' in /etc/systemd/system"
    ls -la /etc/systemd/system/*hermes* 2>/dev/null
    SERVICE_EXISTS=1
fi

# Check for system service named hermes
if systemctl list-unit-files | grep -q "^hermes"; then
    echo "⚠️  System service named 'hermes' exists"
    systemctl list-unit-files | grep "^hermes"
    SERVICE_EXISTS=1
fi

# Check for user service named hermes
if systemctl --user list-unit-files 2>/dev/null | grep -q "^hermes"; then
    echo "⚠️  User service named 'hermes' exists"
    systemctl --user list-unit-files | grep "^hermes"
    SERVICE_EXISTS=1
fi

if [ $SERVICE_EXISTS == 1 ]; then
    echo "Skipping creating service. Manually review."
    sed "s/TEMPLATE_USER/$1/g" ../extras/hermes.service.template
else
    echo "Creating system service /etc/systemd/system/hermes.service"
    # /etc/systemd/system/hermes.service
    sed "s/TEMPLATE_USER/$1/g" ./extras/hermes.service.template > /etc/systemd/system/hermes.service
fi

echo "Reloading systemd daemon"
sudo systemctl daemon-reload

echo "Enabling & starting Hermes"
sudo systemctl enable --now hermes.service

echo "Done. run newgrp $1 to update your groups, or logout & back in."
