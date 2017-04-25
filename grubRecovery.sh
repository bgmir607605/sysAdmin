#!/bin/bash
sudo fdisk -l
echo "enter partName"
read partName
echo "start mount"
sudo mkdir /mnt/linux
sudo mount /dev/$partName /mnt/linux
sudo mount --bind /dev /mnt/linux/dev
sudo mount --bind /proc /mnt/linux/proc
echo "Enter in root mode:"
echo "grub-install /dev/$partName"
sudo chroot /mnt/linux
echo "start mount"
sudo umount /mnt/linux/dev
sudo umount /mnt/linux/proc
sudo umount /mnt/linux
echo "shutdown"
sudo shutdown now
