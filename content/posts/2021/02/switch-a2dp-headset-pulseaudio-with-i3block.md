---
title: "Switch between A2dp and Headset pulseaudio profile with i3Blocks"
date: 2021-02-03T19:12:23+01:00
categories:
- laptop
- dev
description: A quick way to switch from A2dp to Headset pulseaudio profile for a bluetooth headset.
tags:
- i3blocks
- pulseaudio
- python
---

For the first "real" post of this year, I'll talk about a quick script I had to write to simplify my life with pulseaudio profile for bluetooth headset (namely A2DP and Headset_head_unit).

## Context

I've purchased my first nice bluetooth headset a couple of weeks ago. And while I really enjoy the freedom and great quality (as well as good noise cancelling), I found out that when connecting a bluetooth headset (via bluez library and the blueman UI), I had the possibility to use 2 different profiles: A2DP or Headset_head_unit…

I won't go here into the details of these 2 profiles as there are some info online, but the main thing is that in the end I have to mix between the two multiple times a day.

Why? Because the A2DP provides the best sound quality, but when in that mode, the microphone is not working… Whereas the Headset_head_unit profile provides a poor sound quality but at least the microphone works… Yeah I know… And because I do lots of calls during the day but still listen to music or videos often, I need to switch very quickly between the two modes (because yes, it is bad enough to not want to listen to music in the Headset_head_unit profile… It is fine for calls though.)

Anyway, the first few days, I was opening pavucontrol and then change the configuration as needed and keeping the pavucontrol screen open somewhere in a dedicated i3wm workspace. But I got very quickly fed up with that, so I thought about a way to improve this. Two things came 2 mind: a keyboard shorcut (via i3 keybindings) and a i3blocks block that would toggle the pulseaudio profile when clicked.

(For those who don't know [i3blocks](http://vivien.github.io/i3blocks/), it is very often used tool with [i3wm](https://i3wm.org) to display information in the status bar)

## i3blocks and a small python script

I created a small python script that can be used with i3blocks and that display nothing when the bluetooth headset is not connected. A green mic icone when connected in Headset_head_unit profile and a red headphones icon when connected in A2DP profile. You can see the icons on the [README page](https://gitlab.com/bacardi55/i55blocks/-/tree/main/bluetooth-headset-mode).

First, clone the repo (I've created public [gitlab](https://gitlab.com/bacardi55/i55blocks) and [github](https://github.com/bacardi55/i55blocks) repo for convenience)

```bash
git clone https://gitlab.com/bacardi55/i55blocks.git
```
or
```bash
git clone https://github.com/bacardi55/i55blocks.git
```

To use it, add in your ```~/.config/i3blocks/config``` file:
```INI
[bt_headset_mode]
command=$SCRIPT_DIR/bluetooth-headset-mode/bt_headset_mode
markup=pango
interval=10
bluetoothcard=<NameOfYourBluetoothCard>
```

<NameOfYourBluetoothCard> is the name of your bluetooth card that you can find using:

```bash
pactl list cards | grep bluez_card
```

You should get something like this:
```bash
Name: bluez_card.4C_87_5D_2B_62_1D
```

use the full name for the `bluetoothcard` variable.

Reload i3blocks and you should see either of the 2 icons if your headset is connected, nothing otherwise.

## Using a keyboard shortcut in i3wm

Now, as a quick alternative tip, if I don't have my hand on my mouse, I like having quick i3wm keybind to do the same only via keyboard.

To do so, open your i3wm config file (`~/.config/i3/config`) and add:

```config
bindsym $mod+Mod1+p exec --no-startup-id export BLOCK_BUTTON=true && export bluetoothcard="<NameOfYourBluetoothCard>" && /usr/bin/python3 /home/bacardi55/workspace/perso/i55blocks/bluetooth-headset-mode/bt_headset_mode
```

And voilà, you should reload i3 and be able to use the shortcut (remember to put the correct name of your bluetooth card) :)
