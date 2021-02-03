---
title: Headless RaspberryPi installation
date: 2017-11-05
tags:
- raspberrypi
category:
---


*Nota*: This is more a quick note for myself to save somewhere how to do this more than a real blog post :)

The idea here is to install raspbian on a RaspberryPi without connecting the Pi to a screen and keyboard.

As I'm installing my new Pi (for a [MagicMirror²]() purpose, link to [Kalliope]() but more on this soon(ish) ^^)


Steps:

- Install raspbian on a micro SD card (as explain on the internet [here] or [here] for example) (I like to simply run the dd command like this: ```dd bs=4M if=/home/bacardi55/Téléchargements/2017-09-07-raspbian-stretch-lite.img of=/dev/mmcblk0 conv=fsync``` and then ```sync```)
- Mount the SD card boot partition and create an empty file named ssh (```touch /path/to/card/boot/ssh```).
- You can now unmount the boot partition and mount the root partition of the card
- Go to /path/to/your/card/etc/wpa_supplicant/ and edit the wpa_supplicant.conf file to configure your wifi.
- Add this at the end:

```
network={
  ssid="NameOfYourNetwork"
  psk="Your WIFI password"
}
```

- You can also change the country at the top of this file too if your not in GB :)
- Optional: If you want to loose time finding the IP of the new Pi on your network, you can edit the etc/hosts and etc/hostname files to give it a name. Normally, you should be able to ssh pi@theNameYouSet without knowing the IP :)
- Save and quit, then unmount the sd card root partition
- and voilà, connect to your pi via ssh pi@name (default is raspberry if you didn't change it and if you don't have other pi on your network) or via ssh pi@xxx.xxx.xxx.xxx :)

++
