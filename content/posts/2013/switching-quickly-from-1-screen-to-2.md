---
title: Switching quickly from 1 screen to 2
date: 2013-01-28
tags:
- xrand
- linux
- multiscreen
category:
description:
---


As I open to switch often between 1 and 2 screen (I use a laptop), I made a very little bash script based on xrandr to help me switch faster.

``` bash

    #!/bin/bash

    NB=`xrandr|grep " connected"|wc -l`

    if [ "$NB" -eq 2 ]; then
      xrandr --output VGA-0 --auto --left-of LVDS
      if [ "$1" = "off" ]; then
    	xrandr --output LVDS --off
      fi
    else
      xrandr --auto
    fi
```

I named my script dualscreen.


Now, I you just have to run dualscreen in a term (or in a launcher like dmenu or your kde/gnome launcher). Then the script will the detect if 1 or 2 screen are plugged and do what it need to do.








If you want to plug a second screen and switch off the screen of the laptop, you can run dualscreen off and there you go !


Of course you need to adapt the output name depending on your hardware. Just run randr in a terminal.


For example, here is what I have running xrandr:

``` bash

    Screen 0: minimum 320 x 200, current 1366 x 768, maximum 16384 x 16384
    LVDS connected 1366x768+0+0 (normal left inverted right x axis y axis) 0mm x 0mm
    1366x768       60.2*+
    1280x720       59.9
    1152x768       59.8
    1024x768       59.9
    800x600        59.9
    848x480        59.7
    720x480        59.7
    640x480        59.4
    DisplayPort-0 disconnected (normal left inverted right x axis y axis)
    HDMI-0 disconnected (normal left inverted right x axis y axis)
    VGA-0 disconnected (normal left inverted right x axis y axis)
```

This means that I have 4 outputs. The LVDS is my laptop output. Then, plug your screen and run the xrandr command again.
You'll see another output connected. This is the one you should use in the script.


Bonus:

If you are lucky enough that your computer send an acpi signal or something to detect that a screen is plugged, you can do it automatically.

Unfortunatly it's not the case with my current laptop so I don't know more ^^. Maybe someone can send me an email with the procedure :).
