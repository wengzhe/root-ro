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

for ((j = 0; j < $i; j++))
do
	[[ ${strlist[$j]} == run-level* ]] && echo "Found:\"${strlist[$j]}\"" && runlevel=${strlist[$j]}
done

if [[ -n "$runlevel" ]]; then
	str=${str/"$runlevel "/}
fi

if [[ -z "$config" ]]; then
	echo -e "Root-ro is enabled now!"
	echo -e "Disable it?(Y/N)\c"
	read A
	if [[ $A == Y* ]] || [[ $A == y* ]]; then
		str="disable-root-ro=true $str"
		echo "$str" > $filename

		echo -e "Change runlevel to 1?(Y/N)\c"
		read A
		if [[ $A == Y* ]] || [[ $A == y* ]]; then
			echo "run-level=1 $str" > $filename
		fi

		echo "Done! Reboot please"
	else
		echo "Nothing changed"
	fi
else
	echo -e "Root-ro is disabled now!"
	echo -e "Enable it?(Y/N)\c"
	read A
	if [[ $A == Y* ]] || [[ $A == y* ]]; then
		echo ${str/"$config "/} > $filename
		echo "Done! Reboot please"
	else
		echo "Nothing changed"
	fi
fi
