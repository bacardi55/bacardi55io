---
title: Xrandr command when (un)plugging a screen
date: 2016-12-09
tags:
- xrandr
- multiscreen
category:
description:
---


When I plug or un plug a screen on my laptop, I want my system to Automatically detect this change and switch from a single to dual screen setup (or the opposite when unplugging the screen).
Here is how I do it:

# Xrandr to switch screen layout

First, you need a script that automate the layout change based on the number of screens plugged in.
Here is the script I use:

```bash

    #!bin/sh

    # Adapt it to your hdmi or output card
    HDMI=`cat /sys/class/drm/card0-HDMI-A-1/status | grep -Ec "^connected"`
    if [ "$HDMI" -eq 1   ]; then
      /bin/sleep 2s;
      # Adapt with the output name and your user name
      su -c "DISPLAY=:0.0 /usr/bin/xrandr --output HDMI1 --mode 1920x1080 --pos 1920x0 --rotate normal --output DP1 --off --output eDP1 --mode 1920x1080 --pos 0x0 --rotate normal --output VIRTUAL1 --off" "bacardi55"
    else
      /bin/sleep 2s;
      # Adapt with the output name and your user name
      su -c "DISPLAY=:0.0 /usr/bin/xrandr --output HDMI1 --off --output VIRTUAL1 --off --output eDP1 --mode 1920x1080 --pos 0x0 --rotate normal" "bacardi55"
    fi
```

As you can see, commands are fired with my user and display specified in the command.
This is because this script will be fired by the system and not within an X session so DISPLAY needs to be precised.


### Launch the script when screen is (un)plugged

To achieve this, you'll need to create an udev rule.
Create the file ```/etc/udev/rules.d/99-monitor-hotplug.rules``` and insert the following:

```bash
    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="/path/to/xrandr/script.sh"
```



And here you go, script should be fired when monitor setup changes :)
