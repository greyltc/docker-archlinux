# Arch Linux baseline docker container
# Generated on Sun Jan 24 21:10:29 GMT 2016 from this specific GutHub repo and commit:
# https://github.com/greyltc/docker-archlinux/tree/db153677a2d177b91f6cc590ec9f208cbde6c5bb
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in root filesystem archive
ADD archlinux.tar.xz /

# perform initial container setup tasks
RUN setup-arch-docker-container
