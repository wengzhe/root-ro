#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "Superuser privileges are required to run this script."
    echo "e.g. \"sudo $0\""
    exit 1
fi

filename="/boot/cmdline.txt"

str=`cat $filename`

strlist=($str)
i=${#strlist[@]}

echo "Searching for configuration now"

for ((j = 0; j < $i; j++))
do
	[[ ${strlist[$j]} == disable-root-ro* ]] && echo "Found:\"${strlist[$j]}\"" && config=${strlist[$j]}
done

if [[ -z "$config" ]]; then
	echo -e "Root-ro is enabled now!"
	echo -e "Disable it?(Y/N)\c"
	read A
	if [[ $A == Y* ]] || [[ $A == y* ]]; then
		echo "disable-root-ro=true $str" > $filename
	else
		echo "Nothing changed"
	fi
else
	echo -e "Root-ro is disabled now!"
	echo -e "Enable it?(Y/N)\c"
	read A
	if [[ $A == Y* ]] || [[ $A == y* ]]; then
		echo ${str/" $config "/" "} > $filename
	else
		echo "Nothing changed"
	fi
fi
