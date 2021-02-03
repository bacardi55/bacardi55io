---
title: Pimaton is now installable via pip!
date: 2018-02-06
tags:
- pimaton
- pip
- python
---


Yesterday was a small step for me entering the world of python packaging :)

As you've read before [I've decided to create a photobooth application for raspberrypi](/2018/01/12/introducing-my-new-project-pimaton-a-photobooth-app-for-raspberry-pi.html) for a wedding in August. Last time, I posted [some pictures of the pimaton in action](/2018/01/25/yesterday-pimaton-v0-0-3-alpha-was-put-in-used.html) during an evening with a friend.

Since the code seems stable and usable (all MVP features are done but one: the GPIO button), I decided to follow my beloved "release early, release often" principle and create a pip package so Pimaton can be installed easily on a raspberrypi.

I won't spend time on how I created the package, as there is plenty of documentation about it online already, and the process is pretty straight forward :). The important thing is that it is now possible to boot a raspbian on a pi and install pimaton in 2 minutes. The package page is [here](https://pypi.python.org/pypi/pimaton )

Click on the image below to see a quick gif of the GUI (**NOTA**: The camera stream is not shown here as PiCamera handle it on its own above X, check the video to see it fully. And the print option is disabled):

![Pimaton UI gif](/images/posts/pimaton_gui_thumbnail.gif")

You can see it working on quick video here:
{{< youtube HJ43O-nPQzw >}}

## Installation

Now pimaton can be installed as simply as:

```bash
# Install dependencies:
sudo apt install python-pip libjpeg-dev
pip install -U pip
# To enable GUI:
sudo apt install python-tk python-pil.imagetk
pip install pimaton
```

Then, duplicate the default config file to start modifying it:
```bash
cp /usr/local/lib/python2.7/dist-packages/pimaton/assets/default_config.yaml /path/to/myconfig.yaml
```

And then edit the configuration file. Read carefully the comment before editing everything :) If you have X installed, I strongly suggest using the GUI for now by changing the ```ui_mode``` to ```gui```:).

Then you can start running pimaton:
```bash
pimaton --config-file=/path/to/myconfig.yaml
pimaton --config-file=/path/to/myconfig.yaml --debug # verbose mode.
```


## What can it do so far:

- Take pictures and generate a final picture with thumbnails of the taken picture (by default 6 pictures that will be displayed on 2 rows and 3 columns)
- Print that picture if a printer is plugged in
- Very configurable:
  - TUI (very basic for now) and GUI mode
  - Multiple start input (keyboard, touchscreen and GPIO soon)
  - A template file (image with decoration to be the base of rendered image) can be used
    - A empty template with placeholder can be generated to help the template image creation
  - Picture size (taken by picamera), thumbnails (printed pictures), number and disposition of final rendering
  - Time between steps / loops
  - All texts
  - Print is an option, number of copies can be configured.
  - All picamera settings can be overridden.

More information can be found on the [README](https://github.com/bacardi55/pimaton/).
