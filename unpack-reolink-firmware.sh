#!/bin/bash
#
# unpack-reolink-firmware.sh
#
# Unpack Reolink camera rootfs from firmware dist file
#
# (C) 2019-2020 Hajo Noerenberg
#
#
# http://www.noerenberg.de/
# https://github.com/hn/reolink-camera
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3.0 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.
#

FIRMWARE=RLC-410-5MP_448_19061407
DLURL=https://reolink-storage.s3.amazonaws.com/website/firmware/20190614firmware
PAKFILE=IPC_51516M5M.448_19061407.RLC-410-5MP.OV05A10.5MP.REOLINK.pak

mkdir -pv $FIRMWARE
cd $FIRMWARE

echo "e67454a79bcd538fb96d7c8b8a742956  $FIRMWARE.zip" > $FIRMWARE.zip.md5
wget -nv -nc $DLURL/$FIRMWARE.zip

md5sum -c < $FIRMWARE.zip.md5
if [ $? -ne 0 ]; then
	echo "Error: $FIRMWARE.zip wrong checksum"
	exit 1
fi

test -f $PAKFILE || unzip $FIRMWARE.zip

#binwalk $PAKFILE

dd bs=5135401 skip=1 of=rootfs.bin if=$PAKFILE

test -d rootfs || unsquashfs -d rootfs rootfs.bin

ls rootfs

head rootfs/etc/firmware.info

