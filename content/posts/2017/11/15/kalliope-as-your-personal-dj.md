---
title: Kalliope as your personal DJ
date: 2017-11-15
tags:
- kalliope
- mpd
- mopidy
category:
---


A quick blog post about how I managed my music via Kalliope :)

The basic idea is simple: I want to ask Kalliope to play music for me, and manage spotify playlist/search and radio

To do this, I need:
- [Kalliope](https://kalliope-project.github.io) installed
- [Kalliope MPD module](https://github.com/bacardi55/kalliope-mpd) installed
- [Mopidy server](https://www.mopidy.com/) (to act like a MPD server and manage spotify and radio source)

I wanted to have a simple flow:

```
Me: "I want to listen to music"
Kalliope: "Of course, what do you want to listen to?"
Me:
  Option 1:
    Me: "My favorite spotify playlist"
    Kalliope: "Ok, starting your favorite playlist"

  Option 2:
    Me: "spotify playlist <Name Of a playlist>"
    Kalliope: "Ok, launching <Name of a playlist>"

  Option 3:
    Me: "I want to listen to the radio"
    Kalliope: Which radio sir?
    Me: "<radio name>"
    Kalliope: "launching radio <radio name>"

  Option 4:
    Me: "music from <artist name>"
    Kalliope: "searching for music of <artist name>"

  Option 5:
    Me: "I'll try some fashion music"
    Kalliope: "Starting some fashion music"
```

## Installation


### Kalliope

First, install Kalliope. For this, follow [the documentation](https://github.com/kalliope-project/kalliope/blob/master/README.md).
Once it's done and working, install the [MPD neuron](https://github.com/bacardi55/kalliope-mpd) as indicated on the [README](https://github.com/bacardi55/kalliope-mpd/blob/master/README.md).

We'll get to the brain configuration in the next step.


### Mopidy server

Then, you need to install mopidy. Either on the same device as Kalliope or on another one. For this, same as above, [follow the documentation](https://docs.mopidy.com/en/stable/) :)

If you have the same use cases as me, and want to plug spotify and the radio, you will also need to install [mopidy-spotify](https://github.com/mopidy/mopidy-spotify), [tunein](https://github.com/kingosticks/mopidy-tunein), and [spotify_tunigo](https://github.com/trygveaa/mopidy-spotify-tunigo) and of corse the core [mpd backend](https://docs.mopidy.com/en/stable/ext/mpd/).

Mon fichier de conf ```.config/mopidy/mopidy.conf``` pour exemple:

```
[mpd]
enabled = true
hostname = 127.0.0.1
port = 8080
password = MyPassword
max_connections = 10
connection_timeout = 60
zeroconf = Mopidy MPD server on $hostname
command_blacklist = listall,listallinfo
default_playlist_scheme = m3u

[core]
cache_dir = $XDG_CACHE_DIR/mopidy
config_dir = $XDG_CONFIG_DIR/mopidy
data_dir = $XDG_DATA_DIR/mopidy
max_tracklist_length = 10000
restore_state = false

[logging]
color = true
console_format = %(levelname)-8s %(message)s
debug_format = %(levelname)-8s %(asctime)s [%(process)d:%(threadName)s] %(name)s\n  %(message)s
debug_file = mopidy.log
config_file =

[spotify]
username = MyLogin
password = MyPassword
enabled = true
bitrate = 320
timeout = 100
client_id = MyClientId
client_secret = MyClientSecret

[spotify_tunigo]
enabled: true

[tunein]
timeout = 5000
```

*PS: You need to adapt the hostname if your mopidy server is not installed on the same machine as Kalliope!, see [mopidy hostname configuration here](https://docs.mopidy.com/en/stable/config/).*


## Configuring the brain

### The first question

Let's create a new brain file called ```mpd.yml``` in your brains directory, and configure the first step of the flow:

```yaml
  - name: "ask-and-play-music"
    signals:
      - order: "I want to listen to music"
    neurons:
      - say:
          message: "Of course, what do you want to listen to?"
      - neurotransmitter:
          from_answer_link:
            - synapse: "play-favorite-spotify-playlist"
              answers:
                - "My favorite spotify playlist"
            - synapse: "play-asked-spotify-playlist"
              answers:
                - "spotify playlist {{query}}"
            - synapse: "play-fashion-music"
              answers:
                - "I'll try some fashion music"
            - synapse: "play-asked-radio"
              answers:
                - "I want to listen to the radio"
            - synapse: "play-asked-music"
              answers:
                - "search for {{query}}"
          default: "didnt-understand"
```

So here we have the first step for our full flow. Kalliope is asking what kind of music I want to listen to, and depending on my answer, different synapse will be triggered.

Now I need to define the actions for each of these choices.


### Managing options and anwsers

#### Playing my favorite playlist

That's easy, just like said in the doc of the neuron:

```yaml
  - name: "play-favorite-spotify-playlist"
    signals:
      - order: "start my favorite spotify playlist"
    neurons:
      - kalliopempd:
          mpd_action: "playlist"
          mpd_url: "{{mpd_url}}"
          mpd_port: "{{mpd_port}}"
          mpd_password: "{{mpd_password}}"
          mpd_random: "1"
          mpd_volume: "50"
          query: "{{favorite_playlist_name}}"
      - say:
          message: "Ok, starting your favorite playlist"
```

I could give a "no_order" but I might want to fire this playlist directly so I gave a correct order.

*Please note that I'm using the brackets because I'm using the [variables capability of kalliope](https://github.com/kalliope-project/kalliope/blob/master/Docs/settings.md#global-variables)*

#### Playing a playlist

```yaml
  - name: "play-asked-spotify-playlist"
    signals:
      - order: "start playlist {{query}}"
    neurons:
      - kalliopempd:
          mpd_action: "playlist"
          mpd_url: "{{mpd_url}}"
          mpd_port: "{{mpd_port}}"
          mpd_password: "{{mpd_password}}"
          mpd_random: "1"
          mpd_volume: "50"
          query: "{{query}}"
      - say:
          message: "Ok, starting the playlist {{query}}"
```

#### Asking and playing a radio

First, lets configure kalliope so it ask which radio I want to listen to:

```yaml
  - name: "play-asked-radio"
    signals:
      - order: "I want to listen to the radio"
    neurons:
      - say:
          message: "Which radio sir?"
      - neurotransmitter:
          from_answer_link:
            - synapse: "play-radio"
              answers:
                - "{{query}}"
          default: "didnt-understand"
```

Then, create the brain that will actually start the radio:

```yaml
  - name: "play-radio"
    signals:
      - order: "play-radio-no-order"
    neurons:
      - kalliopempd:
          mpd_action: "search"
          mpd_url: "{{mpd_url}}"
          mpd_port: "{{mpd_port}}"
          mpd_password: "{{mpd_password}}"
          mpd_random: "0"
          query: "{{query}}"
      - say:
          message: "Launching radio {{query}}"
```

*Please note that I'm using the brackets because I'm using the [variables capability of kalliope](https://github.com/kalliope-project/kalliope/blob/master/Docs/settings.md#global-variables)*

#### Asking and playing any music

Same as the favorite playlist:

```yaml
  - name: "play-asked-music"
    signals:
      - order: "search music {{query}}"
    neurons:
      - kalliopempd:
          mpd_action: "search"
          mpd_url: "{{mpd_url}}"
          mpd_port: "{{mpd_port}}"
          mpd_password: "{{mpd_password}}"
          mpd_random: "0"
          query: "{{query}}"
      - say:
          message: "Launching some music of {{query}}"
```

*Please note that I'm using the brackets because I'm using the [variables capability of kalliope](https://github.com/kalliope-project/kalliope/blob/master/Docs/settings.md#global-variables)*

#### Didn't understand synapse

This is just to let me know if something went wrong and Kalliope didn't understand:

```yaml
  - name: "didnt-understand"
    signals:
      - order: "didnt-understand"
    neurons:
      - say:
          message: "I'm terribly sorry sir, but something went wrong…"
```

Don't forget to add your new brain file in the brain.yml via an include and your variable in a loaded file :)

The full brain file:

```yaml
  - name: "ask-and-play-music"
    signals:
      - order: "I want to listen to music"
    neurons:
      - say:
          message: "Of course, what do you want to listen to?"
      - neurotransmitter:
          from_answer_link:
            - synapse: "play-favorite-spotify-playlist"
              answers:
                - "My favorite spotify playlist"
            - synapse: "play-asked-spotify-playlist"
              answers:
                - "spotify playlist {{query}}"
            - synapse: "play-fashion-music"
              answers:
                - "I'll try some fashion music"
            - synapse: "play-asked-radio"
              answers:
                - "I want to listen to the radio"
            - synapse: "play-asked-music"
              answers:
                - "search for {{query}}"
          default: "didnt-understand"

  - name: "play-favorite-spotify-playlist"
    signals:
      - order: "start my favorite spotify playlist"
    neurons:
      - kalliopempd:
          mpd_action: "playlist"
          mpd_url: "{{mpd_url}}"
          mpd_port: "{{mpd_port}}"
          mpd_password: "{{mpd_password}}"
          mpd_random: "1"
          mpd_volume: "50"
          query: "{{favorite_playlist_name}}"
      - say:
          message: "Ok, starting your favorite playlist"

  - name: "play-asked-spotify-playlist"
    signals:
      - order: "start playlist {{query}}"
    neurons:
      - kalliopempd:
          mpd_action: "playlist"
          mpd_url: "{{mpd_url}}"
          mpd_port: "{{mpd_port}}"
          mpd_password: "{{mpd_password}}"
          mpd_random: "1"
          mpd_volume: "50"
          query: "{{query}}"
      - say:
          message: "Ok, starting the playlist {{query}}"

  - name: "play-asked-radio"
    signals:
      - order: "I want to listen to the radio"
    neurons:
      - say:
          message: "Which radio sir?"
      - neurotransmitter:
          from_answer_link:
            - synapse: "play-radio"
              answers:
                - "{{query}}"
          default: "didnt-understand"

  - name: "play-radio"
    signals:
      - order: "play-radio-no-order"
    neurons:
      - kalliopempd:
          mpd_action: "search"
          mpd_url: "{{mpd_url}}"
          mpd_port: "{{mpd_port}}"
          mpd_password: "{{mpd_password}}"
          mpd_random: "0"
          query: "{{query}}"
      - say:
          message: "Launching radio {{query}}"

  - name: "play-asked-music"
    signals:
      - order: "search music {{query}}"
    neurons:
      - kalliopempd:
          mpd_action: "search"
          mpd_url: "{{mpd_url}}"
          mpd_port: "{{mpd_port}}"
          mpd_password: "{{mpd_password}}"
          mpd_random: "0"
          query: "{{query}}"
      - say:
          message: "Launching some music of {{query}}"

  - name: "didnt-understand"
    signals:
      - order: "didnt-understand"
    neurons:
      - say:
          message: "I'm terribly sorry sir, but something went wrong…"
```
