#!/usr/bin/env bash

sudo dnf install -y syncthing

sudo useradd -r -s /bin/false -d /var/lib/syncthing syncthing
sudo mkdir -p /var/lib/syncthing
sudo chown -R syncthing:syncthing /var/lib/syncthing

sudo systemctl disable syncthing@syncthing
sudo systemctl start syncthing@syncthing

# sudo systemctl restart syncthing@syncthing

echo 'Run syncthing generate --gui-password='<pass>' --gui-user=hermes to set a GUI account'
