#!/usr/bin/env bash
set -o pipefail

# this fails in the chroot during setup, so let's run it now to build the cache
ldconfig

# populate keychain
pacman-key --init
pacman-key --populate archlinux

# reinstall the keyring because its install also failed in the chroot
pacman -S --noconfirm archlinux-keyring

# install sed now because we're about to use it to modify pacman.conf
pacman -S --noconfirm sed

# cleanup some pacorig files
rm /etc/passwd.pacorig
rm /etc/resolv.conf.pacorig
rm /etc/shadow.pacorig
rm /etc/pacman.d/mirrorlist.pacorig
rm /etc/pacman.conf.pacorig

# space checking in the cotainer doesn't work; disable it
sed -i "s/^[[:space:]]*\(CheckSpace\)/# \1/" /etc/pacman.conf

# these are packages from the base group that we specifically don't want in this image for various reasons
# taken from here: https://github.com/docker/docker/blob/master/contrib/mkimage-arch.sh
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
rm /etc/pacman.d/mirrorlist
reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman -Rs reflector --noconfirm

# update all packages and cache
pacman -Syyu --noconfirm --needed

# install zsh shell and use it as sh
# this allows us to source /etc/profile from every RUN command so that 
# PATH is always what we expect it to be by setting ENV=/etc/profile
# in the Dockerfile
pacman -S --noconfirm zsh
rm /usr/bin/sh
ln -s /usr/bin/zsh /usr/bin/sh

# fix TERM not being set
echo "export TERM=xterm" >> /etc/profile

# remove all cached package archives
paccache -r -k0

# copy over the skel files for the root user
cp /etc/skel/.[^.]* /root

# setup gnupg
echo "keyserver hkp://pgp.mit.edu" >> /usr/share/gnupg/dirmngr-conf.skel
sed -i "s,#keyserver-options auto-key-retrieve,keyserver-options auto-key-retrieve,g" /usr/share/gnupg/gpg-conf.skel
gpg --refresh-keys

# remove all the manual files
rm -rf /usr/share/man/*
