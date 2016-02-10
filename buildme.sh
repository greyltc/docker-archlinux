#!/usr/bin/env bash

set -e -u -o pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)

cat > "$DIR/Dockerfile" << EOF
# Arch Linux baseline docker container
# Generated on `date` using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in root filesystem archive
ADD archlinux.tar.xz /

RUN ["/usr/bin/pacman", "--noconfirm", "-Sy", "--force", "coreutils", "bash", "grep", "gawk", "file", "tar", "sed", "acl", "archlinux-keyring", "attr", "bzip2", "curl", "e2fsprogs", "expat", "glibc", "gpgme", "keyutils", "krb5", "libarchive", "libassuan", "libgpg-error", "libidn", "libssh2", "lzo", "openssl", "pacman", "pacman-mirrorlist", "xz", "zlib"]

# perform initial container setup tasks
RUN setup-arch-docker-container

# this allows the system profile to be sourced at every shell
ENV ENV /etc/profile
EOF

# make the root filesystem
echo -e "\033[1mGenerating Arch Linux root filesystem...\033[0m"
TEMP_ROOT=./tmproot
rm -rf $TEMP_ROOT || True
../arch-bootstrap/arch-bootstrap.sh $TEMP_ROOT 1
echo -e "\033[1mRoot filesystem generation complete.\033[0m"

# install our setup script
echo -e "\033[1mInstalling setup script.\033[0m"
install -m755 -D "$DIR/setup-arch-docker-container.sh" "$TEMP_ROOT/usr/bin/setup-arch-docker-container"

# dockerify the rootfs
echo -e "\033[1mDoing Docker things to the root file system.\033[0m"
pushd $TEMP_ROOT
DEV=dev
rm -rf $DEV
mkdir -p $DEV
fakeroot mknod -m 666 $DEV/null c 1 3
fakeroot mknod -m 666 $DEV/zero c 1 5
fakeroot mknod -m 666 $DEV/random c 1 8
fakeroot mknod -m 666 $DEV/urandom c 1 9
fakeroot mkdir -m 755 $DEV/pts
fakeroot mkdir -m 1777 $DEV/shm
fakeroot mknod -m 666 $DEV/tty c 5 0
fakeroot mknod -m 600 $DEV/console c 5 1
fakeroot mknod -m 666 $DEV/tty0 c 4 0
fakeroot mknod -m 666 $DEV/full c 1 7
fakeroot mknod -m 600 $DEV/initctl p
fakeroot mknod -m 666 $DEV/ptmx c 5 2
ln -sf /proc/self/fd $DEV/fd

# correct some permissions
chmod 1777 tmp/
chmod 1777 var/tmp/
chmod 775 var/games/
chmod 1777 var/spool/mail/

# remove some files that we don't need here
rm -rf usr/share/man/*
rm -rf etc/hosts
rm -rf etc/resolv.conf
rm -rf etc/passwd
rm -rf etc/shadow
#rm -rf etc/pacman.d/mirrorlist
#rm -rf etc/pacman.conf

popd

# make the root filesystem archive
rm -rf archlinux.tar.xz
pushd $TEMP_ROOT
echo -e "\033[1mCompressing root filesystem archive...\033[0m"
XZ_OPT="-9 -T 0" tar --owner=0 --group=0 --xattrs --acls -Jcf ../archlinux.tar.xz *
popd
echo -e "\033[1mRoot fs archive generation complete.\033[0m"

rm -rf $TEMP_ROOT
