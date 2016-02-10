# Arch Linux baseline docker container
# Generated on Wed Feb 10 17:57:30 GMT 2016 using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in root filesystem archive
ADD archlinux.tar.xz /

RUN ["/usr/bin/pacman", "--noconfirm", "-Sy", "--force", "coreutils", "bash", "grep", "gawk", "file", "tar", "sed", "acl", "archlinux-keyring", "attr", "bzip2", "curl", "e2fsprogs", "expat", "glibc", "gpgme", "keyutils", "krb5", "libarchive", "libassuan", "libgpg-error", "libidn", "libssh2", "lzo", "openssl", "pacman", "pacman-mirrorlist", "xz", "zlib"]

# perform initial container setup tasks
RUN setup-arch-docker-container

# this allows the system profile to be sourced at every shell
ENV ENV /etc/profile
