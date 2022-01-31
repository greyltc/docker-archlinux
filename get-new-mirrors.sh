#!/bin/sh
set -e
set -u

echo "Finding the fastest Arch mirrors..."
curl --silent --get --url https://archlinux.org/mirrorlist/ --data "country=all" --data "use_mirror_status=on" --data "protocol=https" > /tmp/mirrorlist
sed 's/^#Server/Server/' --in-place /tmp/mirrorlist
rankmirrors --verbose -n 10 --max-time 3 /tmp/mirrorlist > /tmp/fastmirrorlist
rm /tmp/mirrorlist
echo "Fast mirror list found. Relocating list."
mv /tmp/fastmirrorlist /etc/pacman.d/mirrorlist
rm -rf /etc/pacman.d/mirrorlist.pacnew
pacman -Syy
echo "Mirrorlist updated."

