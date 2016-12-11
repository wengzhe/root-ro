#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

if [ -e "/etc/initramfs-tools/scripts/init-bottom/root-ro" ]; then
    echo "root-ro found, removing"
    rm /etc/initramfs-tools/scripts/init-bottom/root-ro
    mkinitramfs -o /boot/init.gz
fi

if [ -e "/boot/cmdline.bak" ]; then
    echo "cmdline.bak found, recovering"
    mv /boot/cmdline.bak /boot/cmdline.txt
fi

echo "Done! Please reboot"
echo "The initramfs still exists, you can manually remove it:"
echo "1. Delete the /boot/init.gz file"
echo "2. Remove the line \"initramfs init.gz\" in /boot/config.txt"