---
title: Entering the domotic game
date: 2017-03-15
tags:
- kallioper
- home_automation
- domoticz
---


## Introduction

So far, most of the things I do with Kalliope could be considered as not really domitic (maybe more domogeek ^^).

Indeed, so far I use Kalliope to:

- Get data from API ([Google calendar](https://github.com/bacardi55/google-calendar), [Google Maps](https://github.com/bacardi55/kalliope-gmaps), [Uber](https://github.com/bacardi55/kalliope-uber))
- Get [RSS feeds](https://github.com/kalliope-project/kalliope_neuron_rss_reader) info (lequipe.fr mainly)
- [Scrap web page](https://github.com/bacardi55/kalliope-web-scraper) to get content (Google news, TV program, Cinema program, joke of the day, …)
- Get Kalliope to reminds things using [a script](https://github.com/bacardi55/kalliope-starter55/blob/master/script/reminder.py) and the [repeat neuron](https://github.com/bacardi55/kalliope-repeat)
- [Play music](https://github.com/bacardi55/kalliope-mpd) via my [mopidy](http://mopidy.com/) server
- Play video on my [Kodi](https://kodi.tv/) server via [a script](https://github.com/bacardi55/kalliope-starter55/blob/master/script/find-episode.sh)

The last 2 items could be considered as domotic, but I consider them as media management, but the line is grey :)


## Domotic

### what for?

Usage are legions and I don't intend to describe all of them here, just the one I'm going to use. Bear in mind than I'm just starting so my knowledge is limited and the devices I have are not numerous :).

I have several ideas to start with, like managing internal sensors (temp, light, motion detector, …) or managing switches (Lamp, electric plug, …)

### How:

#### The protocol: Z-wave

But first, I needed to find the basic of all this: How to manage these devices from a central control point. I read online some documentation, about protocol and devices and finally end up choosing device compatible with the z-wave protocol, as there is the openzwave opensource lib that seems to work well. Main issue of Z-wave is that the company behind it are owner of the z-wave chip.

I let you read online additional info on z-wave if you wish, there are a lot about it.

#### The main controller: [Domoticz](https://domoticz.com/)

So I ended up buying a usb stick z-wave controller and a z-wave multi sensor (temp/hum, light, motion detection) to start poking at it. But I still needed an app to manage all the z-wave devices.

For this, 2 solutions:

- Create a neuron that leverage the openzwave python library
- Use a tool that manage domotic devices

I think that the simplest, yet most powerful approach was to choose the 2nd option, and choose a software that was exactly meant to manage domotic device. I could have choose several: [jeedom](https://www.jeedom.com), [openhab](http://www.openhab.org/), [Home-Assistant.io](Home-Assistant.io), …


I ended up choosing [Domoticz](https://domoticz.com/), very light and powerful app in C++ with a web app and a mobile app. It was very easy to install on an old rpiB+ and to setup my z-wave sensor.

It also provide [APIs](https://www.domoticz.com/wiki/Domoticz_API/JSON_URL%27s#Retrieve_status_of_specific_device) to do a lot of actions so that kalliope could send action :)

APIs provide options to (non exhaustive, go to their doc page for full API endpoints):

- Get device status (and value): Important for me to get metric from sensor
- Set on/off on device: I'll soon have a zwave electrig plug, and I want to be able to switch it on and off via kalliope
- Get / Set scene/groups state: Scene and groups are option in domoticz to regroup devices together (group mean all device has same state (on or off) and group state can be change. Scene has only one state, but devices can have different states).

That's the main I'll start poking at, in that order!


#### Kalliope integration

##### Pymoticz

I did find online an [old python code](https://github.com/EirikAskheim/pymoticz/network) to manage domoticz. I also found a more recent fork of it [here](https://github.com/wackoracoon/pymoticz) that worked well.

Only issue is that is was forcing the use of http and didn't allow https. So I [forked it](https://github.com/bacardi55/pymoticz) to add https support. There is [pull request here](https://github.com/wackoracoon/pymoticz/pull/1) to merge it.


##### Kalliope Neuron

As you would have guess, a neuron is coming up. You can find it in a draft mode [on github](https://github.com/bacardi55/kalliope-domoticz). For now, it is very limited but in development. It does include directly the pymoticz library so no manual addition needed there.

For now, you can only request data value from a device. So for example, I can retrieve the temperature and the light level from the sensor.

**Brain example**

```yaml
  ---
    - name: "domoticz-get-temp-living-room"
      signals:
        - order: "living room temperature"
      neurons:
        - domoticz:
            host: "{{domoticz_host}}"
            action: "get_device"
            device: "6"
            ssl_verify: "False"
            say_template: "Living temperature is {{devices[0]['Temp'] | safe}} degrees and humidity is {{devices[0]['Humidity'] | safe}} %"
    - name: "domoticz-get-lux-living-room"
      signals:
        - order: "brightness in living room"
      neurons:
        - domoticz:
            host: "{{domoticz_host}}"
            action: "get_device"
            device: "5"
            ssl_verify: "False"
            say_template: "Living room brightness is {{devices[0]['Data'] | safe}}"
```

## What's next

As I said above, there are a lot to be able to do: set on/off devices, get / set scenes and groups, … A lot of fun to have marrying Kalliopé and domoticz :)

Stay tuned!
