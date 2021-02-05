---
title: "Home Automation, part 3: List of my automation flows"
description: "A list of all my NodeRed flows that automate my life"
date: 2021-02-16T19:18:13+01:00
tags:
- homeautomation
- nodered
- domoticz
- raspberry pi
categories:
- selfhosting
---

Quick posts around the different automation flow I have setup so far. I'll do a couple of deep dive in separate posts for the most important one.

**Disclaimer**: I'm using a lot of `link in` and `link out` node to share info between flows and also subflows. They have clear names but sometimes it might not be easy to follow. If you have any questions or remarks, let me know :)

### Dashboard

The nodered flow to manage my nodered dashboard. The flow is quite big to provide multiple screen tabs, so I'll write a post about this later. In the meantime, I can show the main screen of my dashboard as of today:

![Nodered Dashboard](/images/posts/2021/02/nodered-dashboard.png)

### Scenarii

I'll write a dedicated post for these are they are the most interesting thing setup, but an overview of the scenarii is below:

- *Go To Bed*: What needs to happen when going to bed: switching off everything, setting up the morning alarm Clock
- *Leaving*: Switching everything off, setup the "empty house" mode and enable camera at entry and the alert system
- *Getting Home*: Switching off the camera and alerts, setup "full house" for automation to work
- *Wake Up*: My morning routine, including music to wake up and getting the news
- *Work mode*: A special mode when working for lights or other stuff


### Alerts

Managing all alerts:
Always on alert:
- Water leak sensor
- Smoke detector (I use the fibaro zwave smoke detector)
- Front door open for too long

When "empty house" mode is on:
- Frontend open detection
- Motion sensor in entry, living room or office


### Modes

- Manage house mode: empty, full, night
- Manage guest mode (If guests are staying in certain rooms, I want to stop some automation :)).

### Alarm Clock

Specific workspace for managing my morning alarm clock. I'll write an article about this specifically.

### Music

Integration with MPD server from my [mopidy server](), eg: play/pause/next/prev/…

Example of the toggle play/pause flow:

![Nodered Music Flow](/images/posts/2021/02/nodered-music-example.png)

### Snapcast

Integration with Snapcast: (un)mute or change volume on the different snapcast client, eg:

![Nodered Snapcast Flow](/images/posts/2021/02/nodered-snapcast-example.png)

### Device Mgt

This is where I manage the different devices: lights, kodi, tv, zwave remote, …

It looks like this (partial view):

![Nodered devices flow](/images/posts/2021/02/nodered-devices-example.png)

But the main idea of this flow is just to receive a command and then send it like it should (eg: via mqtt for domoticz device or api calls for to kodi for example), nothing fancy :).

### MQTT

It looks like this:

![MQTT nodered flow](/images/posts/2021/02/nodered-mqtt-flow.png)


Integration with MQTT. Transform MQTT output from Domoticz into something more useful, eg:

![MQTT Domoticz In](/images/posts/2021/02/nodered-mqtt-domoticz-in.png)

becomes

![MQTT Domoticz In](/images/posts/2021/02/nodered-mqtt-domoticz-out.png)

This is better for me as the output is cleaner and the topic more explicit following a naming convention like `home/<Room>/Device`. Plus I filter also what goes out so I dont' resend everything received by Domoticz, but only the info I want to act on.

I also check in there the battery level of the different devices and send an alert via telegram in case a device has a low battery (<15%).

*Don't mind the last "line" as it is to send debug information via telegram in some specific cases*

### Bot

A flow that allows me to interact with nodered via telegram chat. I'll talk about this in a dedicated posts as it would be too long in this "high level view" for this post.

To see the things I can do through the telegram chat, see the result from the `/help` command:

```
Available commands:
/alarm: Triger question for morning alarm clock;
/alert off: Stop alert mode;
/analysis or /status : Return setup information;
/analysis-mqtt or /status-mqtt : Return MQTT values;
/bedroom {on,off}: switch {on,off} the bedroom light;
/camera {on, off}: Start/Stop camera in entry;
/guest {office, bedroom, livingroom} {on, off}: (De-)Activate guest mode in {room};
/kanboard {Task}: Add {task} to Kanboard backlog in Triage project - Alias: /kb;
/kodi {play,pause,toggle}: Toggle play/pause;
/mode {night, away, full, night, dumb}: switch house mode;
/music {play, pause, toggle}: Play / Pause music;
/news: Retrieve the news from 'Le Monde';
/office {on,off}: switch {on,off} the office light;
/piscreen {on, off, reboot, halt}: Switch off screen on PisScreen, or reboot it or shut it down;
/scenario {bed, leaving, home, wakeup}: Start scenario - Alias: /s;
/snapshot: Take a picture of the entry and send it;
/tv {on,off}: switch {on,off} the tv;
/tvprogram: Get the tv program;
/work {on,off}: Work mode {on,off};
```

### APIs

Just managing a few API endpoints:
- 1 for receiving picture for my frontdoor camera (more on this later)
- 1 for receiving a call from [diun]() to alert me of new images for my docker containers (as explained earlier [here](/2020/05/05/receive-alerts-when-new-images-are-available-for-your-docker-swarm-cluster-with-diun/))

The flow for the diun API looks like this:

![Nodered API flow](/images/posts/2021/02/nodered-api-example.png)


### Kanboard

API integration with Kanboard. Mainly to send tasks to my triage project. I use it with the release detector (add task for each new release for me to remember to update the software) or to add task via my telegram bot integration.

### HTML Crawler

Crawl pages without RSS feed to extract content and send the response via telegram. I use this for example for getting the TV program at night during my evening scenario.

### Release Detector

Check new release on github for specific software. New release are pushed to the triage project on my kanboard for me to remember.

### Cron

Planned tasks at a specific time. Nothing interesting there because they are in reality part of the other flows.


This post is already long enough, I'll write about the more interesting flow in more details (scenario, alerts, …) in later posts, but in the meantime feel free to ping me with some questions :).
