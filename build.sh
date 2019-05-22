#!/bin/bash
set -x
# setup
mkdir -p $HOME/LIVE_BOOT

sudo debootstrap \
    --arch=i386 \
    --variant=minbase \
    stretch \
    $HOME/LIVE_BOOT/chroot \
    http://ftp.us.debian.org/debian/

cp -p chroot.sh $HOME/LIVE_BOOT/chroot/tmp/chroot.sh

sudo mount --bind /proc $HOME/LIVE_BOOT/chroot/proc
sudo mount --bind /dev $HOME/LIVE_BOOT/chroot/dev

sudo chroot $HOME/LIVE_BOOT/chroot /tmp/chroot.sh

sudo umount $HOME/LIVE_BOOT/chroot/proc
sudo umount $HOME/LIVE_BOOT/chroot/dev

mkdir -p $HOME/LIVE_BOOT/{scratch,image/live}

rm -f $HOME/LIVE_BOOT/image/live/filesystem.squashfs

sudo mksquashfs \
    $HOME/LIVE_BOOT/chroot \
    $HOME/LIVE_BOOT/image/live/filesystem.squashfs \
    -e boot

cp $HOME/LIVE_BOOT/chroot/boot/vmlinuz-* \
    $HOME/LIVE_BOOT/image/vmlinuz && \
cp $HOME/LIVE_BOOT/chroot/boot/initrd.img-* \
    $HOME/LIVE_BOOT/image/initrd

cat <<'EOF' >$HOME/LIVE_BOOT/scratch/grub.cfg

search --set=root --file /DEBIAN_CUSTOM

insmod all_video

set default="0"
set timeout=30

menuentry "Debian Live" {
    linux /vmlinuz boot=live quiet nomodeset
    initrd /initrd
}
EOF

touch $HOME/LIVE_BOOT/image/DEBIAN_CUSTOM

grub-mkstandalone \
    --format=i386-pc \
    --output=$HOME/LIVE_BOOT/scratch/core.img \
    --install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
    --modules="linux normal iso9660 biosdisk search" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$HOME/LIVE_BOOT/scratch/grub.cfg"

cat \
    /usr/lib/grub/i386-pc/cdboot.img \
    $HOME/LIVE_BOOT/scratch/core.img \
> $HOME/LIVE_BOOT/scratch/bios.img

xorriso \
    -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "DEBIAN_CUSTOM" \
    --grub2-boot-info \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    -eltorito-boot \
        boot/grub/bios.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog boot/grub/boot.cat \
    -output "${HOME}/LIVE_BOOT/debian-custom.iso" \
    -graft-points \
        "${HOME}/LIVE_BOOT/image" \
        /boot/grub/bios.img=$HOME/LIVE_BOOT/scratch/bios.img
