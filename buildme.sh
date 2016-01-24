#!/usr/bin/env bash

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)

cat > "$DIR/Dockerfile" << EOF
# Arch Linux baseline docker container
# Generated on `date` using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in root filesystem archive
ADD archlinux.tar.xz /

# perform initial container setup tasks
RUN setup-arch-docker-container
EOF

# make the root filesystem
TEMP_ROOT=./tmproot
rm -rf $TEMP_ROOT
mkdir -p $TEMP_ROOT
echo -e "\033[1mGenerating Arch Linux root filesystem...\033[0m"
fakechroot fakeroot "$DIR/arch-bootstrap.sh" -a x86_64 $TEMP_ROOT
echo -e "\033[1mRoot filesystem generation complete.\033[0m"

# install our setup script
echo -e "\033[1mInstalling setup script.\033[0m"
install -m755 -D "$DIR/setup-arch-docker-container.sh" "$TEMP_ROOT/usr/bin/setup-arch-docker-container"

# make the root filesystem archive
rm -rf archlinux.tar.xz
pushd $TEMP_ROOT
echo -e "\033[1mCompressing root filesystem archive...\033[0m"
XZ_OPT="-9 -T 0" tar --owner=0 --group=0 --xattrs --acls -Jcf ../archlinux.tar.xz *
popd
echo -e "\033[1mRoot fs archive generation complete.\033[0m"

rm -rf rm -rf $TEMP_ROOT

