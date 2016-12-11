#!/bin/bash

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
	update-initramfs -u
fi

echo "Done!"