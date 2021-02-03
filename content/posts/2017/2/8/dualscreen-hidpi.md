---
title: Manage dualscreen with HiDPI
date: 2017-02-08
tags:
- xrandr
- tips
---


My new Dell XPS 13 has a HiDPI touchscreen and when I plug a 2nd display (not HiDPI), the resolution is big and ugly.

Solution for this is using the --scale option of xrandr!

My script example (in this case, laptop screen is at the right of my external screen):

```bash
xrandr --output eDP1 --primary --mode 3200x1800 --pos 3840x192 --rotate normal --output DP1-1 --mode 1920x1080 --pos 0x0 --rotate normal --scale 2x2
```
