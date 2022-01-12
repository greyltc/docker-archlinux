#!/usr/bin/env bash
set -e -u -o pipefail

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)

# build architecture
ARCH=${1:-x86_64}

# output folder (relative to this script)
OUT=${2:-out}

# build the fs in some temporary place
TMP_ROOT=$(mktemp -d)

# generate the docerfile
cat > "${TMP_ROOT}/Dockerfile" <<END
# Arch Linux baseline docker container
# Generated on `date` using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Greyson Christoforo <grey@christoforo.net>

# put the whole build context into the image
ADD * /

# perform initial container setup tasks
RUN provision-container

# allow the system profile to be sourced at every shell
ENV ENV /etc/profile
END

# make the root filesystem
echo "Generating Arch Linux root filesystem..."
bash <(curl --silent --tlsv1.3 --location 'https://raw.githubusercontent.com/greyltc/arch-bootstrap/master/arch-bootstrap.sh') -a${ARCH} -s1 "${TMP_ROOT}"
echo "Root filesystem generation complete."

# inject our setup script
echo "Installing setup script."
install -m755 -D "${DIR}/provision-container.sh" "${TMP_ROOT}/usr/bin/provision-container"

# inject our details fixer
curl --silent --tlsv1.3 --location 'https://raw.githubusercontent.com/greyltc/arch-bootstrap/master/fix-details.sh' > "${TMP_ROOT}/usr/bin/fix-details"
chmod +x "${TMP_ROOT}/usr/bin/fix-details"

# inject our image size reducer
install -m755 -D "${DIR}/cleanup-image.sh" "${TMP_ROOT}/usr/sbin/cleanup-image"

# dockerify the rootfs
echo "Doing Docker things to the root file system."
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
popd   # dev

# remove some files that we don't need here
rm -rf usr/share/man/*
rm -rf etc/hosts*
rm -rf etc/resolv.conf*
rm -rf etc/passwd*
rm -rf etc/shadow*
popd  # $TMP_ROOT

# move the fs from tmp to ${OUT}/
rm -rf "${DIR}/${OUT}/${ARCH}"
mkdir -p "${DIR}/${OUT}"
mv "${TMP_ROOT}" "${DIR}/${OUT}/${ARCH}"

echo "Root filesystem is now ready in ${DIR}/${OUT}/${ARCH}"
