docker-archlinux-builder
========================

This builds a new archlinux docker image from scratch.

The following script was used to generate the Dockerfile and root file system image here:
```bash
#!/bin/bash

cat > Dockerfile << EOF
# Arch Linux base docker container
# Generated on `date`
FROM scratch
MAINTAINER l3iggs <l3iggs@live.com>
ADD archlinux.tar.xz /
EOF

curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch.sh > mkimage-arch.sh
chmod +x mkimage-arch.sh

#sed -i 's,tar --numeric-owner --xattrs --acls -C $ROOTFS -c . | docker import - archlinux,printf '\''n archlinux-%02d.tar\\n'\'' {2..100} | tar --numeric-owner --xattrs --acls -C $ROOTFS -c . -L 100M -f archlinux-01.tar 2>/dev/null,g' mkimage-arch.sh

sed -i 's/| docker import - archlinux/-af archlinux.tar.xz/g' mkimage-arch.sh
sed -i '/docker run -i -t archlinux echo Success./d' mkimage-arch.sh

curl https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch-pacman.conf > mkimage-arch-pacman.conf

su -c './mkimage-arch.sh'

rm mkimage-arch.sh
rm mkimage-arch-pacman.conf
```
