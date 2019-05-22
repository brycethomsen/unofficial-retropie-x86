#!/bin/bash


sudo apt-get update && \
sudo apt-get install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    vim \
    sudo
sudo apt-get autoremove nano
