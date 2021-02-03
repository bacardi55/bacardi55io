---
title: "My Home Lab 2020, part 3: Docker Swarm setup"
date: 2020-03-27T16:43:22+01:00
tags:
- docker
- dockerswarm
- selfhosting
- homelab
categories:
- selfhosting
description: Initial Docker Swarm setup
---

# Introduction

## Context reminder

Today, a new part of my [homelab posts serie](/categories/homelab/) :). In the first post, I've explained [my architecture choices for my 4 Raspberry Pi cluster](/posts/2020/03/21/my-home-lab-2020-part-1-context-and-architecture-choices/). In the second, I've setup a [GlusterFS replicated volumes](/posts/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/) on all my servers in order to have a shared folders between them (so you don't care where containers are created).

In this post, I'll talk about the initial [docker swarm](https://docs.docker.com/engine/swarm/) setup.


## Assumptions

I have 4 Raspberry Pi, all having a `/mnt/cluster-data` [GlusterFS](http://gluster.org/) volume mounted so that any files in there will be replicated on all Pis.


As a reminder, my 4 Raspberry Pi are named `cell, ptitcell1, ptitcell2, ptitcell3`. For GlusterFS, they all have the same roles, but not for our docker swarm cluster, so pay attention to the servers name :).


For the rest of the article, you should have an understanding of what docker, containers or a cluster are. You should also know your way a little navigating in a linux terminal. If not, go read some documentation first :).



# Docker Swarm setup:

## Definition

**Docker Swarm**[^1]:
>  A swarm consists of multiple Docker hosts which run in swarm mode and act as managers (to manage membership and delegation) and workers (which run swarm services). A given Docker host can be a manager, a worker, or perform both roles.

**Docker Swarm Node(s)**[^1]:
>  A node is an instance of the Docker engine participating in the swarm.

**Docker Swarm Manager(s)**[^1]:
>  Dispatches units of work called tasks to worker nodes.

**Docker Swarm Worker(s)**[^1]:
>  Receive and execute tasks dispatched from manager nodes.


## My choices

I decided to setup a cluster with 1 manager node and 3 workers nodes. You can choose a different setup with multiple manager if you want but in this case adapt the following steps to your situation. I might later on change this, it isn't complex to add a new manager or workers later on if needed.


## Installation

Ok, let's go then :)

First, install docker on all the pi[^2]:
```bash
curl -sSL https://get.docker.com | sh;
sudo usermod -aG docker pi
```

Then, on the manager node (`cell` in my case):
```bash
docker swarm init --advertise-addr <CellIpAddress> --default-addr-pool 10.10.0.0/16
```
Replace `<CellIpAddress>` by the local IP address of your node manager.

The `--default-addr-pool` is optional and is needed only if it conflicts with other network[^3].


On all the other nodes of our cluster (for me: `ptitcell{1,2,3}`):
```bash
docker swarm join --token <token> <CellIpAddress>:2377
```
Replace `<CellIpAddress>` by the local IP address of your node manager.

And that should do it for basic setup, it's that simple :)

## Testing

Now, let's start a simple container to see if this is working as expected. Let's start a very simple container that create a simple webpage to visualize our containers. For this, we will use [alexellis2/visualizer-arm](https://github.com/alexellis/docker-swarm-visualizer).

```bash
docker service create \
  --name viz \
  --publish 8080:8080 \
  --constraint node.role==manager \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  alexellis2/visualizer-arm:latest
```

Now you can open a browser and go to `http://<CellIpAddress>:8080`

Finally, let's transform this in a `docker-compose.yml` as this will be the format I will use to define all my services later on.

I'm saving all my services config files (`docker-compose.yml`) in `/mnt/cluster-data/services-config/<nameOfTheService>`, so in this case, I'm creating a `/mnt/cluster-data/services-config/vizualizer/docker-compose.yml` with the following content:

```docker-compose.yml
version: "3"

services:
  viz:
    image: alexellis2/visualizer-arm:latest
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    ports:
      - "8080:8080"
    deploy:
      placement:
        constraints:
          - node.role == manager
```
And start it with the following command:

```bash
docker stack deploy viz -c /mnt/cluster-data/services-config/visualizer/docker-compose.yml
```

Now you can go back to `http://<CellIpAddress>:8080` to check if everything is still working!

```docker-compose.yml
...
  deploy:
    placement:
      constraints:
        - node.role == manager
```
↑ This part is to force the container to be started on the docker swarm manager node.


If everything is working fine, you now have a docker swarm cluster setup and ready to manage services! We'll go through this in our next post. In the meantime, you can stop and remove the `viz` stack:
```bash
docker stack rm viz
```


# To be Continued… :-)

Now we have a very basic docker swarm setup working and ready to manage stack, services and containers :) … But that will be in my next blog post where we'll start managing real services, with [traefik 2](https://docs.traefik.io) as a reverse proxy with automated redirection to https and automatic ssl via [letsencrypt](https://letsencrypt.org).

# In this blog posts serie:

You can follow all posts about my Home Lab setup on the [dedicated page](/pages/home-lab/).

In the Home Lab setup series:

# TODO

To be writen: Monitoring, Backups, Tests environment, …



[^1]: [Docker swarm documentation](https://docs.docker.com/engine/swarm/key-concepts/)
[^2]: Remember the tip using tmux synchronize-panes in [my previous blog post]() to launch commands on all servers at once :)
[^3]: In my case, to avoid conflicts with my wifi network IPs.
