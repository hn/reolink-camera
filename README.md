# Reolink RLC-410-5MP IP camera

## Preamble
The Reolink RLC-410-5MP is a 2560x1920 pixel IP camera with infrared night vision, motion detection and PoE support.

![Camera casing](https://github.com/hn/reolink-camera/blob/master/reolink-rlc-410-5mp-case.jpg "Reolink RLC-410-5MP case")

## Hardware

The camera uses a `Novatek NV98515` SoC with a `Omnivision OS05A10M` image
sensor. The firmware is stored on a 16 MiB GD25Q127C SPI NOR flash.

## Firmware

The firmware is based on Novatek's reference board linux system (U-Boot 2014.07 and kernel 4.1.0).

## Serial port

There is a `115200 8-N-1` serial port accessible via `J9`:

![Serial port](https://github.com/hn/reolink-camera/blob/master/reolink-rlc-410-5mp-serial.jpg "Reolink RLC-410-5MP serial port")

