#!/usr/bin/env bash

touch "config/klipper.config"
mkdir "out"

command='make menuconfig && make'
if [[ $1 == "--mks_robin" ]]; then
  command="${command} scripts/update_mks_robin.py out/klipper.bin out/Robin_nano35.bin"
fi

docker run --rm -it \
  --pull "always" \
  -v './out:/opt/klipper/out' \
  -v "./config/klipper.config:/opt/klipper/.config" \
  --user "$(id -u):$(id -g)" \
  ghcr.io/miob/klipper-tools:latest \
  "${command}"