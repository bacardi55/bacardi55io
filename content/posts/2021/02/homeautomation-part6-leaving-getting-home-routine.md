---
title: "Home Automation, part 6: Leaving and Arriving home routine via NodeRed"
description: "Description of the automated flow when leaving and arriving at my flat"
date: 2021-02-28T23:59:59+01:00
tags:
- homeautomation
- nodered
- domoticz
- raspberry pi
categories:
- selfhosting
---

## Context

Following my previous posts about [my automation flows](/2021/02/06/home-automation-part-4-list-of-my-nodered-automation-flows/) and [my night and morning routines](/2021/02/22/home-automation-part-5-night-and-morning-routines-with-nodered/), in this post, I want to describe the two simple routines I have in place for when I leave my place or when I come back.

It is basically about managing devices and alarms when I leave or come back home.

The involved devices are:
- A raspberry pi 0W with a fisheye camera pointing at the door entry running [motion](https://motion-project.github.io/);
- Telegram on my phone;
- A z-wave door sensor;
- My [homelab](/pages/home-lab/) cluster with [NodeRed](https://nodered.org/), [Domoticz](https://www.domoticz.com/) and [Mosquitto](https://github.com/eclipse/mosquitto);

*Nota*: More devices will be used for the next post explaining all alarms in place.

## Routine description:

### Leaving Routine

When leaving my apartment, the following scenario runs:
- Wait 30s and:
  - Switch off lights and TV (if on);
  - Stop kodi media server and the multi room music system if playing;
  - Switch off the piscreen display.
- Wait 5min and:
  - Start entry door camera (motion);
  - Set "Away" mode (for alarms);
  - Send "good by" notification.

The NodeRed flow looks like this:

![NodeRed leaving flow](/images/posts/2021/02/nodered-leaving-flow.png)

I will describe in the next post the alarms themselves in place and how they work so I won't say much here except that NodeRed will send via MQTT a message. A custom python script run on the raspberry pi 0W with motion listen to this specific topic. Depending on the message, the script will start/stop motion and the camera. Stay tuned for more details.

You can read the [part 4](/2021/02/06/home-automation-part-4-list-of-my-nodered-automation-flows/#device-mgt) for details on managing the devices.

5min later, I will receive a message on Telegram if everything went well saying «Away mode activated! See you soon :)».


#### Starting the "leaving routine"

I used to have a Bluetooth beacon to detect if I was home or not but it died. Since then, I have a more manual process. When leaving the house, I have multiple options to start the "leaving home" scenario:
- On the touch piscreen, I can start the "leaving home" scenario (see [this post](/2021/02/06/home-automation-part-4-list-of-my-nodered-automation-flows/#dashboard) for a screenshot of the dashboard);
- By clicking on my "exit button" near the entry door. Unfortunately, this is the only unreliable z-wave device I have so I don't really use it as it doesn't work most of the time[^1];
- By clicking on the right button that my [multi button remote control](https://www.remotec.com.hk/zrc90);
- By sending a Telegram command (Allow me to enable it whenever I want).


### Arriving Routine

When arriving home, the following is done:
- Switching off the entry camera (stopping motion);
- Switch on piscreen display;
- Send me a welcome message on telegram (just to make sure that if anyone else know how to stop the alerts by saying I'm home, I still receive something on telegram);
- Change house mode from "away" to "home";

The NodeRed flow looks like this:

![NodeRed home flow](/images/posts/2021/02/nodered-arriving-flow.png)

Again, on the next post I'll talk about the different alerts mechanism in more details. But same as above, a message is sent via MQTT so that the motion service is stopped.


#### Starting the "arrived home routine"

As said above, I do not have Bluetooth detection anymore to see if I'm home or not. To start this scenario, I can:
- Click on a specific button of the remote control;
- Send a telegram message (eg: when in the elevator);
- Wait for the alert and indicate I'm home (read below).

The 3rd option is the one I'm using the most because when I get back home without starting the home routine ahead (which I never do since I don't do Bluetooth detection), it will starts an alert (because door has been opened while "away mode" activated, and because the entry door camera will detect motions).

Again, I will explain in details the alarm/alerts in place, but what you need to know here is that when the entry door is opened while in "away" mode, I will receive a message via telegram asking « Stop Alert », « Real Alert », « I am Home ».

More details later, but clicking on « I am Home » will simply start the "arriving home" scenario.

![Telegram Door Alert](/images/posts/2021/02/telegram-entrydoor-alert.png)

So when I arrive home, I usually use this.

[^1]: I use [this Fiboro button](https://www.fibaro.com/fr/products/the-button/). Unlike all other [Fibaro](https://www.fibaro.com/) devices that works flawlessly, this one just doesn't work properly. And seeing other comments online, I'm not the only one. Too bad for a device that is supposed to by used as an emergency button…
