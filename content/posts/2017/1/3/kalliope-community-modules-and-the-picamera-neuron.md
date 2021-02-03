---
title: Kalliope community modules and the Picamera neuron
date: 2017-01-03
tags:
- kalliope
- home_automation
category:
description:
---


[Kalliope](https://github.com/kalliope-project/kalliope) has recently introduced the "community module" system that will help user share neurons, tts and stt easily via a simple git url.

This blog introduce quickly how it works and update the installation process of the picamera simple neurons to this method

## Introducing the community neurons system

Goal here is to provide a way for the user to share their neurons. I believe the team are (or will) work on a "market place" for neurons, but as of today, the list is only available on the github doc page [here](https://github.com/kalliope-project/kalliope/blob/master/Docs/neuron_list.md), so you'll have to create a pull request to add your custom neuron in this list.

The neurons needs to be on a dedicated git repository and contains a dna.yml and a install.yml files on top of the python code of your neuron

[dna.yml](https://github.com/kalliope-project/kalliope/blob/master/Docs/contributing/dna.md) file contains the description of the module, including its name, the version of kalliope supported and some tags.

[install.yml]() file contains an ansible playbook that will
which include the dependencies that might need to be installed when installing the neuron (could be via pip or apt-get). It uses [ansible](https://www.ansible.com/) behind the scene to do so.


More information about creating your neurons [here](https://github.com/kalliope-project/kalliope/blob/master/Docs/contributing/contribute_neuron.md).

## Example with picamera neuron

So following the new rules, I've created a dedicated repository for the picamera neuron that can be found [here](https://github.com/bacardi55/kalliope-picamera).
As the doc says, you just need to do

```bash
    kalliope install --git-url https://github.com/bacardi55/kalliope-picamera
```

And it should install the picamera python library as well as cloning your repo in your neuron resource directory.

The neuron resource directory is set in the settings.yml like this:

```yaml
    resource_directory:
      neuron: "resources/neurons"
      stt: "resources/stt"
      tts: "resources/tts"
```

Then, as before, you can create a brain to use this neuron like this:

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

And voilà!
