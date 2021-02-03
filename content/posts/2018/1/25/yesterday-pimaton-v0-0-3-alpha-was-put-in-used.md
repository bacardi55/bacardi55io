---
title: Yesterday, Pimaton v0.0.3 (alpha) was put in used!
date: 2018-01-25
tags:
- pimaton
category: dev
---

So you might remember that I'm working on a photoboot application for raspberrypi, as detailed [here](https://bacardi55.org/2018/01/12/introducing-my-new-project-pimaton-a-photobooth-app-for-raspberry-pi.html).

Yesterday, I had friends over at my place, so I thought I might do a very small run of the application to actually test something closer to reality than my "developer tests".

I know that running a program over time might have impact, software (memory limit, bugs and crash, ...) or hardware (printer issue, connectivity, ...) so I thought do a first trial.

We didn't used it a lot (only 3 times over 3 hours, taking 18 pictures and printing 6 pages (2 copies each)).

The bad news is that we didn't try it intensively as we should have (but wedding is still very far away^^), but the good news is that it works almost flawlessly. At least we could start taking pictures whenever we want and the printer behaved correctly all night :).

Obviously, I found some small issues in the UI (like step 7/3 ^^) and missing element that I'll fix before tagging the MVP v0.0.3 (as well as some UI improvment as it is very ugly at the moment).

It should arrive soon, even though I'll probably won't be able to work on it before end of next week, as I'm travelling for work and don't want to take the pi with me (Or I might look into the possibility of emulating the pi and picamera and gpio on a virtual machine.)


[![Pimaton Dry Run pic]({{ "/assets/pimaton_dryrun_thumbnail.jpg" | absolute-url }})]({{ "/assets/pimaton_dryrun.jpg" | absolute-url }})


You can see above an example of the rendering (blank template so no text or icons printed with the thumbnails), don't worry, the picture are not blurry, I just don't like pictures of me on the internet :).


I'll update soon when v0.0.3 is stable and official :)

If you want to try the exact version of the code I ran yesterday, look at [this specific commit](https://git.bacardi55.org/bacardi55/pimaton/commit/0a3207fed81528cfbea56929ad0028940990461c)

For more information, you can read [the README](https://git.bacardi55.org/bacardi55/pimaton/src/master/README.md) that should always be up to date with the latest code version/
