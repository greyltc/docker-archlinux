#!/bin/sh
set -e
set -u

echo "Finding the fastest Arch mirrors..."
pacman -Syy pacman-contrib curl --needed --noprogressbar --noconfirm
curl --silent --get --url https://archlinux.org/mirrorlist/ --data "country=all" --data "use_mirror_status=on" --data "protocol=https" > /tmp/mirrorlist
sed 's/^#Server/Server/' --in-place /tmp/mirrorlist
sed '/^##/d' --in-place /tmp/mirrorlist
rankmirrors --verbose -n 10 --max-time 3 /tmp/mirrorlist > /tmp/fastmirrorlist
rm /tmp/mirrorlist
echo "Fast mirror list found. Relocating list."
mv /tmp/fastmirrorlist /etc/pacman.d/mirrorlist
echo 'Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
awk '!seen[$0]++' /etc/pacman.d/mirrorlist
rm -rf /etc/pacman.d/mirrorlist.pacnew
pacman -Syy
echo "Mirrorlist updated to be:"
cat /etc/pacman.d/mirrorlist
