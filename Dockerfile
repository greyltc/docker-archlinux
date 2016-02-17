# Arch Linux baseline docker container
# Generated on Wed Feb 17 00:02:01 GMT 2016 using code in this GitHub repo:
# https://github.com/greyltc/docker-archlinux
FROM scratch
MAINTAINER Grey Christoforo <grey@christoforo.net>

# copy in super minimal root filesystem archive
ADD archlinux.tar.xz /

# properly reinstall the bare minimum packages required for pacman, plus the filesystem package
# this list can be generated under Arch Linux by running:
# bash <(curl -L 'https://raw.githubusercontent.com/greyltc/arch-bootstrap/master/get-pacman-dependencies.sh')
#RUN ["/usr/bin/pacman", "--noconfirm", "-Sy", "--force", "coreutils", "bash", "grep", "gawk", "file", "tar", "sed", "acl", "archlinux-keyring", "attr", "bzip2", "curl", "e2fsprogs", "expat", "glibc", "gpgme", "keyutils", "krb5", "libarchive", "libassuan", "libgpg-error", "libidn", "libssh2", "lzo", "openssl", "pacman", "pacman-mirrorlist", "xz", "zlib", "filesystem"]

# perform initial container setup tasks
RUN setup-arch-docker-container

# this allows the system profile to be sourced at every shell
ENV ENV /etc/profile
