---
title: Monitor and restart Kalliope via a led and a push button
date: 2017-02-24
tags:
- kalliope
- home_automation
---


## Introduction

Tonight, I wanted to play a bit with my old raspberry pi B+ that I wasn't using anymore.

I wanted to use this rpi to monitor the temperature inside my house, and to do so I had to buy a sensor and a small electronic kit. While the temperature thing is not ready (even though the sensor is already plugged - but that will be another blog post), I had fun with 2 other elements of the electronic kit: A led and a push button.

The idea was simple: having a red LED that goes on when Kalliope is not responding anymore and a push button to restart the whole thing when needed.

So that if kalliope crashes, the red light will indicate me quickly and if I'm too lazy to go to my laptop to check what happened, I can simply press the button to restart every processes.

## How

My setup is simple: I have 1 rpi with Kalliope installed on it, and another rpi with the component installed. I already have a lot working on the kalliope pi (kalliope and its API, mopidy and X with a touchscreen) so I used this other one.

What I did:

* Create a script on kalliope rpi that restart everything
* Create a script on the rpi B+ that starts / stops the led when needed
* Create a script on the rpi B+ that listen to the push button

## Installing the led and the button

I won't go in details here, I just followed some how to online and adapted to my needs. I invite you to do the same to setup your led and your button.

* [A how to for the led](https://thepihut.com/blogs/raspberry-pi-tutorials/27968772-turning-on-an-led-with-your-raspberry-pis-gpio-pins)
* [A how to for the button](http://razzpisampler.oreilly.com/ch07.html)
* I even throw here the [how to for my temperature sensor](https://thepihut.com/blogs/raspberry-pi-tutorials/27968772-turning-on-an-led-with-your-raspberry-pis-gpio-pins), because why not :)


## The scripts

### Restart script

[The restart script can be found here](https://github.com/bacardi55/kalliope-starter55/blob/master/script/restart.sh).

I manage kalliope and mopidy via the pi user because of some Pulseaudio issue, so that makes this script a bit ugly, but the idea is simple: kill running processes and restart them. Make sure this script is executable (```chmod +x restart.sh```) and where your user can access it.

### The led script

[The led script can be found here](https://github.com/bacardi55/kalliope-starter55/blob/master/script/is_kalliope_online.py).

* Try to access kalliope,. I choose to do it via the API. For now, it uses GET /synapses that is a bit heavy, but when [this branch](https://github.com/kalliope-project/kalliope/blob/audio_api/kalliope/core/RestAPI/FlaskAPI.py#L67) will get merged, it will be lighter via a simple GET / to get kalliope version
* If Kalliope is off, turn on LED, if kalliope is on, turn off led
* I also added a temporary file that contains previous status, so the script don't fire GPIO commands every minutes.
* Launch this script via cron task (I choose every 2 minutes, but that's your choice)

Use the -h option of the script for help about script arguments.


### The button script

This is the script that needs to be always running on rpi B+, so that when I push the button, it will fire the restart.sh via ssh.
*For this to work, the user from the rpiB+ needs to be able to connect over ssh without password (via ssh key)!*

The script itself can be [found here](https://github.com/bacardi55/kalliope-starter55/blob/master/script/emergency_button.py).

You need to have it running all the time, and for this, I created a [systemd service file that be found here](https://github.com/bacardi55/kalliope-starter55/blob/master/script/systemd/emergency-button.service), thanks to my friend rustx!

All you need to do is to put it in ```/etc/systemd/system/``` and enable it at boot:

```bash
  sudo systemctl enable emergency-button.service
```

Start it (```sudo service emergency-button start```) and check that everything is fine with the command ```sudo status emergency-button```

You should have something like this:

```bash
  ● emergency-button.service
     Loaded: loaded (/etc/systemd/system/emergency-button.service; enabled)
     Active: active (running) since ven. 2017-02-24 22:55:08 UTC; 6min ago
   Main PID: 8349 (emergency_butto)
     CGroup: /system.slice/emergency-button.service
             └─8349 /usr/bin/python /home/pi/scripts/emergency_button.py
```

And normally everything should go smoothly, and each time the red led is on, just press the button to restart the whole shebang!
