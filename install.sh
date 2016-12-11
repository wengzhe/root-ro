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

echo "installing script \"root-ro\""

cp root-ro /etc/initramfs-tools/scripts/init-bottom/root-ro
#/usr/share/initramfs-tools/scripts/init-bottom
chmod 0755 /etc/initramfs-tools/scripts/init-bottom/root-ro

#add overlay to /etc/initramfs-tools/modules
if [ `cat /etc/initramfs-tools/modules | grep 'overlay' | wc -l` -lt 1 ]; then
	echo "overlay" >> /etc/initramfs-tools/modules
fi

#now we need to make sure there is an initramfs exist
num=`find /boot -name 'init*' | wc -l`
echo "updating initramfs"
if [ $num -lt 1 ]; then
	update-initramfs -c -k `uname -r` -v
	if [ `cat /boot/config.txt | grep 'initramfs' | wc -l` -lt 1 ]; then
		echo "initramfs initrd.img-`uname -r`" >> /boot/config.txt
	fi
	#mkinitramfs -o /boot/initrd.img-`uname -r`
	#initramfs initrd.img-`uname -r` @ config.txt
	#initramfs initrd.img-4.4.22-v7+ 0x00f00000
else
	update-initramfs -u
fi

echo "script is installed, changing /boot/cmdline.txt"

echo "backup /boot/cmdline.txt to /boot/cmdline.bak"
cp /boot/cmdline.txt /boot/cmdline.bak

echo "adding root-ro-driver=overlay disable-root-ro=false to /boot/cmdline.txt"
bak=`cat /boot/cmdline.txt`
echo -e "root-ro-driver=overlay disable-root-ro=false \c" > /boot/cmdline.txt
#initrd=0xf00000,0x57BD38				#root=/dev/mmcblk0p2 rootfstype=ext4
echo $bak >> /boot/cmdline.txt

#or we can use cmdline(string) in config.txt of Raspberry Pi instead of cmdline.txt

echo "done! reboot please"