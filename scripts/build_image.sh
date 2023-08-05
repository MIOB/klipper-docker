#!/usr/bin/env bash

set -e

readonly APP=${1}
shift
readonly GITHUB_NAME=${1,,}
shift
readonly ADDITIONAL_ARGS="$*"
readonly REGISTRY="ghcr.io/${GITHUB_NAME}/"
readonly DOCKERFILE="docker/${APP}/Dockerfile"
if [[ ! -f "${DOCKERFILE}" ]]; then
  echo "Dockerfile not found"
  exit 1
fi

REPOSITORY=$(grep "ARG REPOSITORY" "${DOCKERFILE}" | cut -d = -f 2)
readonly REPOSITORY

echo "Getting latest commit from ${REPOSITORY}"
COMMIT=$(git ls-remote "${REPOSITORY}" master | cut -f 1)
readonly COMMIT

TAG=$(echo "${COMMIT}" | cut -c 1-8)
readonly TAG

function build_image() {
  local target=${1}
  local name=${2}
  echo "Building target ${target} of ${name} with tag ${TAG}"
  docker buildx build \
    --platform "linux/arm64/v8" \
    --build-arg "VERSION=${COMMIT}" \
    --tag "${REGISTRY}${name}:${TAG}" \
    --tag "${REGISTRY}${name}:latest" \
    --target "${target}" \
    "${ADDITIONAL_ARGS}" \
    \
    "docker/${APP}"
}

build_image "run" "${APP}"

if [[ $APP == "klipper" ]]; then
  build_image "tools" "klipper-tools"
fi
