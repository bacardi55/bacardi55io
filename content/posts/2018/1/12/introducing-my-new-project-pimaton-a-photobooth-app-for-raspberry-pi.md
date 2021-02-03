---
title: "Introducing my new project: Pimaton a Photobooth app for raspberry pi"
date: 2018-01-12
tags:
- pimaton
category: dev
---

Hello everyone!

## Introduction

As said in my [previous post](/2018/01/10/2018-is-here.html), I offered for my help to setup a photo booth for the wedding of my sister in law. I proposed this as I've seen numerous project on reddit or elsewhere about DIY methods based on raspberry pi.

For the few readers of this blog, you must know my love for the Pi (I think now I have 1 pi2, 1pi0W and 6 pi3…) so I thought it would be great to not only do geeky stuff on them (code, hosting, …) but something that non geeky people will also enjoy using, with a bit of hardware (creating the box) too.

I look again on the internet and saw a a lot of great project like:
- [This one by Jake Barker](http://jackbarker.com.au/photo-booth/)
- [Boothy](https://github.com/zoroloco/boothy)
- [drumminhands](http://www.drumminhands.com/2014/06/15/raspberry-pi-photo-booth/)
- [Rpi photobooth](https://github.com/johols/RPi-photobooth)
- …

But while these are great project and good inspiration, it didn't do what I exactly wanted or I didn't like how it was done… So like a nerd, I starting hacking away to create a small PoV… PoV that will soon be published as 0.0.1 and opensourced (**Note** 0.0.1 won't be a fully usable project yet, but I like the principle of release early release often^^).

This post is about introducing and describing the project, other posts will come soon with the evolution of the code and the construction of the box as this is really work in progress so far.


## The idea of my photo booth

Requirements:

- A simple box with a screen that tell people to get pictures
- A big hardware button that people wouldn't miss even tired (hum hum) at 4am to start the process
- Pressing the button will start taking several pictures
- A UI that tell me when the pictures will be taken with countdown
- Print the taken pictures all in image like a photo booth (X time).
- Use a "template" system (base image) to personalized the background/texts of the printed pictures (eg: adding the names and the date at the bottom of the page or anything)
- Save all the picture for the newly wed
- Configurable system to be reused easily.
- Installable via pip for simplicity
- Maybe: Add a flash / lights in case of dark place

And if I have internet on the Pi, I also want to
- Sync pictures on a webserver (outside of the pi for performance reasons)
- Generate QR code to give a link so that people could go download the picture for themselves too (linked to above)
- Ask to receive pictures via email
- Maybe: A "end of party" action, where it zip all pictures and send a downloadable link to everyone.

And if using a touchscreen:
- Add a button to see a slideshow of the taken pictures
- Add an option for taking picture with or witout flash (if flash installed)


If possible, translatable too (I'm coding everything in english but I'd like to have it setup in French for this wedding)


## Where I am ?

I've done this very small roadmap:
- v0.0.1: Core features:
  - Taking X pictures and displaying them on a single compiled image (with a template image)
  - Configurable via a yaml file
  - Taken and pictures pictures share a unique key to retrieve the full group of pics easily later on.
- v0.0.2: Printing capabilities + hardware button input
- v0.0.3: UI implementations (Implement both option for CLI on GUI)
- v0.0.4: Web capabilities (if I decide to go that way)
- v0.0.5: Optional stuff

System will be fully usable starting v0.0.3.


As of now, I have done all the v0.0.1 items, including the main architecture of the app, with a configuration system and the core features around pictures. System will take X (configurable) pictures, will create thumbnails (size configurable). Then it will load the configured template if any (based image that might contains decorations) and paste the X image on as needed (depends on the number of pictures and the number of rows/columns configured).

So that's working pretty well :).

I've started working on the v0.0.2 this week end, now the system is able to print the generated image. I now want to add the hardware button as a configurable option (meaning you can either do it via the button or keep it via keyboard. on v0.0.3 it will also allow to choose GUI).


## The hardware ?

I think I'm going to do a more complete post on that when I'll talk about building the box but as of now, I have:

- a Raspberry Pi with raspbian installed.
- a PiCamera
- a 7" touchscreen and its box
- a Canon selphy CP 1200 to print the picture (connected via USB, not WiFi)
- a big arcade push button (not connected yet)


## WHERE IS THE FREAKING CODE ??

Well, it's not open yet, but will be soon, probably this week end. I will wait for the 0.0.3 to advertise more for it but the source code will be accessible to the couple of people reading these pages :).


That's it for now, but stay tune for news soon :)
