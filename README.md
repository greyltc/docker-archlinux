[![Build Container](https://github.com/greyltc/docker-archlinux/actions/workflows/build_container.yml/badge.svg)](https://github.com/greyltc/docker-archlinux/actions/workflows/build_container.yml)

docker-archlinux
====================
Minimal Arch Linux docker image with trustable, traceable & inspectable origin   

## Intro
This project contains a script, `build-root.sh`, which uses a slightly modified Arch bootstrapping script from [this project](
https://github.com/tokland/arch-bootstrap) to create an Arch Linux root filesystem archive suitable for use in a Docker container.

The filesystem used in [the greyltc/archlinux container on the Docker registry](https://hub.docker.com/r/greyltc/archlinux) is an asset attached to each of the releases for this repo. Feel free to inspect it to prove to yourself that it's safe before using it in your project!

## Usage
Use docker to pull the latest trustable, AUTOMATED BUILD prebuilt image:  
```bash
docker pull ghcr.io/greyltc/archlinux
# from https://github.com/greyltc/docker-archlinux/pkgs/container/archlinux
```
or  
```bash
docker pull greyltc/archlinux
# from https://hub.docker.com/r/greyltc/archlinux
```
## Building
You can use docker to build this container yourself.
### From a release asset
You can fetch a docker build context from a release asset and use that to build the container.
1. **Build your baseline Arch Linux docker image**
    ```
    docker build --tag arch-localbuild https://github.com/greyltc/docker-archlinux/releases/download/v20221031.0.175/docker-archlinux-x86_64.tar.xz
    ```
1. **Inspect the container**
    ```
    docker run --interactive --tty arch-localbuild bash
    ```
### From scratch
You can use the scripts in this repo to build this container from scratch.
1. **Install dependencies**  
Use your favorite Linux distro's package manager to install the following commands/packages: fakechroot, fakeroot, chroot, xz, coreutils, wget, sed, gawk, tar, gzip, git, docker, bash, zstd
1. **Clone repo**  
    ```
    git clone https://github.com/greyltc/docker-archlinux.git
    cd docker-archlinux
    ```
1. **Make a build context**  
    ```
    ./build-root.sh x86_64 out
    ```
1. **Build your baseline Arch Linux docker image**
    ```
    docker build --tag arch-localbuild out/x86_64
    ```
1. **Inspect the container**
    ```
    docker run --interactive --tty arch-localbuild bash
    ```
