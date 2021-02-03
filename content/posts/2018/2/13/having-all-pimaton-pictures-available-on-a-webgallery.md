---
title: Pimaton v0.0.4, introducing web features!
date: 2018-02-13T14:27:13+01:00
tags:
- pimaton
- sigal
- python
categories:
- dev
description: test
---

## Introduction

So as you know, [I'm building a photomaton app](/2018/01/12/introducing-my-new-project-pimaton-a-photobooth-app-for-raspberry-pi.html) for my sister in law's wedding. I've released the [v0.0.3](/2018/02/06/pimaton-is-now-installable-via-pip.html) not long ago and I think it's time for the [v0.0.4](https://github.com/bacardi55/pimaton/releases/tag/v0.0.4) to be released.

The goal of this version is to answer specific needs:
What I want for the evening, is for the photo to be synchronized online so everybody at the evening can go and watch the picture and download them if needed.

I didn't want to duplicate the wheel here so I look for a simple photo web gallery application. My choice went to [sigal](https://github.com/saimn/sigal), a static gallery generator, so I could do a simple script to automate the whole on the remote server.

Also, to simplify the process, I want to have a QR code displayed on the waiting screen (only for GUI) to link to the web gallery url.

Last thing I needed, is the ability after each "photoshoot" to have a link for the people who took the pictures to go to a web gallery with only the pictures taken of the group. So you can scan the QR code and go download the specific pictures.


So that's why the [v0.0.4](https://github.com/bacardi55/pimaton/releases/tag/v0.0.4) I'm adding web capabilities:
- Synchronize picture to a remote server (DONE)
- Display a QR code on waiting screen (DONE)
- Put a QR code on the generated file that link to each "run" of pimaton (DONE).


I've also decided to open a "pimaton" section on this blog (see menu at the top of the page) to create a full tutorial on how to create your photobooth from the hardware/setup to the creation of the box, with Pimaton installation and configuration in the middle.

It's still very early draft and needs a lot of work but [the setup of the gallery](/pimaton/part5-optional-webgallery.html) is the first "good" page of this new area of the blog. Hope it will help any of you (or me when i'll resetup everything for the D day) put your photobooth together :).

