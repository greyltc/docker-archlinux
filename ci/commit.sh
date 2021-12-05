#!/usr/bin/env bash

TAG="${1}"
if ! test -z "${TAG}"
then
  git commit -m "root tarball(s) rebuilt"
  git tag -a "${TAG}" -m "rebuilt root tarball(s)"
  git push -u origin master --tags
fi