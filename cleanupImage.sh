#!/usr/bin/env bash

# remove all cached package archives
yes | LC_ALL=en_US.UTF-8 pacman -Scc
#pacman --noconfirm -Scc

# remove all the manual files
rm -rf /usr/share/man/*

# clean tmp folders
rm -rf /tmp/*
rm -rf /var/tmp/*
