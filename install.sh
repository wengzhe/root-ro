#!/bin/bash

echo "Read-only Root-FS script got from niun/root-ro @ gist of github"
echo "Installation script by WZ"

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

if [ -e "/boot/cmdline.bak" ] && [ -e "/etc/initramfs-tools/scripts/init-bottom/root-ro" ]; then
    echo -e "Not clean! Maybe you need to uninstall first, continue?(Y/N)\c"
    read A
    if [[ $A == Y* ]] || [[ $A == y* ]]; then
        echo "Continued"
    else
        exit 0
    fi
fi

#checking initramfs
num=`find /boot -name 'init*' | wc -l`
echo "Checking initramfs"
if [ $num -lt 1 ]; then
	echo "Initramfs missing, building..."
	mkinitramfs -o /boot/init.gz
	if [ `cat /boot/config.txt | grep 'initramfs' | wc -l` -lt 1 ]; then
		echo "initramfs init.gz" >> /boot/config.txt
	fi
	echo "Reboot to make sure initramfs work well please"
	exit 0
fi
echo "Initramfs good"

echo "Installing script \"root-ro\""

cp root-ro /etc/initramfs-tools/scripts/init-bottom/root-ro
chmod 0755 /etc/initramfs-tools/scripts/init-bottom/root-ro

#add overlay to /etc/initramfs-tools/modules
if [ `cat /etc/initramfs-tools/modules | grep 'overlay' | wc -l` -lt 1 ]; then
	echo "overlay" >> /etc/initramfs-tools/modules
fi

#now we need to make sure there is an initramfs exist
echo "Updating initramfs"
mkinitramfs -o /boot/init.gz

echo "Ccript is installed, changing /boot/cmdline.txt"

echo "Backing up /boot/cmdline.txt to /boot/cmdline.bak"
cp /boot/cmdline.txt /boot/cmdline.bak

echo "Adding root-ro-driver=overlay to /boot/cmdline.txt"
bak=`cat /boot/cmdline.txt`
echo -e "root-ro-driver=overlay \c" > /boot/cmdline.txt
echo $bak >> /boot/cmdline.txt

#or we can use cmdline(string) in config.txt of Raspberry Pi instead of cmdline.txt

echo "Done! Reboot please"