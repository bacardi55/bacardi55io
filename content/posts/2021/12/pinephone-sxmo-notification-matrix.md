---
title: "Send sxmo notifications to a matrix room"
date: 2021-12-11T02:00:00+02:00
tags:
- pinephone
- sxmo
- matrix
categories:
- linux phone
---

# Context

As many privacy focused people, one of my goal/dream is to have a fully opensource phone I can trust and run application I like and trust. One big step for me was to buy the [pinephone braveheart](https://wiki.pine64.org/index.php/PinePhone_v1.1_-_Braveheart) edition when it got out to start toying with it and see how it could someday become the my main driver.

I didn't spend much time on it in early 2021, but I've been looking into it a lot more lately as I'd love to be able to remove every blocker for when the [Pinephone Pro](https://wiki.pine64.org/wiki/PinePhone_Pro) is fully ready. And the awesome [sxmo](https://sxmo.org/) distribution made me want to use my Pinephone more. If you like minimalist and tiling WM, sxmo might be for you :].

I'll discuss in a later blog posts all the things I want for it, but I do have specific requirements as I know I'll still have 2 phones in the future. I'll keep my android phone as my "work" phone for which I do need proprietary software like the google suite. But having a personal phone I can use the rest of the time.

I'll explain more about the exact workflow later, but one of the point is the ability to share notifications between phones so I don't miss calls/texts or others while I have only one of the phones with me.

To do this, the basic idea was to have my a private matrix room with end to end encryption where a I could send notifications from either phone and read it on my laptop. I may talk about the matrix setup adventure later on but I really enjoy it so far.

The goal of this post is really around sending notifications from the Pinephone runing [sxmo](https://sxmo.org/) on the matrix room.

# Setup

I won't explain how to setup a matrix server or create matrix room in this post, so I assume you already have:
- 2 matrix users (your main account and a "bot" account for sharing notifications from your phone(s)). Eg: `user@matrix.homeserver` and `phone@matrix.homeserver`. Of course adapt to yours;
- 1 matrix private room, eg `private-room@matrix.homeserver` where both users are invited;
- A phone with sxmo installed.

## Sxmo configuration

The goals are simple:
- Manage an "away mode" to only share notification when "away" and avoid double notification (once for the event, once on matrix client), this means:
  - Send notification to the matrix room when away
  - Do the usual thing (vibrate) otherwise
- Be able to toggle the away mode from the script menu

### Matrix-Commander

First we need to install [matrix-commander](https://github.com/8go/matrix-commander), a CLI-based Matrix client.
To do so, ssh to your phone and install required libraries and clone the git repo:

```bash
sudo apk add libolm libolm-dev libffi-dev zlib-dev jpeg-dev python3-dev py3-pip
git clone https://github.com/8go/matrix-commander.git; cd matrix-commander
```

I didn't need the notification dependency (`dbus-python` and `notify2`), so I created a local copy of the requirements.txt file:

```bash
cp requirements.txt requirements.local
```

And removed `dbus-python` and `notify2` lines and then install the requirements and make the main file executable:

```bash
pip install -r requirements.local.txt
chmod +x matrix-commander.py
```

*Nota*: I may have forgotten a few dependency, if that's the case, the error message when running the `pip install …` command should be self explanatory to add the missing libraries.

You should definitely read the matrix-commander README to understand basic usage, but it should be as simple as:

```bash
# initial configuration:
python3 ./matrix-commander.py
```
And answer the question, by giving your matrix server url (`matrix.homeserver`), the phone username (`phone@matrix.homeserver`) and password, and the room to push message to. The room id can be found in the url and should start with `!` (not the display name of your room that start with `#`).

You'll need to validate the new device to ensure encryption will work. That will be done after sending the first message. You should have another validated client open and connected with your phone account.

If everything worked, you could test sending a message via:

```bash
./matrix-commander.py -m "test message"
```

Then, on your other matrix client, it will ask you to validate the new client. Use the validate by emoji option and use matrix-commander to validate:

```bash
./matrix-commander.py --verify
```

Now all should be good, but to be "cleaner", lets move ./matrix-commander file to a more standard place:

```bash
mkdir ~/.local/share/matrix-commander && mv -i store/ ~/.local/share/matrix-commander
mkdir ~/.config/matrix-commander/ && mv credentials.json ~/.config/matrix-commander/
```

You can try another time to send a message to ensure everything still works fine :). If that's the case, let's start working on sxmo scripts.

### sxmo scripts

Sxmo is awesome as it is very configurable with simple bash scripts and hooks <3.

#### Sxmo notifications hook

Sxmo has an "notification" hook that allow you to do things when receiving a notification. To do so, create a `$XDG_CONFIG_HOME/hooks/notification` file (usually `$XDG_CONFIG_HOME` is `~/.config/sxmo`).
The latest version of my notification hook can be found [here](https://gitlab.com/bacardi55/pinephone-sxmo/-/blob/main/hooks/notification).

The idea is simple, if the "away mode" is enabled, send the notification via matrix-commander, otherwise vibrate. The away mode is simply a file (in my case `$XDG_CONFIG_HOME/away_mode`). If the file content is `1`, away mode is enabled, if content is `0`, it is disabled.

Don't forget to make the file executable (`chmod +x hooks/notification`) :).

#### Sxmo menu integration

Now all we need is a way to enable/disable the away mode easily. For this, I created a `$XDG_CONFIG_HOME/userscripts` file. This file allow you to add new lines at the start of the `scripts` menu. The content is quite simple:

```
  Toggle Away Mode ^ 0 ^ /path/to/awaymode_toggle.sh
```

Basically, it adds a menu item in the "menu → scripts" menu at the start named `  Toggle Away Mode` that will start the `awaymode_toggle.sh` script.

The latest version of the script can be found [here](https://gitlab.com/bacardi55/pinephone-sxmo/-/blob/main/scripts55/awaymode_toggle.sh) but the basic idea is that it reads the content of the `$XDG_CONFIG_HOME/away_mode` file and will change `0` into `1` or `1` into `0`.

And that's it! Toggling the away mode will either make your phone behave like default by vibrating when receiving a notification and when activated, will not vibrate but share the notification to a signal room so that you can read it anywhere :).

# Conclusion

This is just the start of many scripts I believe, but at least now if I have only my android phone I won't miss anything from the Pinephone. I will now look into android notifications and the other blocker I have with the Pinephone. I'll try to write more about my experiences with it too on this blog soon.

All my Pinphone/Sxmo files can be found [on gitlab here](https://gitlab.com/bacardi55/pinephone-sxmo/)
