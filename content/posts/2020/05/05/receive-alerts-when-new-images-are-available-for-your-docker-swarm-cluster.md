---
title: Receive alerts when new images are available for your docker swarm cluster with Diun
date: 2020-05-05T15:41:52+01:00
tags:
- docker
- dockerswarm
- swarmservice
- diun
- monitoring
- selfhosting
categories:
- selfhosting
description: Or make sure you are using up to date services.
---

# Context

Today, a quick post about [Diun](https://github.com/crazy-max/diun), a nice tool that alerts you when new docker images are available for your services. It works with docker hub (obviously) but also with alternate / private docker registry (eg: if you have automation for building images).

I'm in a middle of a bigger article about keeping your cluster up to date that will talk about my usage of [Diun](https://github.com/crazy-max/diun), but I thought I would first write about the installation and usage before going into the bigger picture of having an up to date cluster.

**Nota**: I know there are great tools like [WatchTower](https://containrrr.github.io/watchtower/) that will not only check for new version of containers' images but also update them automatically. But I don't like this solution as I prefer choosing myself when and how to upgrade (and what to backup first :)). That also allows me to potentially test on another environment first before running it on my production.


# Diun

As stated above, Diun is a simple yet powerful tool that will check every defined period (configurable) if new versions of the images you are using exist and then alert you in a lot of possible way.

## Docker swarm service

Diun can work in a docker container too and is compatible with bare docker or docker swarm :-). So as usual, we're going to create a docker swarm service for it. First, create the directory structure. If you follow mine[^1]:

```bash
mkdir /mnt/cluster-data/{services-config,containers-data}/diun/
mkdir /mnt/cluster-data/containers-data/diun/data
```

Then, create the service definition file `/mnt/cluster-data/services-config/diun/docker-compose.yml`:

```docker-compose.yml
version: "3.2"

services:
  diun:
    image: crazymax/diun:latest
    volumes:
      - "/mnt/cluster-data/containers-data/diun/data:/data" # Adapt if needed.
      - "/mnt/cluster-data/containers-data/diun/diun.yml:/diun.yml:ro" # Read Only on config file.
      - "/var/run/docker.sock:/var/run/docker.sock"
    environment:
      - "TZ=Europe/Paris" # Adapt.
      - "LOG_LEVEL=info"
      - "LOG_JSON=false"
    deploy:
      placement:
        constraints:
          - node.role == manager
```

*Nota*: Usual warning: When using containers, you should either build your own or at least have a very good understanding of how the public image you use is built and what it does before using it. Using unknown containers on your platform is a security risk!

## Configuration

Before actually running the service, we need to create the configuration file. If you didn't change the above `docker-compose.yml`, create the file `/mnt/cluster-data/containers-data/diun/diun.yml`:

```diun.yml
db:
  path: diun.db

watch:
  workers: 4
  schedule: "0 * * * *"
  first_check_notif: true

notif:
#  mail:
#    enable: false
#    host: localhost
#    port: 25
#    ssl: false
#    insecure_skip_verify: false
#    username:
#    password:
#    from:
#    to:
  webhook:
    enable: true
    endpoint: http://<IPNodeRed>:<PortNodered>/api/cluster/update
    method: GET
    headers:
      Content-Type: application/json
    timeout: 10

providers:
  swarm:
    # Watch all services on local Swarm cluster
    swarm55:
      watch_by_default: true
```

[Look at the documentation](https://github.com/crazy-max/diun/blob/master/doc/configuration.md) for additional details, but in a nutshell:

- `db`: indicate the path to diun.db (in the end will be in the data containers we created above)
- `watch`: define how many workers can run at the same time (here 4) and when to run the checks. It is a [cron expression](https://godoc.org/github.com/robfig/cron#hdr-CRON_Expression_Format) so should be easy to understand :). In this example, it runs every hours.
- `notif`: Tell diun how to tell you a new image is ready. The simplest way is to use emails or telegram, that's why I left the email config part here. I use the webhook system only, as part of my [home automation](/pages/home-lab/) so that diun send an alert to [NodeRed](https://nodered.org/) that will then include that in my more global flow of releases check, but more on that in the next post :).
- `providers`: This is where you tell diun to listen to the swarm cluster and look at all images updates (`watch_by_default: true`). If you want to explicitly tell diun which images to check, set the watch_by_default to false and then use labels in service definition (docker-compose.yml) as described [here](https://github.com/crazy-max/diun/blob/master/doc/providers/docker.md#configuration). I'm lazy so I just check everything.


Again, I strongly recommend to look at the [configuration documentation](https://github.com/crazy-max/diun/blob/master/doc/configuration.md) for additional details, as all options are explained explicitly :).


## Start the service

As usual, quite simple:
```bash
docker stack deploy diun -c /mnt/cluster-data/services-config/diun/docker-compose.yml
```

If you kept the `first_check_notif: true`, you should receive notification if any services is not using the latest images available. If you didn't get any alert, check the logs, maybe everything is up to date:

```bash
docker service logs -f diun_diun # Adapt service name if needed.
```

And to stop the service:
```bash
docker stack rm diun
```

# Conclusion

That's it for now, we'll see in the next post how I use Diun and other tools to stay alerted of new version of the software I use.

You can follow all posts about my Home Lab on the [dedicated page](/pages/home-lab/).

[^1]: See [this post](/posts/2020/03/27/my-home-lab-2020-part-3-docker-swarm-setup/).
