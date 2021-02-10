---
title: "[DRAFT] Home Automation, part 5: Night and Morning routines with Nodered"
description: "Description of the automated flow at night and morning with Nodered as the center piece"
date: 2021-02-13T19:12:13+01:00
tags:
- homeautomation
- nodered
- domoticz
- raspberry pi
- snapcast
- mpd
categories:
- selfhosting
draft: true
---

## Context

In this post, I want to highlight some of the things I talked about in my [previous post listing all my home automation flows](/2021/02/06/home-automation-part-4-list-of-my-nodered-automation-flows/). And more specifically some of the routines and automation in place at night and morning (the 2 are linked).

## Night Routine

### Telegram chat

It all starts at 8pm at night with a simple question I receive via telegram from nodered asking me if I want to see what is schedule on TV tonight (I usually respond no, but in case I say yes, it will leverage the http crawler nodered flow I have to parse a site and bring me back results):


A couple of hours later, at 10pm, I receive another question on telegram asking me at what time I want to wake up tomorrow. I only receive this if the house is not in "vacation" mode.

I have some pre-programmed time to select (eg: 7am, 7:30am, 8am or 8:30am) that I can clicked easily to select the right time, or click on "other" to indicate manually a time to wake up.

Once the time is set, I'll be asked what type of music I want to listen in the morning. I have 2 very different playlists (one with only my favorite hiphop songs, the other one with classical music). The UI asks me also if I want to select manually an artist or a radio, but I haven't configure the flows in these cases as I normally will want just one of the 2 choices.

After deciding what music will be played, I'm asked if I'm going to bed. At that point, I usually wait to click yes only when I go to sleep. This will trigger the «Going to bed» scenario

![Incoming telegram chat at 8pm](/images/posts/2021/02/telegram-night.png)

The alarm setup flow is a bit messy and looks like this:

![Nodered Alarm flow](/images/posts/2021/02/nodered-alarm-setup.png)

All "link in" nodes mainly come from the bot flow that handle telegram inputs and outputs.

### «Going to bed» scenario

When clicking «Yes», the different switch will go off (lights, TV, …), music, if playing will stopped, same for any video running on kodi. The house switch to the «night mode» where only the frontdoor alerts stays on (as well as the usual smoke & water leak detection).

I also have a pi with a touch screen in the living room with the nodered dashboard that switch off (just the screen, not the pi) at night. The screen is turned back on when motion are detected at night in the living room (and no guest is in the living room, but more on the guest mode later :)).


That's it for the night routine, I then go to sleep and wait for the morning one :).

At a glance, the scenario looks like this in nodered:

![Nodered Go to bed flow](/images/posts/2021/02/nodered-gotobed.png)

## Morning routine

In the morning, at the time I asked at night, NodeRed will start playing the music only in my bedroom ([Remember I have a multiroom sound system](/2020/04/18/home-automation-part-3-multi-room-music-and-sound-system-with-mopidy-and-snapcast/)) with the playlist I wanted.

I will also at the same time receive a chat on telegram telling me to wake up and give me 2 options: either saying I'm up and stop the music, or snooze it for 10 minutes (I love too much using snooze in the morning…). If I snooze, then the next time (10min later), the sound will be louder and I will have the same options. If I don't respond to this, music continues.

Once I click on "I'm up", then I will get a quote of the day, the weather for the day and be asked if I want to read the news:

If I click on "yes", I will receive titles and links from newspaper websites' RSS feeds. On this example, we see feeds from the french newspaper "Le Monde".

![telegram morning](/images/posts/2021/02/telegram-morning.png)

This is how it is managed by Nodered:

![Nodered Alarm Wake Up](/images/posts/2021/02/nodered-alarm-wakeup.png)

↑ This is the wake up process at the time decided.

![Nodered Alarm Snooze](/images/posts/2021/02/nodered-alarm-snooze.png)

↑ This is how I manage the snooze part of the routine.

![Nodered Alarm Wake Up](/images/posts/2021/02/nodered-alarm-snapcast.png)

↑ This is the snapcast piece to manage sound in the right room and right sound level.


## Conclusion

I hope I managed to explain these routines clearly :)

Obviously, as I don't share the Nodered flows themselves, let me know if you have any questions.

