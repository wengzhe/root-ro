#!/bin/bash

if [ $UID -ne 0 ]; then
	echo "Superuser privileges are required to run this script."
	echo "e.g. \"sudo $0\""
	exit 1
fi

if [ `mount | awk '$3 == "/" {print $1}'` = "overlay" ]; then
	echo "Info: Found system in RO mode! disabling..."
	filename="/boot/cmdline.txt"
	str=`cat $filename`
	echo "disable-root-ro=true $str" > $filename
	echo "Done! Please reboot and rerun this script"
fi

echo "Info: System in RW mode now! Preparing to uninstall..."

if [ -e "/boot/cmdline.bak" ]; then
	echo "cmdline.bak found, recovering"
	mv /boot/cmdline.bak /boot/cmdline.txt
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

echo "Done! Please reboot"
