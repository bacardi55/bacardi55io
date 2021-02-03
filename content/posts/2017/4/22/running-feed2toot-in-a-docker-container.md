---
title: Running feed2toot in a docker container
date: 2017-04-22
tags:
- docker
- mastodon
- feed2toot
---


## Introduction

Today, a very quick blog post on a how to install [feed2toot](https://gitlab.com/chaica/feed2toot) in a docker container. Feed2toot is a python application that will send toot on Mastodon for each item of an RSS feed.

If you want to install Mastodon, I suggest you read here:
- [Offical documentation](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Docker-Guide.md)
- [Intall guide for Digital ocean](https://hackernoon.com/deploying-mastodon-on-digital-ocean-f54b94c7f5b8)
- [French intall guide on Debian](https://psychedeli.cat/mastodon/)


if you want to install [feed2toot](https://gitlab.com/chaica/feed2toot) in a container to be able to create toot from an RSS feed, then keep reading :).


## Create the docker image

### Get the files

You can start with my repo as a base:

```bash
git clone https://git.bacardi55.org/bacardi55/docker-feed2toot.git
```

## Build the container image

```
cd docker-feed2toot
docker build -t b55/feed2toot .
```

*You can change the tag name :)*

## Configure feed2toot

Edit the ```conf/feed2toot.ini```, ```conf/rsslinks.txt``` and ```conf/hashtags.txt``` files as describe in the [official documentation]()

**The current release needs a hashtags file, even empty! It will become optional in the next release**

## Run

### Get your credential first

Then, register your application with your mastodon account:

```bash
docker run --rm -v "$(pwd)"/conf:/etc/feed2toot -it b55/feed2toot register_feed2toot_app
```

It will ask your password (but won't save it) to generate token files.


### Test the first run

```bash
docker run --rm -v "$(pwd)"/conf:/etc/feed2toot b55/feed2toot
```

Go to your user mastodon page, you should see the toot generated :)


### Automate

To avoid launching the app manually, let's put a simple task in our crontab:

Open the crontab file: ```crontab -e``` and insert this line:

```
@hourly docker run --rm -v /path/to/conf:/etc/feed2toot b55/feed2toot
```

And you should be good to go!
