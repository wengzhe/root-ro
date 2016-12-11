#!/bin/sh

if [ -e "test.bak" ]; then
    echo "test.bak found, recovering"
    mv test.bak test.txt
else
    echo "backing to test.bak"
    cp test.txt test.bak
    bak=`cat test.txt`

    echo "root-ro-driver=overlay disable-root-ro=false \c" > test.txt
    echo $bak >> test.txt
fi