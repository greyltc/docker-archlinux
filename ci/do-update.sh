#!/usr/bin/env bash
set -e -u -o pipefail

ARCH="$1"

pushd $(git rev-parse --show-toplevel)
./build-root-tarxz.sh ${ARCH} |& tee build-${ARCH}.log
git add build-${ARCH}.log
git add archlinux-${ARCH}.tar.xz
git add Dockerfile
#git commit -m "$(date): bump to latest Arch Linux"
#git push -u origin master
#git tag -a $(date -I) -m "$(date) snapshot" && git push --tags
popd
