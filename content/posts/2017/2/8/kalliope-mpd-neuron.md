---
title: Kalliope MPD neuron
date: 2017-02-08
tags:
- kalliope
- home_automation
- mpd
---


## Introduction

I was thinking about starting music by voice recognition for a while now. Since I've managed to launch my tv show via kalliope and kodi (more on that later :)), I still didn't have a way to do same for my music.

I start looking into existing solution and really liked the idea behind [mopidy](https://www.mopidy.com/), having an [MPD](https://www.musicpd.org/) server that also works with remote services like spotify. Meaning I could control not only my local music (as I would with a simple MPD server) but also my spotify library!

So to make this happen, I started created a simple (for now) neuron to manage an MPD server via Kalliope.

I keep the full installation / configuration I made (kalliope + mopidy) for another blog post though (:

## Installation

As usual, use the following command:

```bash
    kalliope install --git-url https://github.com/bacardi55/kalliope-mpd.git
```

## Configuration

This neuron let you launch several action. Let's look at a default neuron for using it:

```yaml
      - name: "play-music"
        signals:
          - order: "start playlist {{query}}"
        neurons:
          - kalliopempd:
              mpd_action: "playlist"
              mpd_url: "xxx.xxx.xxx.xxx"
              mpd_port: "yyyy"
              mpd_random: 1
              args:
                - query
```

As you can see, there is an `mpd_action` arguments that let you choose what to do. As of now, the available commands are:

- playlist (**requires query parameters**): run a playlist
- playlist_spotify (**specific to mopidy - requires query parameters**): run a playlist
- toggle_play: to toggle play/pause
- search (**requires query parameters**): to search music and play it
- play_next: play next song
- play_previsous: play previous song
- play_stop: Stop playing

The playlist_spotify action is a bit specific to mopidy as if you want to run a "top playlist" on spotify (like top tracks everywhere in the glob) you'll need to use this action.
If you know the name of your playlist, you can use the default `playlist` action to launch it (even for spotify playlist)

The [README](https://github.com/bacardi55/kalliope-mpd) will have the up to date list.

More example are available in the [sample brain file](https://github.com/bacardi55/kalliope-mpd/blob/master/samples/brain.yml)


## Conclusion

Now I can start/stop music by voice and simply switch song (prev/next) or play/pause the music when needed (:
I am also very pleased on how kalliope works well with music running in the background, so that the next/prev/pause commands are really usefull :).


I'll be back with a post about my full kalliope setups and configuration later when everything is finalized!
