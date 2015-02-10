# Arch Linux baseline docker container
# Generated on Tue Feb 10 18:06:12 CET 2015
# Read the following to learn how the root filesystem image was generated:
# https://github.com/l3iggs/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER l3iggs <l3iggs@live.com>
ADD archlinux.tar.xz /
RUN pacman -Syyu --needed --noconfirm

# install, run and remove reflector all in one line to prevent extra layer size
RUN pacman -S --needed --noconfirm reflector; reflector --verbose -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist; pacman -Rs --noconfirm reflector
