#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

if [ -e "/etc/initramfs-tools/scripts/init-bottom/root-ro" ]; then
    echo "root-ro found, removing"
    rm /etc/initramfs-tools/scripts/init-bottom/root-ro
    update-initramfs -u
fi

if [ -e "/boot/cmdline.bak" ]; then
    echo "cmdline.bak found, recovering"
    mv /boot/cmdline.bak /boot/cmdline.txt
fi

echo "done! please reboot"