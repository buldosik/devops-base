#!/usr/bin/env bash
set -e

KEY_SRC="/mnt/e/_Projects/_Devops/test-project/devops-vms/.vagrant/machines/default/virtualbox/private_key"
KEY_DST="$HOME/.ssh/vagrant_key"

cp "$KEY_SRC" "$KEY_DST"
chmod 600 "$KEY_DST"
echo "Vagrant key refreshed."
