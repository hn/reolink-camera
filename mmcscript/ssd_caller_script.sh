#!/bin/sh

# This is the caller script that tries to start /mnt/sda/ssd_script.sh every 3 seconds until it suceeeds
# as the mmc doesn't seem to be mounted when the init scripts are run
SSDSCRIPT=/mnt/sda/script/ssd_script.sh
for i in $(seq 1 21); do 
    echo "Try number $i to start ${SSDSCRIPT}"
    nowstring=$(date)
    echo "At ${nowstring} the mount table is:"
    mount
    if [ -f "$SSDSCRIPT" ]; then
        echo "$SSDSCRIPT exists."
        chmod 0777 ${SSDSCRIPT}
        echo "Calling ${SSDSCRIPT}h"
        ${SSDSCRIPT} &
        echo "Successfully started ${SSDSCRIPT}, done"
        exit 0
    fi
    echo "$SSDSCRIPT does not exist, sleeping 3 secs"
    echo ""
    sleep 3
done
