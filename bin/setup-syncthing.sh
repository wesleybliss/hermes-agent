#!/usr/bin/env bash

sudo dnf install -y syncthing

sudo useradd -r -s /bin/false -d /var/lib/syncthing syncthing
sudo mkdir -p /var/lib/syncthing
sudo chown -R syncthing:syncthing /var/lib/syncthing

sudo systemctl disable syncthing@syncthing
sudo systemctl start syncthing@syncthing
