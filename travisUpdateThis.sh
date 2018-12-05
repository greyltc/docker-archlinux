#!/usr/bin/env bash
set -e -u -o pipefail

cd $TRAVIS_BUILD_DIR

./build_root_targz.sh |& tee thisBuild.log

git config user.name "Travis CI"
git config user.email "travis@rob.ot"

git add thisBuild.log
git add archlinux.tar.xz
git add Dockerfile

chmod 600 travis_key
eval `ssh-agent -s`

ssh-add travis_key

git commit -m "$(date -u -I): bump to latest Arch Linux -- via travis"

export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

git remote set-url --push origin git@github.com:greyltc/docker-archlinux.git

TAG="$(date -u -I)-travis"
git push origin master
git tag ${TAG} master --force
#git tag -a $(date -I) -m "$(date) snapshot" --force
#git push --tags --force
#git tag ${TAG} master --force
#git push origin ${TAG} --tags --force -v --progress
