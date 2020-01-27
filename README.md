# Reolink RLC-410-5MP IP camera

## Preamble
The Reolink RLC-410-5MP is a 2560x1920 pixel IP camera with infrared night vision, motion detection and PoE support.
The hardware of the camera is quite good (well designed metal casing, multi-layer PCB with high soldering quality).
The software is bad (requiring Flash Player is not acceptable under any circumstances), but not as bad as other cameras I've seen before.
The camera [offers](https://reolink.com/wp-content/uploads/2017/01/Reolink-CGI-command-v1.61.pdf)
[RTMP](https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol) and [RTSP](https://en.wikipedia.org/wiki/Real_Time_Streaming_Protocol) video
streams. The RTSP stream suffers from various problems ("melting" and "smearing").

![Camera casing](reolink-rlc-410-5mp-case.jpg "Reolink RLC-410-5MP case")

## Hardware

The camera uses a [Novatek NV98515](http://www.novatek.com.tw/en-global/) SoC (MIPS 24KEc V5.5 architecture) with a [Omnivision OS05A10M](https://www.ovt.com/sensors/OS05A10) image sensor. The firmware is stored on a 16 MiB [GD25Q127C](https://www.gigadevice.com/datasheet/gd25q127c/) [SPI](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface) [NOR flash](https://en.wikipedia.org/wiki/Flash_memory#NOR_flash).

### Serial port

There is a `115200 8-N-1` serial port accessible via `J9`:

![Serial port](reolink-rlc-410-5mp-serial.jpg "Reolink RLC-410-5MP serial port")

## Firmware

The firmware is based on Novatek's NVT evaluation board SDK (`U-Boot 2014.07`, `kernel 4.1.0` and a Linux base system based on [Buildroot 2015.11.1-00003-gfd1edb1](https://buildroot.org/)). See [U-Boot bootloader](log-u-boot.txt) and [Linux misc](log-linux.txt) logfiles for more details.

There is a [µITRON](https://en.wikipedia.org/wiki/ITRON_project)-compatible [eCos-RTOS](https://en.wikipedia.org/wiki/ECos) running on CPU1 (probably doing the video encoding work), and Linux running on CPU2 (`-D_CPU1_UITRON -D_CPU2_LINUX`).

Novatek does not release _any_ information about their products. One can find
some brief [datasheet of the NT96650](https://dashcamtalk.com/cams/mobius/Novatek%20NT96650.pdf)
and some [discussion and tools at GoPrawn forum](https://www.goprawn.com/forum/novatek-cams).

### Unpack firmware

Firmware `RLC-410-5MP_448_19061407` is available from Reolink's support website. With [unpack-reolink-firmware.sh](unpack-reolink-firmware.sh) one can download the firmware file and extract the root filesystem:

```
$ ./unpack-reolink-firmware.sh 
mkdir: created directory 'RLC-410-5MP_448_19061407'
URL:https://reolink-storage.s3.amazonaws.com/website/firmware/20190614firmware/RLC-410-5MP_448_19061407.zip [9339002/9339002] -> "RLC-410-5MP_448_19061407.zip" [1]
RLC-410-5MP_448_19061407.zip: OK
Archive:  RLC-410-5MP_448_19061407.zip
  inflating: IPC_51516M5M.448_19061407.RLC-410-5MP.OV05A10.5MP.REOLINK.pak  
1+1 records in
1+1 records out
6242304 bytes (6.2 MB, 6.0 MiB) copied, 0.0104995 s, 595 MB/s
Parallel unsquashfs: Using 4 processors
551 inodes (622 blocks) to write

[===========================================================/] 622/622 100%

created 416 files
created 82 directories
created 135 symlinks
created 0 devices
created 0 fifos

bin  dev  etc  home  lib  linuxrc  mnt  proc  root  sbin  sys  tmp  usr  var

SDK_VER="NVT_NT96660_Linux_V0.4.8"
BUILDDATE="Tue Mar 1 18:25:28 CST 2016"
```

### Compile additional software

Download [Buildroot 2015.11.1](https://buildroot.org/downloads/buildroot-2015.11.1.tar.gz)
(I suggest to choose version 2015.11.1 as Novatek's SDK uses this as well).
Exec `make menuconfig`, select `Target options`, change `Target Architecture`
to `MIPS (little endian)` and `Target Architecture Variant` to `mips 32`.
Select `Target packages` in the main menu and select packages as needed.
Exit and `make`.

### Extend rootfs / add SSH daemon

Use `repack-reolink-rootfs.sh` to repack the rootfs on flash partition 6.
Dump squashfs with `cat /dev/mtdblock6 > /mnt/sda/mtdblock6.bin` to SD card
first. Then execute the script on your Linux workstation like this:

```
$ ./repack-reolink-rootfs.sh
551 inodes (622 blocks) to write
created 416 files
created 82 directories
created 135 symlinks
created 0 devices
created 0 fifos
'./contrib/dropbear' -> 'rootfs/usr/sbin/dropbear'
'./contrib/S99dropbear' -> 'rootfs/etc/init.d/S99dropbear'
changed ownership of 'rootfs/usr/sbin/dropbear' from root:root to 1004:1004
changed ownership of 'rootfs/etc/init.d/S99dropbear' from root:root to 1004:1004
Found a valid SQUASHFS 4:0 superblock on mtdblock6-NEW.bin.
Creation or last append time Mon Jan 27 16:42:00 2020
Filesystem size 6201.27 Kbytes (6.06 Mbytes)
Compression xz
Block size 262144
Filesystem is exportable via NFS
Inodes are compressed
Data is compressed
Fragments are compressed
Always-use-fragments option is not specified
Xattrs are compressed
Duplicates are removed
Number of fragments 23
Number of inodes 635
Number of ids 1
-rw-r--r-- 1 8650752 Jan 27 13:01 mtdblock6.bin
-rw-r--r-- 1 6352896 Jan 27 16:36 mtdblock6-NEW.bin
mtdblock6-NEW.bin file size (65536-byte aligned): 0x610000

Execute the following commands within u-boot:

fatload mmc 0 0x1000000 mtdblock6-NEW.bin
sf erase 0x6e0000 0x610000
sf write 0x1000000 0x6e0000 0x610000
reset
```

Then write the modified squashfs to NOR flash of your camera as shown in
script output:

```
NA51023> fatload mmc 0 0x1000000 mtdblock6-NEW.bin
reading mtdblock6-NEW.bin
6352896 bytes read in 0 ms
NA51023> sf erase 0x6e0000 0x610000
SF: 6356992 bytes @ 0x6e0000 Erased: OK
NA51023> sf write 0x1000000 0x6e0000 0x610000
SF: 6356992 bytes @ 0x6e0000 Written: OK
NA51023> reset
```

Enjoy logging in to your camera with SSH.

### Misc

With `get_sysinfo` debug information about the various video streams
is displayed, see [sample output](log-get_sysinfo.txt).

