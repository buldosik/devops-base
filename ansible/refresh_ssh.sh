#!/usr/bin/env bash
set -e

DEFAULTPATH="/mnt/e/_Projects/_Devops/test-project"

SOURCES=(
  "devops-vms/.vagrant/machines/default/virtualbox/private_key"
  "devops-vms-back/.vagrant/machines/default/virtualbox/private_key"
  "devops-vms-db/.vagrant/machines/default/virtualbox/private_key"
)

DESTS=(
  "$HOME/.ssh/vagrant_key"
  "$HOME/.ssh/vagrant_key_back"
  "$HOME/.ssh/vagrant_key_db"
)

for i in "${!SOURCES[@]}"; do
  SRC="$DEFAULTPATH/${SOURCES[$i]}"
  DST="${DESTS[$i]}"

  if [[ ! -f "$SRC" ]]; then
    echo "Skip: no key at $SRC"
    continue
  fi

  cp "$SRC" "$DST"
  chmod 600 "$DST"
  echo "Vagrant key refreshed: $DST"
done
