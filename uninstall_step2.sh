#!/bin/bash

if [ $UID -ne 0 ]; then
	echo "Superuser privileges are required to run this script."
	echo "e.g. \"sudo $0\""
	exit 1
fi

if [ -e "/boot/cmdline.bak" ]; then
	echo -e "Not clean! Maybe you need to run \"uninstall.sh\" first, continue?(Y/N)\c"
	read A
	if [[ $A == Y* ]] || [[ $A == y* ]]; then
		echo "Continued"
	else
		exit 0
	fi
fi

if [ -e "/etc/initramfs-tools/scripts/init-bottom/root-ro" ]; then
	echo "root-ro found, removing"
	rm /etc/initramfs-tools/scripts/init-bottom/root-ro
fi

if [ -e "/boot/config.bak" ]; then
	echo "config.bak found, recovering"
	mv /boot/config.bak /boot/config.txt
	update-initramfs -d -k `uname -r`
else
	update-initramfs -u
fi

echo "Done!"