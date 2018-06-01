#!/bin/bash

echo "Read-only Root-FS script got from niun/root-ro @ gist of github"
echo "Enable initramfs on Raspberry PI @ github.com/chesty/overlayroot"
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

echo "Installing script \"root-ro\""

cd "$(dirname "${BASH_SOURCE-$0}")"
cp root-ro /etc/initramfs-tools/scripts/init-bottom/root-ro
chmod 0755 /etc/initramfs-tools/scripts/init-bottom/root-ro

echo "Installing \"runlevel.sh\""
cp runlevel.sh /etc/runlevel.sh
chmod 0755 /etc/runlevel.sh

echo "Adding \"runlevel.sh\" to crontab"
PROGRAM=/etc/runlevel.sh
CRONTAB_CMD="@reboot $PROGRAM"
(crontab -l 2>/dev/null | grep -Fv $PROGRAM; echo "$CRONTAB_CMD") | crontab - 
COUNT=`crontab -l | grep $PROGRAM | grep -v "grep"|wc -l ` 
if [ $COUNT -lt 1 ]; then 
	echo "Fail to add crontab $PROGRAM"
fi

#add overlay to /etc/initramfs-tools/modules
echo "Modifying /etc/initramfs-tools/modules"
if [ `cat /etc/initramfs-tools/modules | grep 'overlay' | wc -l` -lt 1 ]; then
	echo "overlay" >> /etc/initramfs-tools/modules
fi

#now we need to make sure there is an initramfs exist
echo "Updating initramfs"
if [ `cat /boot/config.txt | grep 'initramfs' | wc -l` -lt 1 ]; then
	cp /boot/config.txt /boot/config.bak
	update-initramfs -c -k `uname -r` -v
	echo "initramfs initrd.img-`uname -r`" >> /boot/config.txt
else
	update-initramfs -u
fi

echo "Script is installed, changing /boot/cmdline.txt"

echo "Backing up /boot/cmdline.txt to /boot/cmdline.bak"
cp /boot/cmdline.txt /boot/cmdline.bak

echo "Adding root-ro-driver=overlay to /boot/cmdline.txt"
bak=`cat /boot/cmdline.txt`
echo -e "root-ro-driver=overlay \c" > /boot/cmdline.txt
echo $bak >> /boot/cmdline.txt

#or we can use cmdline(string) in config.txt of Raspberry Pi instead of cmdline.txt

echo "Done! Reboot please"