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
	echo "Disabled! Please reboot and re-run this script"
	exit 0
fi

echo "Info: System in RW mode now! Preparing to uninstall..."

if [ -e "/boot/cmdline.bak" ]; then
	echo "cmdline.bak found, recovering"
	filename="/boot/cmdline.txt"
	str=`cat $filename`
	strlist=($str)
	i=${#strlist[@]}
	for ((j = 0; j < $i; j++))
	do
		[[ ${strlist[$j]} == disable-root-ro* ]] && config=${strlist[$j]}
		[[ ${strlist[$j]} == root-ro-driver* ]] && config2=${strlist[$j]}
	done
	if [[ ! -z "$config" ]]; then
		str=${str/"$config "/}
	fi
	if [[ ! -z "$config2" ]]; then
		str=${str/"$config2 "/}
	fi
	echo $str > /boot/cmdline.bak
	mv /boot/cmdline.bak /boot/cmdline.txt
fi

if [ -e "/etc/initramfs-tools/scripts/init-bottom/root-ro" ]; then
	echo "root-ro found, removing"
	rm /etc/initramfs-tools/scripts/init-bottom/root-ro
fi

if [ `cat /etc/initramfs-tools/modules | grep 'overlay' | wc -l` -ge 1 ]; then
	awk '$1 != "overlay" {print $0}' < /etc/initramfs-tools/modules > /etc/initramfs-tools/modules.tmp
	mv /etc/initramfs-tools/modules.tmp /etc/initramfs-tools/modules
fi

if [ -e "/etc/runlevel.sh" ]; then
	echo "runlevel.sh found, removing"
	rm /etc/runlevel.sh
fi

(crontab -l 2>/dev/null | grep -Fv /etc/runlevel.sh) | crontab - 

if [ -e "/boot/config.bak" ]; then
	echo "config.bak found, recovering"
	awk '$1 != "initramfs" {print $0}' < /boot/config.txt > /boot/config.bak
	mv /boot/config.bak /boot/config.txt
	update-initramfs -d -k `uname -r`
else
	update-initramfs -u
fi

echo "Done! Please reboot"
