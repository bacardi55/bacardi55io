---
Title: "My i3wm screens configuration"
date: 2021-04-06T21:30:00+01:00
lang: en
---

A few days ago, I responded on a post in i3wm sub-reddit about my config to manage 3 screens with i3wm.

I thought it might be nice to more or less copy my response in a quick post here in case it is useful for anyone:

I have multiple screens configuration, depending on where I am. It could be either just my laptop screen when on the move, or using 2 screens at the office or 3 screens at home (2 external HDMI and my laptop screen).

To switch between screen configurations, I have a keybind that activate a screen mode:

```config
    # Screen Mode:
    set $mode_screen Screen Layout (l)aptop, (h)ome, (o)ffice (a)uto
    mode "$mode_screen" {
      # Only laptop:
      bindsym l exec --no-startup-id autorandr --load laptop, mode "default"
      # Only home (3 screens):
      bindsym h exec --no-startup-id autorandr --load home, mode "default"
      # Only Office (2 screens):
      bindsym o exec --no-startup-id autorandr --load office, mode "default"
      # Auto fallback:
      bindsym a exec --no-startup-id autorandr --change, mode "default"

      # back to normal: Enter or Escape
      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    bindsym $mod+Shift+p mode "$mode_screen"
```

To select the right screen setup quickly by pressing {l,h,o,a}.

I have 2 sets of workspace, the "perso" (marked "[P]") and the work related ones (marked "[W]"):

```config
    set $ws1  "1:[P] www"
    set $ws2  "2:[P] Term"
    set $ws3  "3:[P] Mail"
    set $ws4  "4:[P] IM"
    set $ws5  "5:[P] misc1"
    ...
    set $ws11  "11:[W] www"
    set $ws12  "12:[W] Slack"
    set $ws13  "13:[W] Misc1"
    set $ws14  "14:[W] Misc2"
    ...
```

To switch between workspaces, I use the same pattern for both. Perso workspace are switched using the windows key and the right number (on an azerty keyboard, hence the "ampersand" instead of "1"); work related workspaces are used using the windows and alt keys + the same number as above.

So to switch to the first {perso,work} workspace, I use the following keybinds:

```
    # switch to workspace
    # Perso workspace
    bindsym $mod+ampersand workspace $ws1
    […]
    # Work workspace
    bindsym $mod+Mod1+ampersand workspace $ws11
    […]
```

Also, I defined some rules to put specific workspaces on specific screens automatically:

```config
    # Display pref
    workspace $ws1 output DP-1
    workspace $ws2 output eDP-1
    workspace $ws3 output eDP-1
    workspace $ws4 output eDP-1
    ...
    workspace $ws11 output HDMI-2
    workspace $ws12 output eDP-1
    workspace $ws13 output HDMI-2
    workspace $ws14 output HDMI-2
    ...
```

If this is of any interest to some people, feel free to ask me to share more on my i3wm setup :)
