#!/bin/bash

IP=192.168.3.4
TOKEN=c1234cb7a0dd1cf	# grab this from your browser's web dev console

curl "http://$IP/cgi-bin/api.cgi?cmd=SetOsd&token=$TOKEN" --insecure -H 'Content-Type: application/json' \
 -H 'Cookie: ' --data-binary '[{"cmd":"SetOsd","action":0,"param":{"Osd":{"channel":0,"watermark":0}}}]'

# result: [ { "cmd" : "SetOsd", "code" : 0, "value" : { "rspCode" : 200 } } ]

