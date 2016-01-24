#!/usr/bin/env bash
set -ev
ldconfig

# populate keychain
pacman-key --init
pacman-key --populate archlinux
#pkill gpg-agent

# these are packages from the base group that we specifically don't want in this image
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

# stuff that needs comments
ln -s /usr/share/zoneinfo/UTC /etc/localtime
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
pacman -S --noconfirm --needed reflector
reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman -Rs reflector --noconfirm
pacman -Syyu --noconfirm --needed
paccache -r -k0
ls /var/cache/pacman/pkg
