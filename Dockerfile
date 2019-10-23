# Arch Linux baseline docker container
# Generated on Wed Oct 23 18:55:36 UTC 2019 using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in super minimal root filesystem archive
ADD archlinux.tar.xz /

# perform initial container setup tasks
RUN setup-arch-docker-container

# this allows the system profile to be sourced at every shell
ENV ENV /etc/profile
