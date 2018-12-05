#!/usr/bin/env bash
set -e -u -o pipefail

./build_root_targz.sh |& tee thisBuild.log
./gitPush.sh
