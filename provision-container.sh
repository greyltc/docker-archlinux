#!/bin/sh
set -e

# this might fail in the chroot during setup, so let's run it now to build the cache
ldconfig

# install/reinstall everything needed for a minimal Arch system
pacman --noconfirm --noprogressbar -Syyu --overwrite \* base pacman-contrib

# fix up some small details, contents here: https://raw.githubusercontent.com/greyltc/arch-bootstrap/master/fix-details.sh
fix-details

cat << 'EOF' > /sbin/get-new-mirrors
#!/usr/bin/env bash
set -e -u -o pipefail
echo "Finding the fastest Arch mirrors..."
curl --silent "https://archlinux.org/mirrorlist/?country=all&protocol=https&ip_version=4&use_mirror_status=on" > /tmp/mirrorlist
sed -i 's/^#Server/Server/' /tmp/mirrorlist
rankmirrors -n 6 /tmp/mirrorlist > /tmp/fastmirrorlist
mv /tmp/fastmirrorlist /etc/pacman.d/mirrorlist
pacman -Syy
echo "Mirrorlist updated."
EOF
chmod +x /sbin/get-new-mirrors
/sbin/get-new-mirrors

# install zsh shell and use it as sh, also update all packages
# this allows us to source /etc/profile from every RUN command so that 
# PATH is always what we expect it to be by setting ENV=/etc/profile
# in the Dockerfile
pacman -Syyu --noconfirm --noprogressbar zsh
ln -sfT zsh /usr/bin/sh

# setup gnupg
echo "keyserver hkp://keys.gnupg.net" >> /usr/share/gnupg/gpg-conf.skel
sed -i "s,#keyserver-options auto-key-retrieve,keyserver-options auto-key-retrieve,g" /usr/share/gnupg/gpg-conf.skel
mkdir -p /etc/skel/.gnupg
cp /usr/share/gnupg/gpg-conf.skel /etc/skel/.gnupg/gpg.conf

# copy over the skel files for the root user
cp -r $(find /etc/skel -name ".*") /root

# set the root user's password to blank
#echo "root:" | chpasswd -e

# lock root account
#passwd --lock root

# do image size reducing things
cleanup-image
