#!/usr/bin/env bash
set -e -u -o pipefail

pushd $(git rev-parse --show-toplevel)
./build-root-tarxz.sh |& tee build.log
git add thisBuild.log
git add archlinux.tar.xz
git add Dockerfile
git commit -m "$(date): bump to latest Arch Linux"
git push -u origin master
git tag -a $(date -I) -m "$(date) snapshot" && git push --tags
popd
