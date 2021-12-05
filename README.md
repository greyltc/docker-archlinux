[![ci](https://github.com/greyltc/docker-archlinux/actions/workflows/ci.yml/badge.svg)](https://github.com/greyltc/docker-archlinux/actions/workflows/ci.yml)

docker-archlinux
====================
Minimal Arch Linux docker image with trustable, traceable & inspectable origin   

## Intro
This project contains a script, `build-root-tarxz.sh`, which uses a slightly modified Arch bootstrapping script from [this project](
https://github.com/tokland/arch-bootstrap) to create an Arch Linux root filesystem archive suitable for use in a Docker container.

The filesystem used in [the greyltc/archlinux container on the Docker registry](https://hub.docker.com/r/greyltc/archlinux) is in the tar.xz file in this repo. Feel free to inspect it to prove to yourself that it's safe before using it in your project!

## Usage
Get the trustable, AUTOMATED BUILD prebuilt image from [https://hub.docker.com/r/greyltc/archlinux](https://hub.docker.com/r/greyltc/archlinux):  
```bash
docker pull greyltc/archlinux
```  
or alternatively build it locally yourself from the source repository like this:

1. **Install dependencies**  
Use your favorite Linux distro's package manager to install the following commands/packages: fakechroot, fakeroot, chroot, xz, coreutils, wget, sed, gawk, tar, gzip, git, docker, bash, zstd
1. **Clone the Dockerfile repo**  
`git clone https://github.com/greyltc/docker-archlinux.git`  
1. **Build the root file system archive**  
`cd docker-archlinux`  
`./build-root-tarxz.sh # this generates a new root filesystem archive: archlinux.tar.xz`  
1. **Build your baseline Arch Linux docker image**  
`docker build -t archlinux .`  
1. **Profit.**

Once you have the image, you could take a look inside:
```bash
docker run -i -t greyltc/archlinux bash
```
