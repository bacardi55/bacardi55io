---
title: Kalliope - a poorsman log analyser
date: 2017-02-21
tags:
- kalliope
- home_automation
---


## Introduction

Today, I wanted to have a quick overview of my Kalliope usage. I have more and more neurons available and more and more configured synapses so I thought it could be cool to start having some data.

I didn't want to put in place some heavy log analyser or sort, a simple bash script would do the trick.

Of course, I also wanted the output interface to be Kalliope as well (:

## How

### Generate log with kalliope

By default, logs are just the output of Kalliope and are not stored in logs. So instead of implementing something within Kalliope, I thought it would be easier to just launch kalliope and push the output into a log file. I also wanted to still be able to see the logs in the terminal I launched Kalliope with.

Normally, a simple

```bash
  command | tee output.log
```

Should be enough, but because it is a python script, you actually need to launch Kalliope like this:

```bash
  /usr/bin/python -u /usr/local/bin/kalliope start | tee -a kalliope.log
```

### Read logs

I then created the simplest shell script possible. Can be found in [my kalliope starter kit](https://github.com/bacardi55/kalliope-starter55) [here](https://github.com/bacardi55/kalliope-starter55/blob/master/script/poorsmanloganalyser.sh).

```bash
  ##!/bin/bash

  ## You need to have kalliope logs available. To do so, I run kalliope like this:
  ## /usr/bin/python -u /usr/local/bin/kalliope start | tee -a kalliope.log
  ## So that logs are still displayed on standard output and in a log file

  ## Edit the audio variable text to use the variable as needed. Kalliope will read the content of the audio variable (output of the script)

  LOG_FILE="/home/pi/kalliope_config/kalliope.log"

  nb_trigger=$(cat "$LOG_FILE" | grep "Say something!" | wc -l)
  nb_match=$(cat "$LOG_FILE" | grep "Order matched in the brain" | wc -l)
  nb_audio_issue=$(cat "$LOG_FILE" | grep "Google Speech Recognition could not understand audio" | wc -l)
  nb_no_synapse=$(cat "$LOG_FILE" | grep "No synapse match the captured order" | wc -l)

  audio="As far as I remember, $nb_trigger vocal orders have been triggered, I didn't understood $nb_no_synapse of them and had an audio issue for $nb_audio_issue of them"

  echo "$audio"
```

basically looking in the output the number of line matching some patterns triggered by Kalliopé.

The content of the audio variable is the text that will be read by Kalliope.

### Create your brain

Now that you have the log generated, and the script to read them, you need to create the brain that will fire a simple shell script and read the output.

```yaml
  - name: "System-status"
    signals:
      - order: "Step into analysis mode, please"
    neurons:
      - shell:
          cmd: "sh script/poorsmanloganalyser.sh"
          say_template:
            - "{{output}}"
```


And now you can have some numbers (:
