# Arch Linux baseline docker container
# Generated on Mon Dec 20 01:52:58 UTC 2021 using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in super minimal root filesystem archive
ADD https://github.com/greyltc/docker-archlinux/releases/download/v20211220.0.41/archlinux-x86_64.tar.xz

# perform initial container setup tasks
RUN provision-container

# this allows the system profile to be sourced at every shell
ENV ENV /etc/profile
