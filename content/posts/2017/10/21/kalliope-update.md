---
title: Kalliope update
date: 2017-10-21
tags:
- kalliope
- blabla
---


Hello,

Quick blog post as I reinstall my [Kalliope](https://kalliope-project.github.io) setup that I quit for a while :)

First, the good news is that i'm impressed by the amount of work the team as done! If you haven't tried it yet for a while, I suggest you retry it now :]

From what I've seen so far:

A lot of performance improvement has been done and now it is faster than ever on a raspberry pi! And also a lot of bug fixes too where done :)

New feature concerns hardware improvement:

- LED
- Mute button:
- Sound sensibility (for the mic)

And lots of new features:

- Player modularity: you can select your own player instead of default one
- No voice via API: now, api call don't have to active audio response, so you can use kalliopé in a client / server configuration (very excited by that one !) :]
- Kalliope memory: Awesome feature to store data in memory for later reuse ! (only temp memory though!)
- New neurons has been developed too:
  - Neurotimer: So you can plan to launch other neuron at a specific time :) or even can use this to create a remember app via kalliopé (So my previous script is now useless)
  - MQTT neuron integration (as well as a signal to start a neuron via MQTT signal)
  - Mute neuron to pause kalliope from waking up

And other stuff too, check out the github page!

Now, I have started checking my neurons to see if they are still working. [Google agenda](https://github.com/bacardi55/kalliope-google-calendar), [Repeat](https://github.com/bacardi55/kalliope-repeat) and [System status](https://github.com/bacardi55/kalliope-system-status) are working fine.

[Web scrapper](https://github.com/bacardi55/kalliope-web-scraper) and [all orders](https://github.com/bacardi55/kalliope-list-available-orders) ones seem to be broken though… I'll check that soon.

I haven't checked the other yet but I'll do it soon too :)

My TODOs:

- Repair neurons
- Test the Mobile app via the API
- Repair my web app
- Redo the Kalliope CLI
- duckduckgo AI API neuron

++
