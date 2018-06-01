#!/bin/bash

if [ `dpkg -l | grep "busybox" | wc -l` -lt 1 ]; then
	echo "Info: You need busybox first"
	echo "e.g. \"sudo apt-get install busybox\""
	exit 1
fi

if [ $UID -ne 0 ]; then
	echo "Superuser privileges are required to run this script."
	echo "e.g. \"sudo $0\""
	exit 1
fi

if [ `mount | awk '$3 == "/" {print $1}'` = "overlay" ]; then
	echo "Info: Found system in RO mode! No need to repair..."
	exit 0
fi

echo "Checking script \"root-ro\""
cd "$(dirname "${BASH_SOURCE-$0}")"
cp root-ro /etc/initramfs-tools/scripts/init-bottom/root-ro
chmod 0755 /etc/initramfs-tools/scripts/init-bottom/root-ro

#add overlay to /etc/initramfs-tools/modules
echo "Checking /etc/initramfs-tools/modules"
if [ `cat /etc/initramfs-tools/modules | grep 'overlay' | wc -l` -lt 1 ]; then
	echo "overlay" >> /etc/initramfs-tools/modules
fi

#now we need to make sure there is an initramfs exist
echo "Updating initramfs"
if [ `cat /boot/config.txt | grep 'initramfs' | wc -l` -lt 1 ]; then
	echo "No initramfs, making..."
	cp /boot/config.txt /boot/config.bak
	update-initramfs -c -k `uname -r` -v
	echo "initramfs initrd.img-`uname -r`" >> /boot/config.txt
else
	#check the kernel version
	echo "Initramfs exists, checking kernel version..."
	line=`cat /boot/config.txt | grep 'initramfs'`
	K_V=${line#*-}
	if [ "$K_V" == "`uname -r`" ]; then
		echo -e "Kernel version right, update initramfs?(Y/N)\c"
		read A
		if [[ $A == Y* ]] || [[ $A == y* ]]; then
			update-initramfs -u
		else
			echo "Not changed."
		fi
	else
		echo "Kernel version wrong, remaking..."
		cd /boot
		for k in `ls initrd.img-*`
		do
			K_V=${k#*-}
			update-initramfs -d -k $K_V
		done
		update-initramfs -c -k `uname -r` -v
		awk '$1 != "initramfs" {print $0}' < /boot/config.txt > /boot/config.txt.tmp
		mv /boot/config.txt.tmp /boot/config.txt
		echo "initramfs initrd.img-`uname -r`" >> /boot/config.txt
	fi
fi

echo "Checking /boot/cmdline.txt"

if [ `cat /boot/cmdline.txt | grep 'root-ro' | wc -l` -lt 1 ]; then
	if [ -ne "/boot/cmdline.bak" ]; then
		echo "Backing up /boot/cmdline.txt to /boot/cmdline.bak"
		cp /boot/cmdline.txt /boot/cmdline.bak
	fi

	echo "Adding root-ro-driver=overlay to /boot/cmdline.txt"
	bak=`cat /boot/cmdline.txt`
	echo -e "root-ro-driver=overlay \c" > /boot/cmdline.txt
	echo $bak >> /boot/cmdline.txt
fi

echo "Done! Reboot please"