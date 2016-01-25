docker-archlinux
====================
Minimal Arch Linux docker image with trustable, traceable & inspectable origin  

## Intro
I've been frustirated with the lack of transparency of the baseline containers that we often build our Docker images from. Often they come with some blurb about their origin (this container was build with [bla]) that is difficult to verify.
This project contains a script, `buildme.sh`, which uses a slightly modified Arch bootstrapping script from [this project](
https://github.com/tokland/arch-bootstrap) to create an Arch Linux root filesystem archive suitable for use in a Docker container.

The filesystem used in [the greyltc/archlinux container on the Docker registry](https://hub.docker.com/r/greyltc/archlinux) is in the tar.xz file in this repo. Feel free to inspect it to prove to yourself that it's safe before using it in your project!

## Usage
Get the trustable, AUTOMATED BUILD prebuilt image from [https://hub.docker.com/r/greyltc/archlinux](https://hub.docker.com/r/greyltc/archlinux):  
```
docker pull greyltc/archlinux
```  
or alternatively build it locally yourself from the source repository:  

1. **Install dependencies**  
Use your favorite Linux distro's package manager to install the following comands/packages: fakechroot, fakeroot, chroot, xz, coreutils, wget, sed, gawk, tar, gzip, git, docker, bash
1. **Clone the Dockerfile repo**  
`git clone https://github.com/greyltc/docker-archlinux.git`  
1. **Build the root file system archive**  
`cd docker-archlinux`  
`./buildme.sh # this generates a new root filesystem archive: archlinux.tar.xz`  
1. **Build your baseline Arch Linux docker image**  
`docker build -t archlinux .`  
1. **Profit.**
