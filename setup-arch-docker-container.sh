#!/usr/bin/env bash
set -e

# this fails in the chroot during setup so let's run it now to build the cache
ldconfig

# populate keychain
pacman-key --init
pacman-key --populate archlinux

# these are packages from the base group that we specifically don't want in this image
# for various reasons, taken from here: https://github.com/docker/docker/blob/master/contrib/mkimage-arch.sh
PKGIGNORE=(
    cryptsetup
    device-mapper
    dhcpcd
    iproute2
    jfsutils
    linux
    lvm2
    man-db
    man-pages
    mdadm
    nano
    netctl
    openresolv
    pciutils
    pcmciautils
    reiserfsprogs
    s-nail
    systemd-sysvcompat
    usbutils
    vi
    xfsprogs
)

# these are the packages in the base group
BASE_PACKAGES="$(pacman -Sg base | awk 'BEGIN {ORS=" "} {print $2}')"
IFS=' ' read -r -a BASE_ARRAY <<< "$BASE_PACKAGES"

# these are the packages in the base group that we don't want to ignore
PACKAGES=($(comm -13 <(printf '%s\n' "${PKGIGNORE[@]}" | LC_ALL=C sort) <(printf '%s\n' "${BASE_ARRAY[@]}" | LC_ALL=C sort)))

# install relevant packages from the base group
pacman -S --noconfirm --needed "${PACKAGES[@]}"

# set the timezone
ln -s /usr/share/zoneinfo/UTC /etc/localtime

# set the locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# use reflector to rank the fastest mirrors
pacman -S --noconfirm --needed reflector
reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman -Rs reflector --noconfirm

# update all packages and cache
pacman -Syyu --noconfirm --needed

# remove all cached package archives
paccache -r -k0
