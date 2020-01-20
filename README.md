# Reolink RLC-410-5MP IP camera

## Preamble
The Reolink RLC-410-5MP is a 2560x1920 pixel IP camera with infrared night vision, motion detection and PoE support.

![Camera casing](https://github.com/hn/reolink-camera/blob/master/reolink-rlc-410-5mp-case.jpg "Reolink RLC-410-5MP case")

## Hardware

The camera uses a `Novatek NV98515` SoC (MIPS 24KEc V5.5 architecture) with a `Omnivision OS05A10M` image
sensor. The firmware is stored on a 16 MiB `GD25Q127C` SPI NOR flash.

### Serial port

There is a `115200 8-N-1` serial port accessible via `J9`:

![Serial port](https://github.com/hn/reolink-camera/blob/master/reolink-rlc-410-5mp-serial.jpg "Reolink RLC-410-5MP serial port")

## Firmware

The firmware is based on Novatek's evaluation board (`U-Boot 2014.07`, `kernel 4.1.0` and a Linux system based on `Buildroot 2015.11.1-00003-gfd1edb1`). See [U-Boot bootloader](log-u-boot.txt) and [Linux misc](log-linux.txt) logfiles for more details.

It _seems_ that there is a µITRON-compatible eCos-RTOS running on CPU1, and Linux running on CPU2 (`-D_CPU1_UITRON -D_CPU2_LINUX`).

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

