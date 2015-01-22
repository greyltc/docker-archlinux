#!/bin/bash

cat > Dockerfile << EOF
# Arch Linux baseline docker container
# Generated on `date`
# Read the following to learn how the root filesystem image was generated:
# https://github.com/l3iggs/docker-archlinux/blob/master/README.md
FROM scratch
MAINTAINER l3iggs <l3iggs@live.com>
ADD archlinux.tar.xz /
EOF

curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch.sh > mkimage-arch.sh
chmod +x mkimage-arch.sh

sed -i 's/| docker import - archlinux/-af archlinux.tar.xz/g' mkimage-arch.sh
sed -i '/docker run -i -t archlinux echo Success./d' mkimage-arch.sh

curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch-pacman.conf > mkimage-arch-pacman.conf

su -c './mkimage-arch.sh'

rm mkimage-arch.sh
rm mkimage-arch-pacman.conf
