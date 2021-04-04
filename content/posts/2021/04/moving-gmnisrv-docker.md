---
title: "Moving my gemini server gmnisrv to the my swarm cluster"
date: 2021-04-04T15:02:13+01:00
tags:
- homelab
- docker
- docker-registry
- selfhosting
- gemini
- gmnisrv
categories:
- selfhosting
---

## Context

Based on my previous post about [managing a local docker registry](https://bacardi55.io/2021/03/29/home-lab-part-8-create-a-local-docker-registry-to-manage-your-own-images/), as promised let's use it to create a useful image and deploy it on [my swarm cluster homelab](https://bacardi55.io/pages/home-lab/).

For this example, I've decided to use the latest image I've created: [gmnisrv](https://git.sr.ht/~sircmpwn/gmnisrv).

Wait what? Gmnisrv running on a docker swarm? Why??

There are no real good reason to have the gemini server as a docker service… So why? Well the real reasons? Because:
- I can :p;
- I have this docker swarm working very smoothly, so let's use it;
- I could have just installed it directly on one of the node, but that made not much sens;
- I can manage it as all the other services^^.

Last week, I made the change from the local installation on a test pi to the cluster, smoothly from what I've seen, without certificate change. But that's not the point of this article^^ (and TBH, I failed[^1] the weekend before :D).

## Installation

### Creating the image for the cluster

So first thing first, we need to create the image on the registry before being able to use it on the cluster. Feel free to refer to my post about [managing a local docker registry](https://bacardi55.io/2021/03/29/home-lab-part-8-create-a-local-docker-registry-to-manage-your-own-images/).

On the registry (in my case named `freeza`), let's create the image. Let's create a working directory:

```bash
mkdir ~/dockerfiles/gmnisrv && cd ~/dockerfiles/gmnisrv
```

Then, create the very simple `Dockerfile`:

```bash
FROM alpine:3.12

RUN apk add --no-cache git make scdoc openssl-dev build-base mailcap && \
    cd /tmp && \
    git clone https://git.sr.ht/~sircmpwn/gmnisrv && \
    cd gmnisrv && \
    mkdir build && \
    cd build && \
    ../configure --prefix=/usr && \
    make && \
    make install

VOLUME /certs
VOLUME /config
VOLUME /data

CMD ["gmnisrv", "-C", "/config/gmnisrv.ini"]
```

Very simple :-).

Then, let's try and build the image:

```bash
docker build .
```

If this works correctly, you can tag the image (I always prefix their name with `b55-`):

```bash
docker build . -t registry.local:5000/b55-gmnisrv:latest
```

Adapt with your registry hostname and port.

Push the image to the directory:

```bash
docker push registry.local:5000/b55-gmnisrv:latest
```

To test the image, you can either use `docker run` or `docker-compose`. Because I'm will use a docker-compose file on my cluster, I prefer testing it with a docker-compose file, buit this doesn't matter.

In my case, the local docker-compose.yml file is:

```docker-compose
version: '3'

services:
  gmnisrv:
    image: registry.local:5000/b55-gmnisrv:latest
    ports:
      - 1965:1965
    volumes:
      - /path/to/testdir/gmnisrv/data/:/data
      - /path/to/testdir/gmnisrv/config/:/config
      - /path/to/testdir/gmnisrv/certs:/certs
```

Then the usual `docker-compose up` to see if this works correctly (be sure to create the volumes if you want to try with it).

If you want to run a full test before deploying on your cluster, you can create a simple .gmi file in the /data/ directory, create a dev host in the gmnisrv config file (and edit your host file).


### Deploying it to the cluster

If everything work, we can use it on the cluster. Adapt a bit the docker file to have:

```yaml
version: '3'

services:
  server:
    image: registry.local:5000/b55-gmnisrv:latest
    ports:
      - "1965:1965"
    deploy:
      placement:
        constraints:
          - node.hostname == ptitcell2
    volumes:
      - /path/to/containers-data/gmnisrv/data/:/data
      - /path/to/containers-data/gmnisrv/certs/:/certs
      - /path/to/services-config/gmnisrv/config/:/config
```

Main difference the placement constraints to a specific node of the cluster. I could have use [traefik](https://traefik.io/traefik/) for load balancing the entry like I do for all services… But I didn't^^. I didn't see the point of adding load to traefik and the node manager for gmnisrv that works on a port that will only be used by gmnisrv. Gmnisrv support multi hosts anyway if I want to add capsules in the future (I'm planing to have a feed type of capsule).

So, long story short, I force the container to only work on the `ptitcell2` node. And I forward the 1965 port on my router to the `ptitcell2` node. I thus save a bit on the manager.

If you don't care by recreating new certs (if your capsule wasn't live yet), you can just start it like this, otherwise just copy/paste the certificates in the right folder before starting the stack with `docker stack deploy gmnisrv -c /path/to/services-config/gmnisrv/docker-compose.yml`.


And voilà :] Granted that I have close to no reader on my capsule, I can still say it has worked perfectly since then!

[^1]: In reality I failed for multiple reasons, but also discovered a bug in the latest version of gmnisrv. I fixed it with the help of [Drew Devault](https://drewdevault.com). Since then my patch has been accepted so even if what I wrote was the [simplest patch](https://git.sr.ht/~sircmpwn/gmnisrv/commit/8b65e303b01fc573cb1c40a365fb5db166146a37) in the history of patch, I'm still happy about it^^.
