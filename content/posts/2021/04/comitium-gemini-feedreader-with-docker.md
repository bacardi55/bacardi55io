---
title: "Managing your gemini feeds with Comitium and docker"
date: 2021-04-08T23:27:13+02:00
tags:
- homelab
- docker
- selfhosting
- comitium
- gemini
categories:
- selfhosting
---

## Context

If you read this blog before, you know that I've become a big fan of the [gemini space](https://gemini.circumlunar.space/) and that I do run [a capsule](gemini://gmi.bacardi55.io) with specific content on there :). I've been enjoying reading many gemlog over the past months and the list is growing :).

As for the web, following every capsules is hard to do "manually" and as for the web, having a feed reader is very useful :). Until now, I have been using the built-in capability of [amfora gemini browser](https://github.com/makeworld-the-better-one/amfora) to subscribe to feeds and it has worked flawlessly (I love this browser :)). But the issue I have with it is that it is link to my laptop and the local installation of amfora. If I browse the gemini space on my phone, I still need to see what's new in the capsule I follow. I won't write more about this, this is the same idea of having a web rss feed like [freshrss](https://www.freshrss.org) or [miniflux](https://miniflux.app/).

I won't talk about how much I love following gemlogs at the moment and how it reminds me of the early days of following bloggers online as it will be the goal of a dedicated gemlog post^^.

There are multiple feed readers for gemini, like [Gemreader](https://sr.ht/~sircmpwn/gemreader/), [Gmisub](https://sr.ht/~callum/gmisub/), [Moku-Pona](https://github.com/kensanata/moku-pona), [comitium](https://git.nytpu.com/comitium/about/), and probably others…

I selected comitium in the end, as it seemed very simple to install and manage. And it does exactly what I need :]. So far, it has worked for a couple of days quite nicely :).

## Installation

So first thing first, as you know, I manage everything in docker in my self hosted environment. As always, I'm not saying this is the right way of doing it, just a way I enjoy ^^.

Anyway, no need to deploy a swarm stack for comitium, I just need to run it every X hours to refresh the feeds. I could have installed comitium on one of the node, but I didn't want to install go locally on the host. So let's use a very simple image to create the gmi files. Comitium will generate files to deploy to your gemini server. More on that later.

### Image Creation

No public image yet to reuse, but as you know I like having my own built images. I have my "preprod" rpi with my local registry on it as explained [here](https://bacardi55.io/2021/03/29/home-lab-part-8-create-a-local-docker-registry-to-manage-your-own-images/).

This is an example of an extremely simple Dockerfile:

```Dockerfile
FROM golang:1.15

RUN \
   git clone https://git.sr.ht/~sircmpwn/scdoc && cd scdoc && \
   make && make install && cd ..
RUN \
   git clone https://git.nytpu.com/comitium && cd comitium && \
   make && make install

VOLUME /data
```

No entrypoint or command as we will have to use different commands (add/remove/refresh).

Then, build the image:

```bash
docker build .
```

If it works, you can tag the image:

```bash
docker build . -t registry.local:5000/b55-comitium:latest
```

Then, you can do a test run:

```bash
docker run -it --rm -v /home/pi/testdir/comitium/data/:/data registry.local:5000/b55-comitium:latest comitium add <GeminiFeedUrl> -d /data
```

It should generate files in the data directory (`feeds.gmi`, `subscriptions.gmi`, `comitium.json`).


### Usage on the cluster

So let's deploy it on the cluster. Ssh to one of the node and:

```bash
docker pull registry.local:5000/b55-comitium:latest
```

Should pull the image from the registry. Adapt to your url/port.

Create the data where the files needs to be generated. It could be in a directory of your servers or anywhere. In my case, I prefer generating it in a dedicated directory and then `rsync` it in the right directory for the server.

```bash
mkdir /path/to/comitium/data
```

Then you can add a feed to test. Same command as on `freeza`:
```bash
docker run -it --rm -v /path/to/comitium/data/:/data registry.local:5000/b55-comitium:latest comitium add <GeminiFeedUrl> -d /data
```

It should generate the files as said above.

**Nota**: You can customize the header of the page by providing a `header.gmi` file.

In my case, I simply use a `header.gmi` file containing (with the empty line at the end):

```text/gemini
# Bacardi55's gemini feed subscriptions
=> https://git.nytpu.com/comitium/ This page is generated with comitium

```

To refresh the data, this command could be used:

```bash
docker run -it --rm -v /path/to/comitium/data/:/data registry.local:5000/b55-comitium:latest comitium refresh -d /data
```

Also, because I make comitium create this files not in the server directory, I need to `rsync` the files to the right directory:

```bash
rsync -avzhP /path/to/comitium/data/ /path/to/server/feed/data/
```

Now, what I'd like is running comitium on its own hostname, not inside my current capsule. In my case, I run it publicly on `gemini://feeds.gmi.bacardi55.io`. You can have a look at it if you want. So I need to copy the `feeds.gmi` file as an `index.gmi` file so it is delivered automatically by the server.

```bash
cp /path/to/server/feed/data/feeds.gmi /path/to/server/feed/data/index.gmi
```


Now that's cool, but adding and removing feeds with the long docker command, the cp and then running rsync is quite boring…

To simplify this, I created 2 bash functions in my `bashrc`:

```bash
comitium-add() {
  docker run --rm -v /path/to/comitium/data/:/data registry.local:5000/b55-comitium:latest comitium add "$1" -d /data
  rsync -avzhP /path/to/comitium/data/ /path/to/server/feed/data/
  cp /path/to/server/feed/data/feed.gmi /path/to/server/feed/data/index.gmi
}

comitium-remove() {
  docker run --rm -v /path/to/comitium/data/:/data registry.local:5000/b55-comitium:latest comitium remove "$1" -d /data
  rsync -avzhP /path/to/comitium/data/ /path/to/server/feed/data/
  cp /path/to/server/feed/data/feed.gmi /path/to/server/feed/data/index.gmi
}
```

And now, simply running `comitium-add <FeedUrl>` and `comitium-remove <FeedUrl>` to manage feeds.

Now, that's great but what we need to finish the setup is a cronjob to refresh the feeds. The simpler is instead of a bash function create a simple shell script that will do the necessary commands. Create the `comitium-refresh.sh` file with the following content:

```bash
#!/bin/bash

docker run --rm -v /path/to/comitium/data/:/data registry.local:5000/b55-comitium:latest comitium refresh -d /data
rsync -avzhP /path/to/comitium/data/ /path/to/server/feed/data/
cp /path/to/server/feed/data/feed.gmi /path/to/server/feed/data/index.gmi
```

Make it executable:

```bash
chmod +x /path/to/comitium-refresh.sh
```

Then `crontab -e` to add the job:
```cron
30 */6 * * * /path/to/comitium-refresh.sh > /tmp/cr.log 2>&1
```

And that should be it. Yes, I only update it every 6 hours, that is enough for me.


Configure your server to run the files as wished. In my case, I just added a second hostname in [gmnisrv](https://git.sr.ht/~sircmpwn/gmnisrv):

```config.ini
[gmi.bacardi55.io]
root=/data/gmi.bacardi55.io

[feeds.gmi.bacardi55.io]
root=/data/feeds.gmi.bacardi55.io
```

And that should be it (:.
