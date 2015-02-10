# Arch Linux baseline docker container
# Generated on Wed Feb  4 10:46:50 CET 2015
# Read the following to learn how the root filesystem image was generated:
# https://github.com/l3iggs/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER l3iggs <l3iggs@live.com>
ADD archlinux.tar.xz /
RUN pacman -Syyu --needed --noconfirm
RUN pacman -S --needed --noconfirm reflector
RUN reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
