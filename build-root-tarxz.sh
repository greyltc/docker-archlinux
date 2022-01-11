#!/usr/bin/env bash
set -e -u -o pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)

# build architecture
ARCH=${1:-x86_64}

cat > "${DIR}/Dockerfile" <<"END"
# Arch Linux baseline docker container
# Generated on `date` using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in super minimal root filesystem archive
ADD archlinux-${ARCH}.tar.xz /

# perform initial container setup tasks
RUN provision-container

# this allows the system profile to be sourced at every shell
ENV ENV /etc/profile
END

# make the root filesystem
echo -e "\033[1mGenerating Arch Linux root filesystem...\033[0m"

TMP_ROOT=$(mktemp -d)

# Bail out if the temp directory wasn't created successfully.
if [ ! -e ${TMP_ROOT} ]; then
    >&2 echo "Failed to create temp directory"
    exit 1
fi
#TODO: work in ARCH here
bash <(curl --silent --tlsv1.3 --location 'https://raw.githubusercontent.com/greyltc/arch-bootstrap/master/arch-bootstrap.sh') -a${ARCH} -s1 "${TMP_ROOT}"
echo -e "\033[1mRoot filesystem generation complete.\033[0m"

# inject our setup script
echo -e "\033[1mInstalling setup script.\033[0m"
install -m755 -D "${DIR}/provision-container.sh" "${TMP_ROOT}/usr/bin/provision-container"

# inject the details fixer
curl --silent --tlsv1.3 --location 'https://raw.githubusercontent.com/greyltc/arch-bootstrap/master/fix-details.sh' > "${TMP_ROOT}/usr/bin/fix-details"
chmod +x "${TMP_ROOT}/usr/bin/fix-details"

# inject the image size reducer
install -m755 -D "${DIR}/cleanup-image.sh" "$TMP_ROOT/usr/sbin/cleanup-image"

# dockerify the rootfs
echo -e "\033[1mDoing Docker things to the root file system.\033[0m"
pushd "${TMP_ROOT}"
rm -rf dev
mkdir -p dev

pushd dev
fakeroot mknod -m 666 null c 1 3
fakeroot mknod -m 666 zero c 1 5
fakeroot mknod -m 666 random c 1 8
fakeroot mknod -m 666 urandom c 1 9
fakeroot mkdir -m 755 pts
fakeroot mkdir -m 1777 shm
fakeroot mknod -m 666 tty c 5 0
fakeroot mknod -m 600 console c 5 1
fakeroot mknod -m 666 tty0 c 4 0
fakeroot mknod -m 666 full c 1 7
fakeroot mknod -m 600 initctl p
fakeroot mknod -m 666 ptmx c 5 2
ln -sf /proc/self/fd fd
popd

# remove some files that we don't need here
rm -rf usr/share/man/*
rm -rf etc/hosts*
rm -rf etc/resolv.conf*
rm -rf etc/passwd*
rm -rf etc/shadow*
popd

# make the root filesystem archive
rm -rf "${DIR}/archlinux-${ARCH}.tar.xz"
pushd "${TMP_ROOT}"
echo -e "\033[1mCompressing root filesystem archive...\033[0m"
XZ_OPT="-9e --threads=0" tar --owner=0 --group=0 --xattrs --acls -Jcf "${DIR}/archlinux-${ARCH}.tar.xz" *
popd
echo -e "\033[1mRoot fs archive generation complete.\033[0m"

rm -rf "${TMP_ROOT}"
