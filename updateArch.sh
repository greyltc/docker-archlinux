#!/usr/bin/env bash

# install reflector
pacman -S --noconfirm --needed reflector

# backup the old mirrorlist
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

# get the latest mirrorlist
curl https://www.archlinux.org/mirrorlist/all/ > /etc/pacman.d/mirrorlist

# use reflector to rank mirrors by speed
reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist

# remove reflector and its deps
pacman -Rs reflector --noconfirm --needed

# upgrade packages
pacman -Syyu --noconfirm --needed

