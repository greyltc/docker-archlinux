docker-archlinux
====================
Minimal Arch Linux docker image with trustable, traceable & inspectable origin  

## Usage
Get the trustable, AUTOMATED BUILD prebuilt image from [https://registry.hub.docker.com/u/l3iggs/archlinux/](https://registry.hub.docker.com/u/l3iggs/archlinux/):  
```
docker pull l3iggs/archlinux
```  
or build it locally yourself from the source repository:  

1. **Make sure you're running Arch Linux**  
1. **Install dependencies**  
`sudo pacman -Suy git expect arch-install-scripts docker`  
1. **Clone the Dockerfile repo**  
`git clone https://github.com/l3iggs/docker-archlinux.git`  
1. **Build the root file system archive**  
You'll be asked for your sudo password.  
`cd docker-archlinux`  
`./buildme.sh`  
1. **Build your baseline Arch Linux docker image**  
`docker build -t archlinux .`  
1. **Profit.**
