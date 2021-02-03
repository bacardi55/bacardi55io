---
title: Home Automation, part 3 - Multi room music and sound system with Mopidy and Snapcast
date: 2020-04-18T16:03:26+01:00
tags:
- homeautomation
- mopidy
- snapcast
- sound
- spotify
- mdp
categories:
- selfhosting
description: Listen local and spotify music in every room
---

# Context

In the previous [home automation blog post](), I explained how I installed the central pieces of my [home automation]() system ([NodeRed](), [Mosquitto]() and [Domoticz]()). Before starting explaining some of the flows, routine and automation, I need to finish explaining the global setup. This post is about my setup for my music server ([Mopidy]()) and the multi room sound system ([Snapcast]()).

You can find the full architecture defined in this [post](), but the TLDR; is this image (updated from previous post):

![My Home Automation architecture](/images/pages/home-lab/architecture.jpg "My Home Automation architecture")


As shown in the diagram above, my setup is composed of:

- A raspberry pi (brook[^1]) in the kitchen, running snapcast server (`snapserver`), Mopidy and Snapcast client (`snapclient`) with a cheap USB speaker (as I just need basic sound while I'm cooking).
- A raspberry pi (ryo saeba[^2]) running snapcast client (`snapclient`) with the same cheap USB speaker (mainly used in the morning for my alarm routine)
- My laptop (in the office), running snapcast client (off by default), connected to a bluetooth speaker (off by default too)

I'm using cheap USB speakers mainly because I bought them as a proof of concept (12€ each) to validate the possibility. I'm thinking of changing the one in my bedroom (I don't care about sound quality in the kitchen). Aside from the sound quality, this system has been working smoothly with almost no issues for at least a year :).

I also need to add a snapclient in my living room plugged to my sound bar as well. But I still need to work on it. The good news is that adding a snapcast client is damn easy :).

# Installation and Configuration of Snapcast and Mopidy

## Mopidy

### Installation

Simply follow the official [raspberry pi install documentation](https://docs.mopidy.com/en/latest/installation/raspberrypi/) (Use a dedicated mopidy user!).

For the installation itself:

```bash
wget -q -O - https://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
sudo wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list
sudo apt update
sudo apt install mopidy mopidy-mpd mopidy-spotify
```


### Configuration

See the [official documentation](http://docs.mopidy.com/) for options and configuration! In the meantime, this is my `/etc/mopidy/mopidy.conf`:

```mopidy.conf
[core]
#cache_dir = $XDG_CACHE_DIR/mopidy
#config_dir = $XDG_CONFIG_DIR/mopidy
#data_dir = $XDG_DATA_DIR/mopidy
#max_tracklist_length = 10000
#restore_state = false

[logging]
color = true
console_format = %(levelname)-8s %(message)s
debug_format = %(levelname)-8s %(asctime)s [%(process)d:%(threadName)s] %(name)s\n  %(message)s
debug_file = mopidy.log
config_file = logging.conf

[audio]
# We will understand that later. Leave commented for now!
# output = audioresample ! audioconvert ! audio/x-raw,rate=48000,channels=2,format=S16LE ! wavenc ! filesink location=/tmp/snapfifo

[mpd]
enabled = true
hostname = 0.0.0.0
port = <port>
#password =
max_connections = 5
connection_timeout = 60
#zeroconf = Mopidy MPD server on $hostname
#command_blacklist =
#  listall
#  listallinfo
default_playlist_scheme = m3u

[http]
#enabled = true
#hostname = 127.0.0.1
#port = 6680
#static_dir =
#zeroconf = Mopidy HTTP server on $hostname

[m3u]
enabled = true
#base_dir =
#default_encoding = latin-1
#default_extension = .m3u8
#playlists_dir =

[softwaremixer]
#enabled = true

[file]
# I don't have local music files.
enabled = false

[local]
# I don't have local music files.
enabled = false

[spotify]
enabled = true
username = <username> # Changeme
#password = <password> # Changeme
client_id = <spotify-client-id> # Changeme
client_secret = <spotify-client-secret> # Changeme
bitrate = 320
volume_normalization = true
private_session = false
timeout = 20
allow_cache = true
allow_network = true
allow_playlists = true
search_album_count = 20
search_artist_count = 10
search_track_count = 50
toplist_countries =

[spotify_web]
client_id = <spotify-client-id> # Changeme
client_secret = <spotify-client-secret> # Changeme

[tunein]
enabled = false

[http]
enabled = true
hostname = ::
port = <port> # Changeme
static_dir =
zeroconf = brook

[mopify]
enabled = true
debug = false

[musicbox_webclient]
enabled = true
musicbox = false
websocket_host =
websocket_port =
on_track_click = PLAY_ALL
```

The important piece for me are the activation of the [MPD]() deamon (the `[mpd]` section) so mopidy can be used with any MPD client (for my laptop) and is connected to spotify for my music library (see `[spotify]` section).

### Control

#### Web UI

I enabled 2 Web UI: [musicbox]() and [mopify](). If you want to have web UI, you need to enable `http` extension (see above my config file or the [official documentation](https://docs.mopidy.com/en/latest/ext/http/#hosting-web-clients)).

If you want to use them, you'll have to install them.

For Mopify:
```bash
sudo pip3 install Mopidy-Mopify
```

For MusicBox Webclient:

```bash
sudo pip3 install Mopidy-MusicBox-Webclient
```

Then go to `http://<MopidyServerIpAddress>:<port>/mopidy` (`<port>` is the one defined in the `[http]` section), and you'll be asked to choose between mopify and music box.

Check the [documentation](https://mopidy.com/ext/) for more Web UI or extension!

#### MPD client

As I have enabled Mopidy to act as a MPD deamon, I can use any MPD client to control it. For example, I'm using [ncmpcpp](https://rybczak.net/ncmpcpp/) on my laptop (because [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) FTW! :)), but you could use [any mpd client](https://www.musicpd.org/clients/)!

#### Mobile App

There is a great [Mopidy android application](https://github.com/tkem/mopidy-mobile) :-).

### Playing sound.

At this point, you should be able to play music with Mopidy through any of the client, eg by going to the web UI. Be careful, for now the sound will only play on the machine where mopidy is installed and not on the client machine! Once the music works, let's move on the snapcast configuration to send the sound to the right places!

## Snapcast

[Snapcast]() is a Synchronous multiroom audio player. It means it can manage multiple clients that will play music in a synchronous manner (= no lag on the different clients). It is really simple yet powerful as you can manage the different client volume level and you can even have multiple stream if you want to play different music in the different rooms. This is planned on my todolist, but for now I'm using only 1 stream so all rooms will play the same thing (if they are not muted of course).


### Installation

First, we need to install the snapcast server (`snapserver`), so on the server you want to run snapserver:

Go to the [latest release page](https://github.com/badaix/snapcast/releases/latest), and copy the link to the armhf deb:
```bash
wget "https://github.com/badaix/snapcast/releases/download/v0.19.0/snapserver_0.19.0-1_armhf.deb"  # May change in case of new release.
sudo dpkg -i snapserver_0.19.0-1_armhf.deb
sudo apt -f install # To fix dependencies
```

Then, on each machine where you want to install snapclient[^3]:

On my Raspberry Pi (`brook` and  `nickylarson`):
```bash
wget "https://github.com/badaix/snapcast/releases/download/v0.19.0/snapclient_0.19.0-1_armhf.deb" # May change in case of new release
sudo dpkg -i snapclient_0.19.0-1_armhf.deb
sudo apt -f install
```

And then on my laptop (running ubuntu for work related reasons):

```bash
wget "https://github.com/badaix/snapcast/releases/download/v0.19.0/snapclient_0.19.0-1_amd64.deb" # May change in case of new release
sudo dpkg -i snapclient_0.19.0-1_amd64.deb
sudo apt -f install
sudo systemctl disable snapclient # To not start it automatically.
```

Look at the [official documentation](https://github.com/badaix/snapcast#installation) if you don't use a raspberry pi or want more information.


### Configuration

#### Snapserver

Edit the configuration file `/etc/default/snapserver` (defines snapserver command arguments):

```ini
START_SNAPSERVER=true
SNAPSERVER_OPTS=""
```

The configuration is very simple because I only use one stream, so I don't need to declare anything specific here. I just set snapserver to start by default

Then edit the server configuration `/etc/snapserver.conf`. I'm going to only highlight here the changed values:

```snapserver.conf
[http]
#enable HTTP Json RPC (HTTP POST and websockets)
enabled = true

# use "0.0.0.0" to bind to any IPv4 address or :: to bind to any IPv6 address
bind_to_address = 0.0.0.0

# which port the server should listen to
port = <port> # changeme

[tcp]
# enable TCP Json RPC
enabled = true

# use "0.0.0.0" to bind to any IPv4 address or :: to bind to any IPv6 address
bind_to_address = 0.0.0.0

# which port the server shgould listen to
port = <port2>

stream = pipe:///tmp/snapfifo?name=default
```

The `stream = pipe:///tmp/snapfifo?name=default` line is very important, it should remind you of a commented line in our mopidy.conf file that you need to uncomment now:

```mopidy.conf
output = audioresample ! audioconvert ! audio/x-raw,rate=48000,channels=2,format=S16LE ! wavenc ! filesink location=/tmp/snapfifo
```

The `location=/tmp/snapfifo` is the way to tell Mopidy to use snapcast as audio output. See the [documentation](https://github.com/badaix/snapcast/blob/master/doc/player_setup.md#mopidy) for more information.

I also enabled the [http] section to be able to send JSON-RPC request via http from NodeRed, but more on that later :).

#### Snapclient

Edit the configuration file `/etc/default/snapclient` on each snapclient[^3]:

```ini
START_SNAPCLIENT=true
SNAPCLIENT_OPTS="-s 15"
```

The `-s 15` is to indicate snapclient to use the `15` soundcard. To find the right soundcard you can run `snapclient -l` to get the list with their id.


### Control

#### Mobile App

Snapcast provides a very minimalist android application to control snapcast client volume level. The android app can also be downloaded on the release page. The app is called `snapdroid` and can be found on the play store or on the [snapdroid release page]().

#### JSON-RPC API

Snapcast provides a full [JSON-RPC API]() that can be leverage to control it. I'm mainly using through my home automation brain [NodeRed](), but we will see this in another post :).

## And now what?

Now, you should have a working Mopidy server, connected to your spotify account that you can control through any device and client. When playing music via a mopidy client (web, mpd, mobile app), sound will be played through snapcast on the different enabled clients (check on the android app the volume level of each and the mute status ;)).


# Conclusion

We'll see in later post how to manipulate and integrate this sound system in the more global home automation by configuring some NodeRed flows (via MPD for Mopidy and Json-RPC for snapcast) :)

Just to whet your appetite, this is part of my dashboard to control (part of) the sound system:

![Sound and Music dashboard](/images/posts/2020/04/18/homeautomationp3/musicdashboard.png "Sound and Music dashboard")


[^1]: From One Piece :)
[^2]: From city hunter / Nicky Larson (fr)
[^3]: Remember the [tmux tip]() to launch commands on multiple machine at the same time.
