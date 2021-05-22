---
title: "Using multiple traefik middlewares using docker labels"
date: 2021-04-11T21:02:13+02:00
tags:
- homelab
- docker
- selfhosting
- traefik
categories:
- selfhosting
---

Quick post today just to highlight how to use multiple middlawares in a traefik configuration. I realized that I haven't posted about it and all example I gave always used 1 middleware to redirect http to https. Today, let's use more :).

For this example, I'm going to install [homer](https://github.com/bastienwirtz/homer) (the very simplistic personal dashboard page). I used to have [Heimdall](https://heimdall.site) installed on my cluster before [the crash](https://bacardi55.io/2021/03/07/rca-of-my-homelab-cluster-downtime/), but I never really used it. That's because I thought it was too heavy for my need to be honest.

I decided to switch to homer because it is very lightweight and simple[^1] but this is not the goal of this post.

If I take the previous configuration shown, the "default" docker-compose would be:

```docker-compose.yml
version: "3"

services:
  homer:
    image: b4bz/homer
    networks:
      - traefik-net
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - /path/to/containers-data/homer/data:/www/assets
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.services.dashboard-service.loadbalancer.server.port=8080
        - traefik.http.routers.dashboard.rule=Host(`homer.domain.tld`)
        - traefik.http.routers.dashboard.entrypoints=http
        # For https:
        - traefik.http.routers.dashboard-secure.rule=Host(`homer.domain.tld`)
        - traefik.http.routers.dashboard-secure.entrypoints=https
        - traefik.http.routers.dashboard-secure.tls=true
        - traefik.http.routers.dashboard-secure.tls.certresolver=le
        - traefik.http.middlewares.dashboard-redirect-dashboard-secure.redirectscheme.scheme=https
        - traefik.http.routers.dashboard.middlewares=dashboard-redirect-dashboard-secure
      placement:
        constraints:
          - node.role == worker

networks:
  traefik-net:
    external: true
```

But this only use one middle. To use multiple ones, we need to use a middleware chain instead of just a declared middleware.

In this example, I'm just going to add a basic http authentication. But this works the same if you added more like rate limiting and such.

Before editing the docker-compose file, we need to generate a user/password for the basic auth. Obviously, it is better to use a file to manage the credential (if you have more than one user at least), but for the sake of example, it is simpler that way.

To create the user/password information, use this command line (from the traefik documentation). You need `apache2-utils` for the `htpasswd` command on debian like distribution.

```bash
echo $(htpasswd -nb user password) | sed -e s/\\$/\\$\\$/g
```

The sed part is to double the `$` sign as traefik needs it.

Then, edit the deploy part of the docker-compose file like this:

```docker-compose.yml
    deploy:
      labels:
        - traefik.enable=true
        - traefik.http.services.dashboard-service.loadbalancer.server.port=8080
        - traefik.http.routers.dashboard.rule=Host(`homer.domain.tld`)
        - traefik.http.routers.dashboard.entrypoints=http
        # For https:
        - traefik.http.routers.dashboard-secure.rule=Host(`homer.domain.tld`)
        - traefik.http.routers.dashboard-secure.entrypoints=https
        - traefik.http.routers.dashboard-secure.tls=true
        - traefik.http.routers.dashboard-secure.tls.certresolver=le
        - traefik.http.middlewares.dashboard-redirect-dashboard-secure.redirectscheme.scheme=https
        # We don't declare just a middleware here.
        #- traefik.http.routers.dashboard.middlewares=dashboard-redirect-dashboard-secure
        # HTTP auth:
        # This is were you need to paste the result of the command above:
        - "traefik.http.middlewares.dashboard-auth.basicauth.users=<user>:<GeneratedPasswordAbove>"
        # Declaring the middleware chain:
        - traefik.http.routers.dashboard-secure.middlewares=secured
        # Add all middlewares in the chain:
        - traefik.http.middlewares.secured.chain.middlewares=dashboard-redirect-dashboard-secure,dashboard-auth
```

If you need to add more, just add to the chain middlewares last line all the middlewares needed.

And voilà! As said, very short example of using a chain middlewares :).


[^1]: And if I'm not mistaken, the main developer is someone I used to work with and appreciate^^.
