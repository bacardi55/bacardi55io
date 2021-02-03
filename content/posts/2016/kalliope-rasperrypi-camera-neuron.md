---
title: Kalliope - Raspberrypi camera neuron
date: 2016-12-26
tags:
- home_automation
- kalliope
category:
description:
---


**EDIT: Installing "community" modules like neuron is now a feature of Kalliope (via the CLI), please [read here instead]({{< ref "/content/posts/2017/1/3/kalliope-community-modules-and-the-picamera-neuron.md" >}} "Read Here")**

To start with the [kalliope](https://github.com/kalliope-project/kalliope) blog posts series, I'll start with introducing the few neurons I created on top of the existing ones.

Simplest neuron I created is a neuron to leverage the raspberrypi camera to take picture when asking kalliope to do so. Kalliope is installed on a raspberrypi v3 with a touchscreen display and a [pi camera](https://thepihut.com/collections/raspberry-pi-camera)

The neuron can be found [here](https://github.com/bacardi55/kalliope_config/tree/master/neurons/camera) (I need to move each neurons on it's own github repository as their will be a market place for kalliope neuron soon).

To enable this neuron, you need to install first the picamera python library ```apt-get install python-picamera``` should do it.

Then, create your neuron file picamera.yml like the [example one](https://github.com/bacardi55/kalliope_config/blob/master/brains/camera.yml):
```yaml
---
  - name: "Take-pictures"
    signals:
      - order: "take pictures"
    neurons:
      - camera:
          number_of_picture: 3
          directory: "/home/pi/Desktop/PIctures/"
          timer: 1
      - say:
          message: "Picture taken"
```

You can configure how many pictures Kalliope will take (3 in this example), where to save then (here /home/pi/Desktop/Pictures) and how many seconds between the picture Kalliope needs to wait.

As you can see, pretty simple, but for me it was more a poc of using the picamera with Kalliope, I have further idea for it in the future, maybe using [OpenCV](http://opencv.org/) with it :).

But I have other neurons do upgrade / create before going this road.

Stay tune for the other neurons.
