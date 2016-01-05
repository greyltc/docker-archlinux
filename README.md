docker-archlinux
====================
Minimal Arch Linux docker image with trustable, traceable & inspectable origin  

## Intro
This image is built through the use of the official Docker build script for Arch Linux containers which is maintained by the Docker team. Have a  look at the script here:
https://github.com/docker/docker/blob/master/contrib/mkimage-arch.sh  

The file system used in docker-archlinux is in the tar.xz file in this repo. Feel free to inspect it to prove to yourself that it's safe!

## Usage
Get the trustable, AUTOMATED BUILD prebuilt image from [https://registry.hub.docker.com/u/l3iggs/archlinux/](https://registry.hub.docker.com/u/l3iggs/archlinux/):  
```
docker pull l3iggs/archlinux
```  
or build it locally yourself from the source repository:  

1. **Make sure you're running Arch Linux**  
1. **Install dependencies**  
`sudo pacman -S --needed git expect arch-install-scripts docker`  
1. **Clone the Dockerfile repo**  
`git clone https://github.com/l3iggs/docker-archlinux.git`  
1. **Build the root file system archive**  
`cd docker-archlinux`  
`./buildme.sh #you'll be asked for your sudo password here`  
1. **Build your baseline Arch Linux docker image**  
`docker build -t archlinux .`  
1. **Profit.**
