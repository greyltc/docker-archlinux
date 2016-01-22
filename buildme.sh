#!/usr/bin/env bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)
cp -a "$DIR/updateArch.sh" /tmp/.

cat > Dockerfile << EOF
# Arch Linux baseline docker container
# Generated on `date`
# Read the following to learn how the root filesystem image was generated:
# https://github.com/greyltc/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in the previously generated file system
ADD archlinux.tar.xz /

# update mirrorlist and packages
RUN updateArch.sh
EOF

# fetch the official Arch Linux generation script from Docker's github account
curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch.sh > /tmp/mkimage-arch.sh
chmod +x /tmp/mkimage-arch.sh

# install a script that will be used to update the mirror list at build time
sed -i 's,arch-chroot $ROOTFS /bin/sh -c '\''echo $PACMAN_MIRRORLIST > /etc/pacman.d/mirrorlist'\'',install -m755 -D /tmp/updateArch.sh -t "$ROOTFS/usr/bin"; arch-chroot $ROOTFS /bin/sh -c '\''touch /usr/bin/updateArch.sh'\'',g' /tmp/mkimage-arch.sh

# instead of importing the image we'll dump the newly created image into a file: /tmp/archlinux.tar.xz
sed -i 's,tar --numeric-owner --xattrs --acls -C $ROOTFS -c . | docker import - $DOCKER_IMAGE_NAME,cd $ROOTFS;XZ_OPT="-9e -T 0" tar --numeric-owner --xattrs --acls -Jcf /tmp/archlinux.tar.xz *,g' /tmp/mkimage-arch.sh

# remove this line since it makes no sense now
sed -i '/docker run --rm -t $DOCKER_IMAGE_NAME echo Success./d' /tmp/mkimage-arch.sh

# change the ownership of the new image
sed -i '$a chown '${USER}' /tmp/archlinux.tar.xz' /tmp/mkimage-arch.sh

# fetch the fixed pacman.conf 
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

