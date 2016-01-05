#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)

cat > Dockerfile << EOF
# Arch Linux baseline docker container
# Generated on `date`
# Read the following to learn how the root filesystem image was generated:
# https://github.com/l3iggs/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER l3iggs <l3iggs@live.com>

# copy in the previously generated file system
ADD archlinux.tar.xz /

# update mirrorlist and packages
ADD updateArch.sh /usr/sbin/updateArch.sh
RUN chmod +x /usr/sbin/updateArch.sh; updateArch.sh
EOF

curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch.sh > /tmp/mkimage-arch.sh
chmod +x /tmp/mkimage-arch.sh

sed -i 's,| docker import - archlinux,-af /tmp/archlinux.tar.xz,g' /tmp/mkimage-arch.sh
sed -i '/docker run --rm -t archlinux echo Success./d' /tmp/mkimage-arch.sh
sed -i '$a chown '${USER}' /tmp/archlinux.tar.xz' /tmp/mkimage-arch.sh

curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch-pacman.conf > /tmp/mkimage-arch-pacman.conf

cd /tmp
echo "Building Arch Linux-docker root filesystem archive."
echo -e "\033[1msudo is required for the arch-chroot command.\033[0m"
sudo /tmp/mkimage-arch.sh
if [ -f /tmp/archlinux.tar.xz ]; then
    echo "Arch Linux-docker root filesystem archive build complete!"
    cp /tmp/archlinux.tar.xz ${DIR}/
else
    echo "The Arch Linux-docker root filesystem archive build failed."
fi

rm -rf /tmp/mkimage-arch.sh
rm -rf /tmp/mkimage-arch-pacman.conf
rm -rf /tmp/archlinux.tar.xz

