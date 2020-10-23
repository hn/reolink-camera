#!/bin/bash
#
# repack-reolink-rootfs.sh
#
# Repack Reolink camera rootfs
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


# RLC-410-5MP NOR flash layout
#     name                size            offset
#  7: rootfs              0x00840000      0x006e0000      0

# rootfs may not exceed size 0x00840000 = 8650752

MTDFILE=mtdblock6.bin		# dump on camera with 'cat /dev/mtdblock6 > /mnt/sda/mtdblock6.bin'
CONTRIB=./contrib
OUTDIR=rootfs
OUTFILE=mtdblock6-NEW.bin
FRSAVE=fakerootsave.$MTDFILE
NEWPASS=reolink

test -f $CONTRIB/dropbear || exit 1

rm -v $FRSAVE
rm -vrf $OUTDIR $OUTFILE

CPASS=$(echo $NEWPASS | mkpasswd -m des -s)
echo "DES-encrypted password is: $CPASS"

fakeroot -s $FRSAVE unsquashfs -d $OUTDIR $MTDFILE

FWYM=$(( $(head -n1 $OUTDIR/mnt/app/version_file | cut -d_ -f2 | cut -b1-4) + 0 ))
if [ $FWYM -ge 2007 ]; then
	FLASHOFFSET=0x620000
elif [ $FWYM -gt 1800 ]; then
	FLASHOFFSET=0x6e0000
else
	echo "Unknown or invalid firmware file version"
	exit 2
fi

fakeroot -i $FRSAVE -s $FRSAVE cp -v $CONTRIB/dropbear $OUTDIR/usr/sbin/
fakeroot -i $FRSAVE -s $FRSAVE cp -v $CONTRIB/S99dropbear $OUTDIR/etc/init.d/
fakeroot -i $FRSAVE -s $FRSAVE cp -v $CONTRIB/S99sdcardautorun $OUTDIR/etc/init.d/
fakeroot -i $FRSAVE -s $FRSAVE chown -v --reference=$OUTDIR/etc $OUTDIR/usr/sbin/dropbear $OUTDIR/etc/init.d/S99dropbear $OUTDIR/etc/init.d/S99sdcardautorun
for LINK in dbclient dropbearconvert dropbearkey scp ssh; do
	fakeroot -i $FRSAVE -s $FRSAVE ln -sv ../sbin/dropbear $OUTDIR/usr/bin/$LINK
	fakeroot -i $FRSAVE -s $FRSAVE chown -v -h --reference=$OUTDIR/etc $OUTDIR/usr/bin/$LINK
done
fakeroot -i $FRSAVE -s $FRSAVE chmod 0777 $OUTDIR/usr/sbin/dropbear $OUTDIR/etc/init.d/S99dropbear $OUTDIR/etc/init.d/S99sdcardautorun

# remove comment to set root password
#fakeroot -i $FRSAVE -s $FRSAVE perl -i -p -e "s/^(root:)/\${1}${CPASS}/p" $OUTDIR/etc/passwd

fakeroot -i $FRSAVE ls -l $OUTDIR/etc/init.d $OUTDIR/usr/sbin $OUTDIR/etc/passwd

fakeroot -i $FRSAVE mksquashfs $OUTDIR $OUTFILE -comp xz -b 262144 -noappend

unsquashfs -s $MTDFILE
unsquashfs -s $OUTFILE
ls -l $MTDFILE $OUTFILE

# align to erase size: "GD25Q127C with page size 256 Bytes, erase size 64 KiB, total 16 MiB"
OUTFILEASIZE=0x$(printf "%x" $((65536 * $(($(($(stat -c "%s" $OUTFILE) + 65535)) / 65536)))))
echo "$OUTFILE file size (65536-byte aligned): $OUTFILEASIZE"   

echo "Execute the following commands within u-boot:"
echo
echo "fatload mmc 0 0x1000000 mtdblock6-NEW.bin"
echo "sf erase $FLASHOFFSET $OUTFILEASIZE"
echo "sf write 0x1000000 $FLASHOFFSET $OUTFILEASIZE"
echo "reset"

echo

