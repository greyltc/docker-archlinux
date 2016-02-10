#!/usr/bin/env bash
set -o pipefail

# this fails in the chroot during setup, so let's run it now to build the cache
ldconfig

# populate keychain
pacman-key --init
pacman-key --populate archlinux

# reinstall the keyring because its install also failed in the chroot
pacman -S --force --noconfirm --noprogressbar archlinux-keyring

# install sed now because we're about to use it to modify pacman.conf
pacman -S --force --noconfirm --noprogressbar sed

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

# these are the packages in the base group minus the ones we're ignoring
PACKAGES=($(comm -13 <(printf '%s\n' "${PKGIGNORE[@]}" | LC_ALL=C sort) <(printf '%s\n' "${BASE_ARRAY[@]}" | LC_ALL=C sort)))

# install relevant packages from the base group
pacman -S --force --noprogressbar --noconfirm "${PACKAGES[@]}"

# cleanup the pacnews
#PACNEW=/etc/pacman.conf.pacnew bash -c 'mv $PACNEW ${PACNEW%.pacnew}'
#rm /etc/pacman.d/resolv.conf.pacnew
#rm /etc/pacman.d/mirrorlist.pacnew
#PACNEW=/etc/shadow.pacnew bash -c 'mv $PACNEW ${PACNEW%.pacnew}'
#PACNEW=/etc/passwd.pacnew bash -c 'mv $PACNEW ${PACNEW%.pacnew}'

# space checking in the cotainer doesn't work; disable it
sed -i "s/^[[:space:]]*\(CheckSpace\)/# \1/" /etc/pacman.conf

# set the timezone
ln -s /usr/share/zoneinfo/UTC /etc/localtime

# set the locale
LANGUAGE=en_US
TEXT_ENCODING=UTF-8
echo "${LANGUAGE}.${TEXT_ENCODING} ${TEXT_ENCODING}" >> /etc/locale.gen
echo LANG="${LANGUAGE}.${TEXT_ENCODING}" > /etc/locale.conf
locale-gen

# use reflector to rank the fastest mirrors
pacman -S --noconfirm --needed --noprogressbar reflector
rm /etc/pacman.d/mirrorlist
reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman -Rs reflector --noconfirm

# update all packages and cache
pacman -Syyu --noprogressbar --noconfirm

# install zsh shell and use it as sh
# this allows us to source /etc/profile from every RUN command so that 
# PATH is always what we expect it to be by setting ENV=/etc/profile
# in the Dockerfile
pacman -S --noconfirm --noprogressbar zsh
rm /usr/bin/sh
ln -s /usr/bin/zsh /usr/bin/sh

# fix TERM not being set
echo "export TERM=xterm" >> /etc/profile

# remove all cached package archives
paccache -r -k0

# setup gnupg
echo "keyserver hkp://keys.gnupg.net" >> /usr/share/gnupg/gpg-conf.skel
sed -i "s,#keyserver-options auto-key-retrieve,keyserver-options auto-key-retrieve,g" /usr/share/gnupg/gpg-conf.skel
mkdir -p /etc/skel/.gnupg
cp /usr/share/gnupg/gpg-conf.skel /etc/skel/.gnupg/gpg.conf
cp /usr/share/gnupg/dirmngr-conf.skel /etc/skel/.gnupg/dirmngr.conf

# copy over the skel files for the root user
cp -r /etc/skel/.[^.]* /root

# remove all the manual files
rm -rf /usr/share/man/*

# set the root user's password to blank
echo "root:" | chpasswd -e
