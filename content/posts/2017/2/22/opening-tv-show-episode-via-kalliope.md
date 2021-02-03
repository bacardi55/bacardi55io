---
title: Opening Tv show episode via Kalliope
date: 2017-02-22
tags:
- kalliope
- home_automation
- kodi
---


## Introduction

Today, a quick blog post about something I've put in place when I started playing with Kalliopé: asking kalliope to read videos from me.

The idea is simple: I have a raspberry pi in my living room plugged on my TV. On it [kodi](http://kodi.tv) is installed and a hard drive with some tv shows episode on it (legally acquired!). The goal was to simply ask Kalliope to find a file on kodi hard drive and run it on kodi, eg: "Launch tv show friends episode 101"

## The idea

First I asked myself if a neuron was useful or not here.

If I created a neuron, it would be either

* A kodi neuron that need to implement their complex API
* A neuron specific to my setup that no-one would reuse

Looking at my alternatives, I decided to manage it mainly via a simple shell script that would parse a simple text to find the name of the show, the episode and season.
The script would then look over ssh to find the file name and then run a request against Kodi API to launch the file directly.

## What does the shell script do

The script will receive in argument something like <TvShow_name> <season_number><episode_number>

* <TvShow_name> is a string (eg: "friends")
* <season_number> is a number on 1 or 2 digit (eg: "1" or 12")
* <episode_number> is a number always on 2 digit (eg: "01" or "21")

Based on this three information, the script will connect via ssh and run a find command on to find a file containing either:

* the <TvShow_name> and "S<season_number>E<episode_number>"   (in this case, if season_number is lower than 10, the number will be put on 2 digit before)
* the <TvShow_name> and "S<season_number>EP<episode_number>"   (in this case, if season_number is lower than 10, the number will be put on 2 digit before)
* the <TvShow_name> and "<season_number><episode_number>"

This are the 2 uses cases for my file name. So a couple of example:

* "friends 304" will search for file containing:
  * "friends" and "S03E04"
  * "friends" and "S03EP04"
  * "friends" and "304"
* "friends 121" will search for file containing:
  * "friends" and "S01E21"
  * "friends" and "S01EP21"
  * "friends" and "121"
* "friends 1005" will search for file containing:
  * "friends" and "S10E05"
  * "friends" and "S10EP05"
  * "friends" and "1005"

Once a file is found (first one), the Kodi API is used to start this file. The API command looks like this:

```bash
curl -g 'http://kodi/jsonrpc?request={"jsonrpc":"2.0","id":"1","method":"Player.Open","params":{"item":{"file":"'"$result_string"'"}}}'
```

Where ```$result_string``` is the name of file (and thus the result of the find/grep command) and ```kodi``` is the hostname of your kodi server.


## Setup

### The shell script

#### Enable ssh access

First, make sure the user that runs kalliope can connect via ssh without password (via ssh key or by manually opening an ssh-agent connection before launching kalliope)

I leave you find some tuto online about this kind of setup, there is already a lot of documentation!


####  Install the script

The full script can be found [here](https://github.com/bacardi55/kalliope-starter55/blob/master/script/find-episode.sh).

Download it, make it executable (```chmod +x find-episode.sh```) and put it somewhere accessible by the user running kalliope.

(In my case, in a [script directory](https://github.com/bacardi55/kalliope-starter55/blob/master/script/) in my [kalliope starter kit](https://github.com/bacardi55/kalliope-starter55)


### Create a brain file

This is my example but you can change to your needs:

```yaml
  - name: "Start-episode"
    signals:
      - order: "start episode {{ query }}"
    neurons:
      - shell:
          cmd: "/path/to/script/find-episode.sh "
          args:
             - query
```

The important thing is is to send the arguments as one query to the script that will manage the rest itself.

I could have created an order like ```start tv show {{tvshow}} season number {{season}} episode number {{number}}``` but the shell neuron didn't take arguments. I made an [accepted PR](https://github.com/kalliope-project/kalliope/pull/132/files) to be able to send an argument to the shell script.

Maybe I should PR it again to add the ability to pass unlimited number of arguments that will be send to the shell script … But that then raise questions of orders, options, …


I hope this will work for you as well so you will be able to fire tv show episode without looking at your remote!
