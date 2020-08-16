#!/bin/sh

# an example script that can be used with the ssd_script.sh on the sd card
# it overwrites the nginx config file and reloads nginx to pick up the changes

echo " adding updating nginx.conf"
cp /mnt/sda/script/nginx.conf /mnt/tmp/nginx.conf
echo " copied nginx.conf from /mnt/sda/script/nginx.conf to /mnt/tmp/nginx.conf"
/bin/nginx -s reload -c /mnt/tmp/nginx.conf -p /mnt/tmp/
echo " told nginx to reload config"
