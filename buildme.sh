#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cat > Dockerfile << EOF
# Arch Linux baseline docker container
# Generated on `date`
# Read the following to learn how the root filesystem image was generated:
# https://github.com/l3iggs/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER l3iggs <l3iggs@live.com>
ADD archlinux.tar.xz /
RUN pacman -Syyu --needed --noconfirm
RUN pacman -S --needed --noconfirm reflector
RUN reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
EOF

curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch.sh > /tmp/mkimage-arch.sh
chmod +x /tmp/mkimage-arch.sh

sed -i 's/| docker import - archlinux/-af archlinux.tar.xz/g' /tmp/mkimage-arch.sh
sed -i '/docker run -t archlinux echo Success./d' /tmp/mkimage-arch.sh

curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch-pacman.conf > /tmp/mkimage-arch-pacman.conf

cd /tmp
echo "Building Arch Linux-docker root filesystem archive."
sudo /tmp/mkimage-arch.sh # this leaves /tmp/archlinux.tar.xz behind :-/
echo "Arch Linux-docker root filesystem archive build complete."
cp /tmp/archlinux.tar.xz ${DIR}/

rm /tmp/mkimage-arch.sh
rm /tmp/mkimage-arch-pacman.conf
