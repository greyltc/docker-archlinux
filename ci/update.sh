#!/usr/bin/env bash
set -e -u -o pipefail

ARCH=${1:-x86_64}

pushd $(git rev-parse --show-toplevel)
./build-root-tarxz.sh ${ARCH} |& tee build-${ARCH}.log
git add build-${ARCH}.log
git add archlinux-${ARCH}.tar.xz
git add Dockerfile
popd
