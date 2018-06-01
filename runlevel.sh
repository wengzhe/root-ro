#!/bin/bash

RUNLEVEL=
for CMD_PARAM in $(cat /proc/cmdline); do
    case ${CMD_PARAM} in
        run-level=*)
            RUNLEVEL=${CMD_PARAM#run-level=}
            ;;
    esac
done

if [ ! -z "${RUNLEVEL}" ]; then
    /sbin/telinit 3
    sleep 0.1
    echo "Changing runlevel to ${RUNLEVEL}"
    /sbin/telinit ${RUNLEVEL}
    sleep 3
    /usr/sbin/service ssh start
fi
