# Arch Linux baseline docker container
# Generated on Tue Feb  9 18:35:34 GMT 2016 using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in root filesystem archive
ADD archlinux.tar.xz /

# perform initial container setup tasks
RUN setup-arch-docker-container

# this allows the system profile to be sourced at every shell
ENV ENV /etc/profile
