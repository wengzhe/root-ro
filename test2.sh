#!/bin/bash

#if [ $UID -ne 0 ]; then
#    echo "Superuser privileges are required to run this script."
#    echo "e.g. \"sudo $0\""
#    exit 1
#fi

filename="test.txt"

str=`cat $filename`

strlist=($str)
i=${#strlist[@]}

echo "Searching for configuration now"

for ((j = 0; j < $i; j++))
do
	[[ ${strlist[$j]} == disable-root-ro* ]] && echo "Found:\"${strlist[$j]}\"" && config=${strlist[$j]}
done

if [[ -z "$config" ]]; then
	echo -e "No configuration of disable-root-ro found!\nPlease install the Read-only Root-FS script first"
	exit 1
fi

echo -e "\nTrying to analyse..."
if [[ $config == *false ]]; then
	echo "Root-ro is enabled currently"
	set="disable-root-ro=true"
elif [[ $config == *true ]]; then
	echo "Root-ro is disabled currently"
	set="disable-root-ro=false"
else
	echo "failed: not true or false"
	set="disable-root-ro=false"
fi

echo -e "\nChange \"$config\" into \"$set\"?(Y/N)\c"

read A

if [[ $A == Y* ]] || [[ $A == y* ]]; then
	echo ${str/$config/$set} > $filename
	echo -e "Root-ro \c"
	([[ $set == *true ]] && echo "disabled!") || ([[ $set == *false ]] && echo "enabled!")
	echo "done! please reboot"
else
	echo "Nothing changed"
fi