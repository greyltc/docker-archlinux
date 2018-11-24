#!/usr/bin/sh
set -e

# this might fail in the chroot during setup, so let's run it now to build the cache
ldconfig

# properly reinstall the bare minimum packages required for pacman, plus the filesystem and dash
# this list can be generated under Arch Linux by running:
# bash <(curl -L 'https://raw.githubusercontent.com/greyltc/arch-bootstrap/master/get-pacman-dependencies.sh')
pacman --noconfirm --noprogressbar -Sy --force coreutils bash grep gawk file tar sed acl archlinux-keyring attr bzip2 curl e2fsprogs expat glibc gpgme keyutils krb5 libarchive libassuan libgpg-error libidn2 libnghttp2 libpsl libssh2 libunistring lz4 openssl pacman pacman-mirrorlist xz zlib zstd filesystem dash

# space checking in the cotainer doesn't work; disable it
sed -i "s/^[[:space:]]*\(CheckSpace\)/#\1/" /etc/pacman.conf

# this stuff requires bash to run
cat << 'EOF' > /tmp/needs-bash
# these are packages from the base group that we specifically don't want in this image for various reasons
# taken from here: https://github.com/docker/docker/blob/master/contrib/mkimage-arch.sh
PKGIGNORE=(
    linux-firmware
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
BASE_PACKAGES="$(pacman -Sg base | sort -u | awk 'BEGIN {ORS=" "} {print $2}')"
IFS=' ' read -r -a BASE_ARRAY <<< "$BASE_PACKAGES"

# these are the packages in the base group minus the ones we're ignoring
PACKAGES=($(comm -13 <(printf '%s\n' "${PKGIGNORE[@]}" | LC_ALL=LC_COLLATE sort -d) <(printf '%s\n' "${BASE_ARRAY[@]}" | LC_ALL=LC_COLLATE sort -d)))

# install relevant packages from the base group
pacman -S --needed --noprogressbar --noconfirm "${PACKAGES[@]}"
EOF
bash /tmp/needs-bash
rm /tmp/needs-bash

# fix up some small details, contents here: https://raw.githubusercontent.com/greyltc/arch-bootstrap/master/fixDetails.sh
fix-details

# use reflector to rank the fastest mirrors
pacman -S --noconfirm --needed --noprogressbar reflector
reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman -Rs reflector --noconfirm

# need pacman-contrib for rankmirrors
pacman -S --noconfirm --needed --noprogressbar pacman-contrib rankmirrors

cat << 'EOF' > /sbin/get-new-mirrors
#!/usr/bin/env bash
set -e -u -o pipefail
echo "Finding the fastest Arch mirrors..."
curl "https://www.archlinux.org/mirrorlist/?country=all&protocol=https&ip_version=4&use_mirror_status=on" > /tmp/mirrorlist
sed -i 's/^#Server/Server/' /tmp/mirrorlist
rankmirrors -n 6 /tmp/mirrorlist > /tmp/fastmirrorlist
mv /tmp/fastmirrorlist /etc/pacman.d/mirrorlist
pacman -Syy
echo "Mirrorlist updated."
EOF
chmod +x /sbin/get-new-mirrors

# create the users & groups that systemd-sysusers.service would have
groupadd -g 3 sys
groupadd -g 8 mem
groupadd -g 11 ftp
groupadd -g 12 mail
groupadd -g 19 log
groupadd -g 25 smmsp
groupadd -g 26 proc
groupadd -g 50 games
groupadd -g 54 lock
groupadd -g 90 network
groupadd -g 94 floppy
groupadd -g 96 scanner
groupadd -g 98 power
groupadd -r daemon
groupadd -r adm
groupadd -r bin
groupadd -r wheel
groupadd -r kmem
groupadd -g 5 tty
groupadd -r utmp
groupadd -r audio
groupadd -r disk
groupadd -r input
groupadd -r kvm
groupadd -r lp
groupadd -r optical
groupadd -r render
groupadd -r storage
groupadd -r uucp
groupadd -r video
groupadd -r users

useradd -N -u 1 bin
usermod -a -G daemon bin
usermod -a -G sys bin
useradd -N -u 2 daemon
usermod -a -G adm daemon
usermod -a -G bin daemon
useradd -N -u 8 -d /var/spool/mail mail 
useradd -N -u 14 -d /srv/ftp ftp 
useradd -u 33 -d /srv/http http

# install zsh shell and use it as sh, also update all packages
# this allows us to source /etc/profile from every RUN command so that 
# PATH is always what we expect it to be by setting ENV=/etc/profile
# in the Dockerfile
pacman -Syyu --noconfirm --noprogressbar zsh
rm /usr/bin/sh
ln -s /usr/bin/zsh /usr/bin/sh

# setup gnupg
echo "keyserver hkp://keys.gnupg.net" >> /usr/share/gnupg/gpg-conf.skel
sed -i "s,#keyserver-options auto-key-retrieve,keyserver-options auto-key-retrieve,g" /usr/share/gnupg/gpg-conf.skel
mkdir -p /etc/skel/.gnupg
cp /usr/share/gnupg/gpg-conf.skel /etc/skel/.gnupg/gpg.conf

# copy over the skel files for the root user
cp -r $(find /etc/skel -name ".*") /root

# set the root user's password to blank
#echo "root:" | chpasswd -e

# do image size reducing things
cleanup-image
