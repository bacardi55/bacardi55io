---
title: "My Home Lab 2020, part 4: Running Services over https with Traefik"
date: 2020-03-30T13:22:08+01:00
tags:
- docker
- dockerswarm
- traefik
- selfhosting
- homelab
categories:
- selfhosting
description: Configuring Traefik with docker to manage services over https
---

# Introduction

## Context Reminder

New post about "[homelab](/categories/homelab/)" setup as promised [yesterday](/posts/2020/03/29/Simple-load-testing-using-siege/) :). You can read about [the architecture choices in part 1](/posts/2020/03/21/my-home-lab-2020-part-1-context-and-architecture-choices/). In [part 2](/posts/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/) I wrote about creating a shared storage via [GlusterFS](https://www.gluster.org) for our cluster and in [part 3](/posts/2020/03/27/my-home-lab-2020-part-3-docker-swarm-setup/) I explained how to create the [docker swarm](https://docs.docker.com/engine/swarm/) cluster.

## Assumptions

For this post, you should understand what are containers and have basic [docker swarm](https://docs.docker.com/engine/swarm/) concepts knowledge. It would also be better if you have an understanding of docker-compose.


## Ok, So what now?

The goal of this post is to be able to run containers on our cluster, behind https with a [letsencrypt](https://letsencrypt.org/) certificate.

To run containers on a docker swarm cluster, you can just create docker-compose.yml files like the example given in the [part 2](/posts/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/) and start them with `docker stack <serviceName> deploy -c </path/to/docker-compose.yml>` and that's it… But this would means running services on different port and accessing them directly with the IP address like we did for our visualizer (`http://<IpOfManagerNode>:8080`). This is because is just made to run the containers themselves, so containers needs to run and expose different ports. This is clearly not ideal to say the least :)

What we want instead, is the ability to run multiple containers, access them via (sub)domain(s) directly on port 443 (https) or 80 (http with a forced redirection to https). For example, I'm running this blog accessible at [https://bacardi55.io](https://bacardi55.io) and [gogs](https://gogs.io) for my git repository at [https://git.bacardi55.io](https://git.bacardi55.io), both running on this docker swarm cluster.

To do so, we basically need a router that will map incoming requests to the running containers… Enters [traefik 2](https://docs.traefik.io/) :)


# Installing and configuring Traefik

## Why Traefik 2

The reason I chose traefik was it simplicity and its native compliance with Docker Swarm. The "native compliance" means that by simply entering some configurations (`container labels`) in your docker-compose.yml files for the services you want to run, traefik will be automatically configured to route the requests accordingly! Isn't that great?

Obviously I over simplifying here on purpose, I suggest you read [traefik documentation](https://docs.traefik.io) (at least the [docker provider overview](https://docs.traefik.io/providers/docker/)) to understand more the concepts :)

## Configuration

Ok, so let's start by configuring traefik!

First, I created `/mnt/cluster-data/services-config/traefik/docker-compose.yml`:

```docker-compose.yml
version: '3'

services:
  reverse-proxy:
    image: traefik
    command:
      ###                          ###
      # Traefik Global Configuration #
      ###                          ###
      # Enable DEBUG logs, change this to INFO after initial successfull setup.
      - --log.level=DEBUG # DEBUG, INFO, etc...
      - --ping=true
      # Enable api access without authentification (only GET route so it only possible to get IPs)
      - --api.insecure=true # You can insecure here, because It accessible only in the container if you didn't open the port.
      # Set the provider to Docker
      - --providers.docker=true
      # Set to docker swarm cluster
      - --providers.docker.swarmMode=true
      # If False : Do not expose containers to the web by default
      - --providers.docker.exposedByDefault=false
      # Default rule to service-name.example.com
      - --providers.docker.defaultRule=Host(`{{ trimPrefix `/` .Name }}.youdomain.com`)
      # Default https port
      - --entrypoints.https.address=:443
      #- --entrypoints.https.tls=true
      # Default http port
      - --entrypoints.http.address=:80
      # Enable let's encrypt
      - --certificatesresolvers.le.acme.httpchallenge=true
      - --certificatesresolvers.le.acme.httpchallenge.entrypoint=http
      - --certificatesresolvers.le.acme.email=<your@email.com>
      - --certificatesresolvers.le.acme.storage=/letsencrypt/acme.json
      # For testing:
      #- --certificatesresolvers.le.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory
    networks:
      - traefik-net
    ports:
      # The HTTP port
      - 80:80
      # The HTTPS port
      - 443:443
      # The Web UI (enabled by --api.insecure=true)
      - 8080:8080 # Remove it once you've tested everything
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
      - /mnt/cluster-data/containers-data/traefik/acme.json:/letsencrypt/acme.json
    deploy:
      placement:
        constraints:
          - node.role == manager

networks:
  traefik-net:
    external: true
```

The comments included should help you configure your docker-compose file. The important part are:

- **The Network**: The is very important, all services that will need to be expose via traefik will need to use this network. Network needs to be external. To create the network, this simple command will do: `docker network create -d overlay --attachable traefik-net`;
- `--providers.docker.defaultRule=Host(`{{ trimPrefix `/` .Name }}.youdomain.com`)` allow to automatically create rules so that if you create an exposed service called `blog` for example, traefik will automatically create the ssl certificate for `blog.yourdomain.com` and expose the service at this address.

If you use the same configuration for letsencrypt storage as above, you will need to create the file `/mnt/cluster-data/containers-data/traefik/acme.json`[^1] and then put the right permission on it:

```bash
mkdir -p /mnt/cluster-data/containers-data/traefik/
touch /mnt/cluster-data/containers-data/traefik/acme.json
chmod 600 /mnt/cluster-data/containers-data/traefik/acme.json
```

## Start Traefik

Now we can simply start traefik by deploying this stack:

```bash
docker stack deploy traefik -c /mnt/cluster-data/services-config/traefik/docker-compose.yml
```

To make sure it is working correctly, go to `http://<ManagerNodeIpAddress:8080` (or adapt if you change the port). You should see traefik dashboard. If that's the case, it means it was launched successfully. If not, you can look at the logs:

```bash
docker service logs -f traefik_reverse-proxy
```

If there is no log, check that a container is actually running:

```bash
docker service ps traefik_reverse-proxy --no-trunc
```

*Nota*: Don't forget to remove the Web UI port so it stay secure once everything works fine. We'll see in another post how to use it in a secure manner. Once everything works fine, you should also move to a INFO log level.


# Installing our first service

Ok, so now we have traefik running and acting as a router and SSL provider for our services… But we still don't have any services running (except traefik but that doesn't do much yet)…

So we will start simply by creating a service running nginx serving html files (eg: for a static blog like this one).

I'm planing to write about services I manage and thus have a library of services ready to use for the different tools I'm running.


So for this first service, we will have a simple nginx server that will serve a static site over http ("internally" in our cluster network). It will also configure traefik to listen (externally) to http and https requests, http requests will be automatically redirected to https that will have a valid ssl/tls certificate obtained via letsencrypt. Requests recieved for this service will be redirected automatically internally to our nginx container on port 80.

And all this will be done simply via the `docker-compose.yml` file :)

I'm keeping my usual structure for files:
```bash
mkdir /mnt/cluster-data/services-config/myWebSite # Create the directory for the docker-compose.yml file.
mkdir /mnt/cluster-data/containers-data/myWebSite # Create the directory that will contain the html.
```

If you don't have a static site to use, you can create a simple `index.html` file (inside the `…/containers-data/myWebSite` directory) with some simple basic html and content in it. Otherwise, just copy your site (using `scp` or other) in the directory.

Now we need to define our service, so create the file `/mnt/cluster-data/services-config/myWebSite/docker-compose.yml` with the following content:

```docker-compose.yml
version: '3'

services:
  web:
    image: nginx
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.routers.web.rule=host(`domain.com`)
        - traefik.http.routers.web.entrypoints=http
        - traefik.http.services.web-service.loadbalancer.server.port=80
        # for https:
        - traefik.http.routers.web-secure.rule=host(`domain.com`)
        - traefik.http.routers.web-secure.entrypoints=https
        - traefik.http.routers.web-secure.tls=true
        - traefik.http.routers.web-secure.tls.certresolver=le
        - traefik.http.middlewares.web-redirect-web-secure.redirectscheme.scheme=https
        - traefik.http.routers.web.middlewares=web-redirect-web-secure
      placement:
        constraints:
          - node.role == worker
    networks:
      - traefik-net
    volumes:
      - /mnt/cluster-data/containers-data/myWebSite/:/usr/share/nginx/html/

networks:
  traefik-net:
    external: true
```

The `deploy` part of the configuration of the service allow you to specify configuration related to the deployment and run of your service[^2].

The `placement` configuration allows to define rules to where container(s) needs to be deployed[^3]. In this case, I want it to be deployed on a worker node (meaning in my setup, not on the manager `cell`, but on any of the `ptitcell{1,2,3}`).

The `labels` allow to specify labels for the service. In our case, this is how we can give instruction to configure traefik accordingly. Let's see in more details (read the comments):

```docker-compose
version: '3'

services:
  web:
    ...
    deploy:
      labels:
        # Tell traefik that this containers will be available through traefik.
        - traefik.enable=true
        # Indicates condition in which the request should be send to this container.
        # In this case base on the domain[^4].
        - traefik.http.routers.web.rule=host(`domain.com`)
        # Accept http (port 80) requests
        - traefik.http.routers.web.entrypoints=http
        # Tells traefik that this container (nginx) listen on port 80,
        # so traefik can send the request accordingly.
        - traefik.http.services.web-service.loadbalancer.server.port=80
        # for https:
        # Same as for http, rules to match the request for this service.
        - traefik.http.routers.web-secure.rule=host(`domain.com`)
        # Accept https (port 443) requests
        - traefik.http.routers.web-secure.entrypoints=https
        # Enable https
        - traefik.http.routers.web-secure.tls=true
        # Indicates that letsencrypt ssl provider (certresolver)
        # will be used (defined in our traefik configuration).
        - traefik.http.routers.web-secure.tls.certresolver=le
        # Define a middleware[^5] to redirect http requests (router `web`)
        # traefik to https (router `web-secure`).
        - traefik.http.middlewares.web-redirect-web-secure.redirectscheme.scheme=https
        # Indicate traefik to use the middleware when http requests (on routers `web`)
        # are recieved.
        - traefik.http.routers.web.middlewares=web-redirect-web-secure
```

And don't forget to link the traefik network so the containers can talk to each other:

```docker-compose
version: '3'

services:
  web:
    ...
    networks:
      - traefik-net
...

networks:
  traefik-net:
    external: true
```

So now, all we need is to deploy the stack on our cluster, for this, a simple command will do:
```bash
docker stack deploy website -c /mnt/cluster-data/services-config/myWebSite/docker-compose.yml
```

**/!\ Watch out /!\ **: You need to make sure before deploying the stack that your domain DNS is configure correctly (as your network router to redirect http and https traefik to your cluster). If you don't configure your DNS before, traefik will fail generating the SSL certificate (multiple times in a row) and you'll end up being banned by letsencrypt (for 1h) for too many failed attempt (so test before and make sure you get a 404 from your cluster - meaning the domain is rightly configure to point to your cluster - before starting the service!).


If everything works correctly, you should be able to go to https://domain.com and see your website.

**Nota**: If you don't use a local dns server (like dnsmasq - prefered option) or a VPN, you might not be able to reach domain.com from the local network, in this case, add an entry in your host file `/etc/hosts` with the IP of your cluster manager and the domain, eg: `10.0.0.200  domain.com`. If you choose the last option and edit your hosts file, you will need to remove this line once testing from an external network (try it while sharing your phone connection for example :)).


And if you want to stop it:
```bash
docker stack rm website
```


# A quick skeleton

You can use this skeleton when creating new services that you want expose to the world via your traefik reverse proxy:

```docker-compose
version: '3'

services:
  web:
    image: <image>
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.routers.<service>.rule=host(`<domain>`)
        - traefik.http.routers.<service>.entrypoints=http
        - traefik.http.services.<service>-service.loadbalancer.server.port=<port>
        # for https:
        - traefik.http.routers.<service>-secure.rule=host(`<domain>`)
        - traefik.http.routers.<service>-secure.entrypoints=https
        - traefik.http.routers.<service>-secure.tls=true
        - traefik.http.routers.<service>-secure.tls.certresolver=le
        - traefik.http.middlewares.<service>-redirect-<service>-secure.redirectscheme.scheme=https
        - traefik.http.routers.<service>.middlewares=<service>-redirect-<service>-secure
      placement:
        constraints:
          - node.role == worker
    networks:
      - traefik-net
    volumes:
      -

networks:
  traefik-net:
    external: true
```

By using this, I can then quickly search and replace the different `<config>` to change (`<domain>`, `<image>`, `<service>` and `<port>`) and have my service configured for traefik. Quick and easy :-) !.

*Nota*: This is a very basic and simple configuration, we could add more stuff but that is enough for now :).
*Nota2*: We'll see in a future blog post how to automate the deployment of a static site instead of just doing a scp :).


# To be Continued… :-)

That's it for now, we have our site running over https thanks to traefik and letsencrypt. All that done only via creating docker-compose.yml files :-). We'll see in future posts other services that I host and share the docker-compose.yml files associated.


[^1]: I split configuration files and data into 2 directory. I could have inside each services directory a config and a data folder but I prefer like this.
[^2]: [https://docs.docker.com/compose/compose-file/#deploy](https://docs.docker.com/compose/compose-file/#deploy)
[^3]: [https://docs.docker.com/compose/compose-file/#labels-1](https://docs.docker.com/compose/compose-file/#labels-1)
[^4]: [https://docs.traefik.io/routing/routers/#rule](https://docs.traefik.io/routing/routers/#rule)
