# Arch Linux baseline docker container
# Generated on Tue Jan 19 14:04:50 GMT 2016
# Read the following to learn how the root filesystem image was generated:
# https://github.com/greyltc/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in the previously generated file system
ADD archlinux.tar.xz /

# update mirrorlist and packages
ADD updateArch.sh /usr/sbin/updateArch.sh
RUN chmod +x /usr/sbin/updateArch.sh; updateArch.sh
