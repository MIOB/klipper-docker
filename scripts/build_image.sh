#!/usr/bin/env bash

set -e

readonly APP=${1}
shift
readonly REGISTRY=${1}
shift
readonly ADDITIONAL_ARGS="$*"
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

echo "Building ${APP} with tag ${TAG}"
docker buildx build \
  --build-arg "VERSION=${COMMIT}" \
  --tag "${REGISTRY}${APP}:${TAG}" \
  --tag "${REGISTRY}${APP}:latest" \
  --target "run" \
  "${ADDITIONAL_ARGS}" \
  \
  "docker/${APP}"