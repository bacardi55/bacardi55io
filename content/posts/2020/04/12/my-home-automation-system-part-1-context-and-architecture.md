---
title: Home Automation, part 1 - Context and Architecture
date: 2020-04-12T17:07:34+01:00
tags:
- homeautomation
- selfhosting
- raspberrypi
- nodered
- mosquitto
- domoticz
- zwave
categories:
- selfhosting
description: A description of my domotic setup based on nodered, domoticz, mqtt and docker
---

# Context

As previously said in my [homelab posts](), I've redone completely my home automation system as it became old and not necessary aligned with my usage… To avoid repeating myself (because I'm also very lazy^^), let me quote myself (that seems very narcissist of me…):

> On the home automation part, it became way too complicated, mostly because I was learning at the time and was building it little by little. I had a old rpi2 B with [domoticz](https://github.com/domoticz/domoticz), a rpi3 with [kalliope](https://kalliope-project.github.io/) and [nodered](https://nodered.org/), … For those reading my blog back then, you are familiar with the voice assistant [Kalliope](https://kalliope-project.github.io/) that was the brain of my home and I was actively participating. One thing though… I noticed that I don't like to talk to a software, that I prefer an easy to access interface (web, app, cli, …) to do the action I wanted… And that I was more into automation than voice control.

The goal of this post is to describe the constraints and the architecture choices for my home automation system. There will be follow up posts on the setup and then a series of posts related to the actual automation I put in place over time :).

# Automation ok... But for what?

I have multiple type of things running that I will describe in more details in future posts, like:

- **Home Alerts**: I have captors to alert me on things like water flood, smoke detection, open front door for too long, temperature too low, etc...
- **Intrusion alerts**: When not in the house, camera is running filming the front door as well as motion detector in rooms and I get an alert directly via chatbot that something is up. I also receive a video of the motion detected at the entry door (if any).
- **Recurring tasks**: Basic routines like wake up, go to sleep, leaving the house, etc...
- **Scenario**: Set of tasks that happen on specific occasion (leaving or arriving at home, going to sleep, etc...)
- **Devices control**: Lights via motion detection in specific rooms and other devices (Includes Sound system, media center, tv hdmi, etc...).
- **Control**: Global house control from a single web dashboard, accessible from a touchscreen in the living room or via any browser (mobile friendly)

# Constraints

I had more or less the following rules in mind when I started thinking about the new architecture:

1. Most important one: Needs to pass the WAF tests :) (for Wife Acceptance Factor[^1])
2. A powerful "brain" (= orchestrator) easy to configure but powerful enough to react and connect to anything
3. Works with [z-wave]() devices (As I had already a few of them: electric plugs, smoke and flood alarms, door sensor, buttons)
4. Lightweight communication (I was using http APIs calls before, but this was too heavy for IoT[^2])
5. Dashboard to control it via a touchscreen device in the living room (I already had the hardware)
6. Communication from outside only via chatbot
7. A multi room sound system
8. A music server, connected to the multi room system above.
9. A media center system for the TV in the living room.
10. A camera pointed to my front door for an alarm system
11. Reuse as much as possible my [home lab raspberrypi cluster](/categories/homelab/) and thus docker swarm.

That maybe a lot, but wait until you see the list of automation in place :D

# My Architecture choices

The TLDR; can be summarized in a simple visual:

![My Home Automation architecture](/images/pages/home-lab/architecture.jpg "My Home Automation architecture")

Ok, it may seems complicated for a home setup but it is not :). Let's take them piece by piece.

2. **Brain / Orchestrator**: I choose [nodered](https://nodered.org/) for this for multiple reasons. But I really like how simple it is to start creating the first flow (= automation recipe) just via drag & drop and some configuration :). But it is also very powerful and almost anything can be achieved (may require Javascript coding for some use cases though!). The community is quite active and software is evolving quite nicely! It also didn't hurt that there is a great node (= nodered module) to create nice dashboards (and thus manage nodered - the brain - with it)
3. **Zwave controller**: I was already using [domoticz](https://www.domoticz.com/wiki/Main_Page) for managing my zwave devices. I worked flawlessly for 2 years on an old rpi 2. I decided to move it to my docker swarm cluster but keep this as my zwave controller as it worked so well and is integrated with MQTT too (see 3.).
4. **Lightweight messaging**: [MQTT](https://fr.wikipedia.org/wiki/MQTT) is the best and main choice for this, and [Eclipe Mosquitto](https://mosquitto.org/) is the most common MQTT broker used.
5. **Dashboard**: As said in 1., Nodered provides this too :).
6. **Chatbot**: I was already using [Telegram](https://telegram.org) and don't see reasons to change yet. I wish I could create a Signal bot instead but it is not doable without a dedicated SIM and phone number. So I settle to creating my own dedicated [Telegram Bot](https://core.telegram.org/bots) to manage any communication from outside (and thus also limit the available commands available through telegram). More on this later! :)
7. **Multi room soud system**: As it is related and not really related to my home automation system, I kept my previous system in place based on [Snapcast](https://github.com/badaix/snapcast) but I have an item in [my kanboard](/posts/2020/04/03/manage-your-personal-project-todos-with-kanboard-and-docker-swarm/) to study if this is still the right solution (but to be honest, it works really well :)).
8. **Music server**: I'm using [mopidy](https://mopidy.com/) connected to my spotify account. It support [mpd](https://www.musicpd.org/), has a web UI and connect to spotify. Perfect for my needs :-).
9. **Media center**: [Kodi](https://kodi.tv) user for a long time, I didn't see any reasons to change yet, a bit like my sound system.
10. **Camera**: Fisheye Picamera on a raspberry pi 0, controlled via MQTT messages.
11. Nodered, Mosquitto and Domoticz will be installed on my homelab cluster (We'll see how in the next posts, especially for domoticz).


This should help understand the diagram above and this is basically it! The heart of my system is nodered, zwave devices are managed via domoticz and any communication between different system (including the picamera and cec bridge[^3]) is achieved via MQTT.

Because I'm going to stop now before entering the interesting (setup) and fun (automation) things, I'll leave here one of the screen of my dashboard, made with [nodered dashboard nodes](https://flows.nodered.org/node/node-red-dashboards://flows.nodered.org/node/node-red-dashboard):

![My Home Automation dashboard](/images/posts/2020/04/12/homeautomationp1/dashboard.png "My Home Automation dashboard")

I have this dashboard in place on a touchscreen in my living room to easily control the house from my couch :).

# Conclusion

That's it for now! I'll talk in the next posts on this series about the actual setup of the main components :). Later, I'll start posting about the different automation and tasks I've setup since!
Because it will be a series of ongoing blog posts, I've setup a dedicated [Home Automation page]()

So far, I have in mind for this set of blog posts:

- Context and Architecture choices (this post :)
- Initial setup part1: Nodered and MQTT
- Initial setup part2: Domoticz
- MultiRoom Sound system setup
- PiCamera managed via MQTT
- TV control via CEC

And of course, I'll write about the different automation flow that manage all this :).


[^1]: WAF: https://en.wikipedia.org/wiki/Wife_acceptance_factor
[^2]: https://en.wikipedia.org/wiki/Internet_of_thingss://en.wikipedia.org/wiki/Internet_of_things
[^3]: I will write a specific post about cec bridge, which is a great tool to command your tv via hdmi! https://github.com/michaelarnauts/cec-mqtt-bridges://github.com/michaelarnauts/cec-mqtt-bridge

*[IoT]: Internet of Things
