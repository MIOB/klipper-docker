#!/usr/bin/env bash
set -e

function build_firmware() {
  docker run --rm -it \
    --pull "${pull}" \
    -v './out:/opt/klipper/out' \
    -v "./config/klipper.config:/opt/klipper/.config" \
    --user "$(id -u):$(id -g)" \
    ghcr.io/miob/klipper-tools:latest \
   "$@"
}

function clean() {
    rm -rf out
    rm -f config/klipper.config
}

function init() {
  if [[ ! -f config/klipper.config ]]; then
    touch config/klipper.config
  fi

  if [[ ! -d out ]]; then
    mkdir out
  fi
}

command='make menuconfig && make'
if [[ $1 == "--mks_robin" ]]; then
  command="${command} scripts/update_mks_robin.py out/klipper.bin out/Robin_nano35.bin"
fi

command=()
pull="missing"
clean=false
build=true
while test $# -gt 0; do
    opt=$1
    shift
    case "$opt" in
    --mks-robin)
        command=('make menuconfig && make && scripts/update_mks_robin.py out/klipper.bin out/Robin_nano35.bin')
        ;;
    --pull)
        pull="always"
        ;;
    --clean)
        clean=true
        ;;
    --no-build)
        build=false
        ;;
    *)
        fatal "Unexpected option: $opt"
        ;;
    esac
done

if $clean; then
  clean
fi
init
if $build; then
  build_firmware "${command[@]}"
fi