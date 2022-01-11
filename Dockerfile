# Arch Linux baseline docker container
# Generated on Tue Jan 11 16:15:55 UTC 2022 using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in super minimal root filesystem archive
ADD https://github.com/greyltc/docker-archlinux/releases/download/v20220111.0.46/archlinux-x86_64.tar.xz

# perform initial container setup tasks
RUN provision-container

# this allows the system profile to be sourced at every shell
ENV ENV /etc/profile
