#!/bin/bash

if [ $UID -ne 0 ]; then
	echo "Superuser privileges are required to run this script."
	echo "e.g. \"sudo $0\""
	exit 1
fi

if [ -e "/boot/cmdline.bak" ]; then
	echo "cmdline.bak found, recovering"
	mv /boot/cmdline.bak /boot/cmdline.txt
fi

if [ -e "/etc/initramfs-tools/scripts/init-bottom/root-ro" ]; then
	rm /etc/initramfs-tools/scripts/init-bottom/root-ro
	update-initramfs -u
fi

echo "Done! Please reboot and run uninstall_step2.sh"