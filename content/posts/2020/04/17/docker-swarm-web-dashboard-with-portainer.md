---
title: Docker swarm Web dashboard with Portainer
date: 2020-04-17T18:48:26+02:00
tags:
- dockerswarm
- portainer
- swarmservice
categories:
- selfhosting
description: Visualize and manage your docker swarm cluster with portainer
---

# Context

Today, a very quick blog post to continue the series of my [docker swarm services recipes](/categories/swarmservice/). If you haven't, I suggest reading some of my [my home lab](/pages/home-lab/) posts to give you an idea if you don't already have an understanding of a docker swarm architecture.

Today's "recipe" is for [Portainer](https://www.portainer.io/). For those living outside the docker world before, [Portainer](https://www.portainer.io/) is a web UI to manage docker containers (with or without swarm engine).

As indicated on their website:
Portainer[^1]:
>  Build and manage your Docker environments with ease today.

In a simple configuration with docker running standalone (meaning not with kubernetes or swarm mode), you can just run the portainer/portainer container on your server, but in a swarm mode, you need to deploy agents on each node that will communicate with portainer server.

# Installation

Create directory structure first, if you follow my filesystem structure[^2], just do:
```bash
mkdir /mnt/cluster-data/{containers-data,services-config}/portainer
```

Then, create the `/mnt/cluster-data/services-config/portainer/docker-compose.yml` file:

```docker-compose.yml
version: '3'

services:
  agent:
    image: portainer/agent
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
    networks:
      - agent_network
    deploy:
      mode: global
      placement:
        constraints: [node.platform.os == linux]

  portainer:
    image: portainer/portainer
    command: -H tcp://tasks.agent:9001 --tlsskipverify
    ports:
      - 9000:9000
      - 8000:8000 #changeme
    networks:
      - agent_network
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
    volumes:
      - /mnt/cluster-data/containers-data/portainer/:/data #changeme if you don't use this file structure

networks:
  agent_network:
    driver: overlay
```

Important piece are:

- Portainer agent is deployed globally (`mode: global`), this means that each node will have 1 instance of this container.
- Portainer server is deployed only on manager nodes.
- The constraints is just there to "look good", because I don't have anything else than linux platform anyway :p.


Deploy the stack:
```bash
docker stack deploy portainer -c /mnt/cluster-data/services-config/portainer/docker-compose.yml
```

You can then go to `http://<ClusterIPAddress:8000`, to create your user and configure portainer (select environment local and then create your user)

And stop it:
```bash
docker stack rm portainer
```

That's it for now, I did say it would be a very quick one :).


[^1]: [https://www.portainer.io/](https://www.portainer.io)
[^2]: [GlusterFS setup](/posts/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/)
