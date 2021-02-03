---
title: Manage your personal project todos with Kanboard and Docker Swarm
date: 2020-04-03T22:29:42+01:00
tags:
- dockerswarm
- kanboard
- traefik
- kanban
- swarmservice
categories:
- selfhosting
description: Deploying Kanboard on a docker swarm raspberry pi cluster
---

# Context

Today, a quick post a about [kanboard](https://kanboard.org), a simple yet powerful [Kanban](https://en.wikipedia.org/wiki/Kanban_(development)) tool. It is not per say part of my [home lab](/categories/homelab/) series but is linked as the idea is to explain my config for running it on my docker swarm cluster. I'm planning to do small posts like this to basically create a [list of "recipes"](/categories/swarmservice/) of how I run my apps on [my raspberry pi cluster](http://localhost:8000/posts/2020/03/21/my-home-lab-2020-part-1-context-and-architecture-choices/).

Quoting wikipedia, a [Kanban](https://en.wikipedia.org/wiki/Kanban_(development)) is:
>   Kanban (Japanese 看板, signboard or billboard) is a lean method to manage and improve work across human systems.[…]

>   Work items are visualized to give participants a view of progress and process, from start to finish—usually via a Kanban board.[…]

>   In knowledge work and in software development, the aim is to provide a visual process management system which aids decision-making about what, when, and how much to produce.

In simplified term (too simplified), it is a project management methodology that consists of using a visual boards (physic or virtual) to manage the different tasks of a projects and track their status.

You manage the different tasks status in column and then create items and move them from column to column when working on them.

There are a lot of way of using the kanban methodology in projects, specially when using [Agile methodology](https://en.wikipedia.org/wiki/Agile_software_development). I don't want to go in details about this here as this is clearly not the goal of this post.

At a personal level, I'm using Kanboard to simply manage my personal projects todo and tasks. I have for example a «devops / Home automation» project with all the things I need to do or another for writing blog posts. (I've also linked [nodered](https://nodered.org/) with [kanboard api](https://docs.kanboard.org/en/latest/api/index.html) to automate some tasks creation, but more on that later when I'll write about my home automation system :-)).

Let's see a quick screenshot of my dashboard:

![My kanboard for devops & home automation](/images/posts/2020/04/03/kanboard/myboard-small-ano.png "My kanboard for devops & home automation")

Here we can see the backlog of ideas on the left, the tasks ready to be started (column ready), the list of bugs and enhancement (I prefer separating them from the new things in the ready column), items i'm currently working on and the finished tasks. For me, this is a great way of managing and keeping track of things that needs to be done (or are already done). I'm using it in its most simplistic way and you could obviously working with it in teams and leverage a lot more features than me :-). Each project can have a different configuration, so my blog posts kanboard have only the following column: backlog, work in progress, proof reading, to be published and published. This is really a great tool, it works for simple or complex kanban flows and teams and don't see a better way (**for me!**) to manage my ideas and projects tasks :).

I let you read the [website](https://kanboard.org) and the [documentation](https://docs.kanboard.org/en/latest/) to get a better understanding of what you can do with it!

# Configuration

If you follow my [homelab setup](/categories/homelab/), you are familiar with the [Gluster shared volume](/posts/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/) and the directory structure for my cluster.

Configuration directory is `/mnt/cluster-data/services-config/kanboard/` and data directory is `/mnt/cluster-data/containers-data/kanboard/`

Create the file `/mnt/cluster-data/services-config/kanboard/docker-compose.yml`[^1]:
```docker-compose.yml
version: '3'

services:
  kanboard:
    image: kanboard/kanboard
    volumes:
     - /mnt/cluster-data/containers-data/kanboard/data:/var/www/app/data
     - /mnt/cluster-data/containers-data/kanboard/plugins:/var/www/app/plugins
    networks:
      - traefik-net
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.services.kanboard-service.loadbalancer.server.port=80
        - traefik.http.routers.kanboard.rule=Host(`kanboard.domain.com`)
        - traefik.http.routers.kanboard.entrypoints=http
        # For https:
        - traefik.http.routers.kanboard-secure.rule=Host(`kanboard.domain.com`)
        - traefik.http.routers.kanboard-secure.entrypoints=https
        - traefik.http.routers.kanboard-secure.tls=true
        - traefik.http.routers.kanboard-secure.tls.certresolver=le
        - traefik.http.middlewares.kanboard-redirect-kanboard-secure.redirectscheme.scheme=https
        - traefik.http.routers.kanboard.middlewares=kanboard-redirect-kanboard-secure
      placement:
        constraints:
          - node.role == worker

networks:
  traefik-net:
    external: true
```

**Nota**: In this case, I'm using the official docker image from the kanboard project. When using an image that you did not create yourself, you must look into the docker build files ([here for kanboard](https://github.com/kanboard/kanboard/blob/master/Dockerfile)) before using it! It is even better to generate your own images instead of using custom non trusted one (for now I often use my own with my own registry but don't publish the build files, *yet* :-)).
# Running the service

As usual:
```bash
docker stack deploy kanboard -c /mnt/cluster-data/services-config/kanboard/docker-compose.yml
```

Then go to `https://kanboard.domain.com` and you should see the kanboard page, follow the instruction and read the documentation if needed :).

**NOTA**: As usual, before deploying your stack, make sure the selected domain DNS (in this example kanboard.domain.org) are correctly configured so that the letsencrypt challenge can be completed and your TLS certificate generated. You can check by going to the domain from outside your home network (if you are selfhosting). You should get a 404 from your traefik container. If you start the container without the domain DNS configured, then you will get banned from letsencrypt for 1h.

And stopping it:
```bash
docker stack rm kanboard
```

[^1]: Looks pretty similar as the template defined in my [homelab blog post part 4](/posts/2020/03/30/my-home-lab-2020-part-4-running-services-over-https-with-traefik/) :)
