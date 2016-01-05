# Arch Linux baseline docker container
# Generated on Tue Jan  5 19:27:05 GMT 2016
# Read the following to learn how the root filesystem image was generated:
# https://github.com/l3iggs/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER l3iggs <l3iggs@live.com>

# copy in the previously generated file system
ADD archlinux.tar.xz /

# update mirrorlist and packages
ADD updateArch.sh /usr/sbin/updateArch.sh
RUN chmod +x /usr/sbin/updateArch.sh; updateArch.sh
