#!/bin/sh

# Starting this script from ssd card to allow runtime changes without re-flashing.
# It can used for all sorts of things, e.g. modifying nginx config, kill processes and
# replace them with other binaries from sd card

# please place this file on the mcc card, in a folder called scripts.
# during runtime it will be available as /mnt/sda/script/ssd_script.sh


echo "Starting ssd_script.sh from mmc card"

echo "  ssd_script.sh: Nothing to do today"
# add your code here

#example:
# echo " updating nginx.conf"
# /mnt/sda/script/nginx_update.sh

echo "Finished ssd_script.sh from mmc card"
