docker-archlinux-builder
========================

This builds a new archlinux docker image from scratch.

The following script was used to generate this image:
```bash
#!/bin/bash

cat > Dockerfile << EOF
# Arch Linux base docker container
# Generated on `date`
FROM scratch
MAINTAINER l3iggs <l3iggs@live.com>
ADD archlinux.tar /
EOF

curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch.sh > mkimage-arch.sh
chmod +x mkimage-arch.sh
curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch-pacman.conf > mkimage-arch-pacman.conf

su -c './mkimage-arch.sh'

rm mkimage-arch.sh
rm mkimage-arch-pacman.conf

docker export $(docker ps -l -q) > archlinux.tar
docker build -t archlinux:`date +%Y.%m.%d` .
```
