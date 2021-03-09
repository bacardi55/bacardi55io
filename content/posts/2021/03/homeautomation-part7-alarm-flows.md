---
title: "Home Automation, part 7: Alarms and alerts flows with Nodered"
description: "Description of the automated flows for the different alerts"
date: 2021-03-09T01:02:13+01:00
tags:
- homeautomation
- nodered
- domoticz
- raspberry pi
- telegram
categories:
- selfhosting
---

## Context

Following my previous posts about [my automation flows](/2021/02/06/home-automation-part-4-list-of-my-nodered-automation-flows/), [my night and morning routines](/2021/02/22/home-automation-part-5-night-and-morning-routines-with-nodered/) and [my leaving and arriving home routines](/2021/02/28/home-automation-part-6-leaving-and-arriving-home-routine-via-nodered/), in this post, I want to describe the different alerts mechanism I have in place.

The involved devices are:
- A raspberry pi 0W with a fisheye camera pointing at the door entry running [motion](https://motion-project.github.io/) (but more on this in my next post);
- Zwave devices: Door sensor, Water leak dectector, Smoke detectors;
- My [homelab](/pages/home-lab/) cluster with [NodeRed](https://nodered.org/), [Domoticz](https://www.domoticz.com/) and [Mosquitto](https://github.com/eclipse/mosquitto);


## Alarms

### Always on detectors

#### Smoke and Water leaks

I have a few "always on" detectors. I use a water leak and a smoke detectors. They do ring very loud in case of water or smoke detected but also connect over zwave so that domoticz can receive information when an alert is raised by one of the devices. I've explained how [NodeRed listen to Domoticz MQTT message for all devices and republish this in a proper way](/2021/02/06/home-automation-part-4-list-of-my-nodered-automation-flows/#mqtt).

This is the smoke detector flow:

![NodeRed Smoke Flow](/images/posts/2021/03/nodered-smoke-flow.png)

As you can see, based on the message receive, I send a notification via telegram.

The Start Alert subflow looks like this:

![NodeRed Startalert Subflow](/images/posts/2021/03/nodered-startalert-flow.png)

The message indicates the alert, eg: "Alert: Water leak detected" or "Alert: Smoke detected". Then, like for [night / morning routines](/2021/02/28/home-automation-part-6-leaving-and-arriving-home-routine-via-nodered/), it asks me if this is a real alert or not. If I don't respond, it will tell me every 10min that the home is still under alerts.

If I say it is a real alert, then for now it does nothing except wishing me luck… Not very useful yet but I have some ideas to implement here.

This is the nodered flow that checks for unresolved alerts:

![NodeRed checks for alert every 10min](/images/posts/2021/03/nodered-alarm-check.png)

The rules here are just passing parameters to the alert to indicate it is a repeat and not a new alert. It means that the message will be different (eg: "Home is still under alert (`<reason of the alert>`), do something!").


The "show notification" subflow will just display the alert on NodeRed dashboard (so at least on my touch screen in the living room and any other place where the dashboard is loaded).

This is the water leak flow:

![NodeRed Water flow](/images/posts/2021/03/nodered-water-flow.png)

Same kind of alert/questions is sent for this one. You can notice in this case that the alert can stopped itself if the water leak indicates that everything is fine again.

The stop alert subflow looks like this:

![NodeRed Stop alert flow](/images/posts/2021/03/nodered-stopalert-flow.png)

Very simple, remove the alert and send back a message.

#### Entry Door

I also have an "always on" check on the entry door where I have a small z-wave device that checks if the door is closed or opened. When home, I will get an alert if a door has been opened for more than 2 minutes.

The flow looks like this:

![NodeRed Alarm Entry Door opened for 2min](/images/posts/2021/03/nodered-alarm-entry-door.png)

Basically start a counter that will wait for 2min. If nothing happened during this 2 minutes, then an message will be sent to my phone on telegram. If that's the case while in away mode, it will raise an alert too (see below).

If the door is closed faster than 2 minutes, the counter is stopped and nothing is sent.

### Away mode alerts

When in "Away" mode, I have the following running:
- Check if entry door is close;
- Check for movement in living room;
- Check for movement in office.
- Camera with motion detection pointing at the entry door;

The nodered flow for the first 3 ones looks like this (still based on the mqtt messages received[^1]):

![NodeRed Stop alert flow](/images/posts/2021/03/nodered-alarm-door-and-mvt.png)

You can notice that the entry door alert here is fired by motion and the camera, not the entry door (not the same MQTT topic). That is because the entry door is managed elsewhere, as shown in the picture above in the [entry door](#entry-door) flow.

Basically, when receiving a mqtt message indicating some movement in the office, the living room or at the entry door, if the mode is "away" then it will start an alert as well as send me a notification via telegram.

Same for the entry door, if it is open while in "Away" mode, I'll get a message on telegram and an alert will be raised.

I haven't program anything yet in case of emergency, but I'm thinking potentially of a message indicating their faces have been recorded and sent to a remote server as well as playing an alarm sound at maximum level in every room. But I didn't set it up yet.

A detailed post on managing the motion (on/off, captures, backups etc…)  will follow soon as it would make this post way too long :).


[^1]: See [this post](/2021/02/06/home-automation-part-4-list-of-my-nodered-automation-flows/#mqtt) for more details on mqtt management.
