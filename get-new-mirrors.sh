#!/bin/sh
set -e
set -u

echo "Fetching new list of Arch mirrors..."
pacman --sync --refresh --refresh --needed --noprogressbar --noconfirm pacman-contrib curl >/dev/null 2>&1
curl --silent --get --url https://archlinux.org/mirrorlist/ --data "country=all" --data "use_mirror_status=on" --data "protocol=https" > /tmp/mirrorlist
sed 's/^#Server/Server/' --in-place /tmp/mirrorlist
sed '/^##/d' --in-place /tmp/mirrorlist

echo "Testing mirror speeds to find the fastest"
rankmirrors -n 10 --max-time 3 /tmp/mirrorlist > /tmp/fastmirrorlist
rm /tmp/mirrorlist
echo "Fast mirror list found"

echo 'Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch' >> /tmp/fastmirrorlist
awk '!seen[$0]++' /tmp/fastmirrorlist > /tmp/fastmirrorlist_unique_global
mv -vf /tmp/fastmirrorlist_unique_global /etc/pacman.d/mirrorlist
rm -rf /etc/pacman.d/mirrorlist.pacnew
pacman --sync --refresh --refresh

echo "The mirror list is now:"
cat /etc/pacman.d/mirrorlist
