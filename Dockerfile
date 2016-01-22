# Arch Linux baseline docker container
# Generated on Fri Jan 22 14:34:23 GMT 2016
# Read the following to learn how the root filesystem image was generated:
# https://github.com/greyltc/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in the previously generated file system
ADD archlinux.tar.xz /

# update mirrorlist and packages
RUN date
RUN ls -alh /usr/bin
RUN ls -alh /bin
RUN file /usr/bin/bash
RUN file /usr/bin/updateArch.sh
RUN /usr/bin/updateArch.sh
