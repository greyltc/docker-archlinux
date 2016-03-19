#!/usr/bin/env bash
set -e -u -o pipefail

./buildme.sh &> buildme.log
git add buildme.log
git add archlinux.tar.xz
git add Dockerfile
git commit -m "$(date): bump to latest Arch Linux"
git push -u origin master
git tag -a $(date -I) -m "$(date) snapshot" && git push --tags
