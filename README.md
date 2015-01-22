docker-archlinux
========================

This builds a new archlinux docker image from scratch.

Get the prebuilt docker image from here: https://registry.hub.docker.com/u/l3iggs/archlinux/

Or follow these instructions to build a baseline archlinux docker image yourself: 

1. Make sure you're running Arch Linux  
1. Install dependencies  
'''sudo pacman -Suy git expect arch-install-scripts docker'''
1. Clone this repo  
'''git clone https://github.com/l3iggs/docker-archlinux.git'''  
1. Run the buildit.sh script  
You'll be asked for your sudo password.  
'''cd docker-archlinux'''  
'''./buildit.sh'''  
1. Build your base docker image  
'''docker build -t archlinux .''' 
1. Profit

