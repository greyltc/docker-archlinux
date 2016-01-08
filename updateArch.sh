#!/usr/bin/env bash

# install reflector
pacman -S --noconfirm --needed reflector

# use reflector to rank mirrors by speed
reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist

# remove reflector and its deps
pacman -Rs reflector --noconfirm --needed

# upgrade packages
pacman -Syyu --noconfirm --needed

