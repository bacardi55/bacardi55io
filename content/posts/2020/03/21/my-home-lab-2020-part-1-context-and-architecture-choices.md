---
title: "My Home Lab 2020, part 1: Context and Architecture choices"
slug: my-home-lab-2020-part-1-context-and-architecture-choices
date: 2020-03-21T17:13:41+01:00
tags:
- homelab
- selfhosting
- raspberrypi
- docker
- dockerswarm
- glusterfs
categories:
- selfhosting
description: My Home Lab 2020, why and what...
---

# Context

At the end of last year, I decided to rebuild my home self hosting and home automation setup. The main reason was that it was starting to get old and was really becoming a mess due to creating it bit by bit and on the fly^^.

I had stopped hosting my services at home for some time (as I moved everything to digitalocean), but always wanted to switch back. I was a bit familiar with docker as this is what I use on my DO servlets but I had never used Docker Swarm or Kubernetes before and wanted to learn more one of them (to at least better grasp the concepts).

On the home automation part, it became way too complicated, mostly because I was learning at the time and was building it little by little. I had a old rpi2 B with [domoticz](https://github.com/domoticz/domoticz), a rpi3 with [kalliope](https://kalliope-project.github.io/) and [nodered](https://nodered.org/), … For those reading my blog back then, you are familiar with the voice assistant [Kalliope](https://kalliope-project.github.io/) that was the brain of my home and I was actively participating. One thing though… I noticed that I don't like to talk to a software, that I prefer an easy to access interface (web, app, cli, …) to do the action I wanted… And that I was more into automation than voice control.

Of course, this meant moving from a voice assistant centric architecture to an automation centric architecture…

Because my home automation system mostly sit on my "home lab" system that I wanted to redo, I've redone everything during end of December and January. The first part was setting up the home lab and will be split in a series of blog posts that you can follow [here](/categories/homelab/) about the basics setup :).

**Nota**: Don't get me wrong, I love [Kalliope](https://kalliope-project.github.io/) and was using it quite extensively for a while[^1]. But I must admit my needs and requirements has changed… Hence the re-architecture.


# My Architecture choices

As said, I've been using docker for some time now, but very "manually" or "handmade"… Meaning myself playing docker compose command on multiple hosts. I wanted to go to the next level during this reset and use my favorite hardware: raspberry pis :).


## Hardware: Raspberry Pi 3 and 4

As said above, the hardware is based on raspberry pis. I'm using 1 raspberry 3 and 3 raspberry pi 4 (4gb RAM) for my cluster (though it might be easier if you only 1 type of architecture, as the rpi 4 differ from the 3).

I've also bought 4 fast USB keys for the cluster storage.

And to push the nerdgasm to the limit, I purchased [this cluster case for 4 raspberry pis](https://www.amazon.com/GeeekPi-Cluster-Raspberry-Heatsink-Stackable/dp/B07MW24S61/ref=sr_1_5) to tidy up the installation. They are all connected via short ethernet cables to my Netgear router :-).


## Software selection

I've decided to go with the following stack:

### OS: Raspbian

I selected (as usual) [raspbian](https://www.raspbian.org/) as the OS for my raspberry pis (3 and 4s).

For a headless installation of raspbian, see my old post [here](/posts/2017/11/5/headless-raspberrypi-installation/).

I won't talk about how the post installation of raspbian for a server, there are plenty of guide on the internet for this :).


### Containers orchestration: Docker Swarm

This is where I spend most time thinking between [Kubernetes](https://kubernetes.io/) and [Docker Swarm](https://docs.docker.com/engine/swarm/)…

The "obvious" choice, if I wanted to have an architecture as close as what most advance containers users are doing, was [Kubernetes](https://kubernetes.io/) (or its lighter version [k3s](https://k3s.io/) perfect for raspberry pis :-)). But the reality is that I don't really need that level of complexity for what i'm doing and I'm not a devops / sysadmin[^2] at my job so it wouldn't help on my day to day job either to learn it.

The other choice was [Docker Swarm](https://docs.docker.com/engine/swarm/), which after reading about it seemed so much simpler than Kubernetes. It also seems that it is not that much use in big or complex architecture (at least not at K8s scale) but seems to do more than the job for my small and limited use case of homemade selfhoster :-).

So I made the choice of Docker Swarm last December…


### Shared File System: GlusterFS

Of course, the main issue when you talk about containers architecture is storage. When I was doing it the poorsman's way[^3] (aka, containers started via docker-compose command on the host directly), it was easy to bypass this issue by just using the local storage.

When you move to a real cluster architecture, meaning multiple servers, then you need to have a shared storage between these servers. And it's better if the storage is on a dedicated drive… This is why I purchased 4 100GB usb keys, to use them as a shared storage.

Now for the technology itself, I went with [GlusterFS](https://www.gluster.org/):
> Gluster is a free and open source software scalable network filesystem.

By using Gluster, I can create a shared folder (so all the usb keys will have a copy of it) and make sure that data are up to date on all raspberry pis :).

I use it both to store services definition (`docker-compose.yml`) and services data.


# To be Continued… :-)

To avoid having way too long blog post, I'll stop here for now that we have an idea of what will be the setup of my home lab! Next we'll go to actual setup of docker, docker-compose, docker-swarm and glusterFS.

[^1]: A good proof ot that is the [number of neuron](https://kalliope-project.github.io/neurons_marketplace.html) I've created for [Kalliope](https://kalliope-project.github.io/) over time :)
[^2]: I'm just an enthusiast selfhoster as a hobby, not a professional, which explains why I really don't know what I'm talking about :-).
[^3]: Not meant in a wrong way, but the way I was doing it was more the level 1 of managing docker container. I'm not saying I moved to 10 and achieve perfection, but I feel I'm more at 4 or 5 now :P
