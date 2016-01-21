# Arch Linux baseline docker container
# Generated on Thu Jan 21 17:31:45 GMT 2016
# Read the following to learn how the root filesystem image was generated:
# https://github.com/greyltc/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in the previously generated file system
ADD archlinux.tar.xz /

# update mirrorlist and packages
ADD updateArch.sh /usr/bin/updateArch.sh
RUN ["/usr/bin/bash", "$(date)"]
RUN echo usr/bin/updateArch.sh
#RUN updateArch.sh
