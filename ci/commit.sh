#!/usr/bin/env bash

TAG="${1}"
if ! test -z "${TAG}"
then
  git config --global user.name 'CI Robot'
  git config --global user.email 'ci@robot.fake'
  git commit -m "version ${TAG} root tarball(s) rebuilt"
  git tag -a "${TAG}" -m "rebuilt root tarball(s)"
  git push -u origin master --tags
fi
