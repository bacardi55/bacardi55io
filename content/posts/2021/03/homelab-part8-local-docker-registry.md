---
title: "Home Lab part 8: Create a local docker registry to manage your own images"
date: 2021-03-29T23:15:13+01:00
tags:
- homelab
- docker
- docker-registry
- selfhosting
categories:
- selfhosting
description: Manage a local docker registry
---

## Why a local registry?

This is a good question and there are many answers to this. But for me the main reasons is that I like be "in control" of some of the containers I'm running. I don't create my own images for everything at all, but I do use a mix of both. For very well known applications like traefik, nginx, mariadb, postgresql, … I usually use public images. Sometimes, for specific services/applications I either don't find an offical arm images (Needed for rpi), or sometimes I may not like how these official images are built.

As I said many times in previous post, you should always be very aware of how the containers you use are built and configured. And when in doubt or need, build your own and keep the whole thing under control :-). I use only public images in my posts mainly for simplicity (and because I don't publish my images outside my private registry).

In this post, I'll explain how to setup a registry on my local network for reuse on my cluster. In the next one, I'll show a real use case I'm using. In a later post, I'll talk about automation around image creation.

## Creating a local docker registry

### My choices

- Only available on my local network, which is why:
  - I won't add (for now at least) HTTP authentication;
  - I use a self-signed certificate (and not letsencrypt or others);
- Setup on a dedicated "non prod" raspberry pi (named `freeza`[^1]);
- Only ARM containers (not multi architecture… yet).

**Assumptions**: This article assume you already have a server setup with docker installed. And in my case, on a rpi not in the swarm cluster.

### Creating the registry

First, add your domain to `/etc/host` if you are using a fake domain (and no local dns server). In this example, I'm using `registry.local`.

Then create the working directory, here I named it `docker-registry`:

```bash
mkdir docker-registry && cd docker-registry
```

Create the `docker-compose.yml` file:

``` docker-compose.yml
version: '3'

services:
  registry55:
    restart: always
    image: registry:2
    ports:
      - "5000:5000" # ChangeMe
    environment:
      - REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.local.crt
      - REGISTRY_HTTP_TLS_KEY=/certs/registry.local.key
    volumes:
      - ./registry:/var/lib/registry
      - ./registry-config/config.yml:/etc/docker/registry/config.yml
      - ./certs:/certs
    networks:
      - registry-ui-net
```

Configure the registry by creating the `registry-config/config.yml` file:

```config
version: 0.1
log:
  fields:
    service: registry

storage:
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry

http:
  addr: :5000 # ChangeMe
  headers:
    X-Content-Type-Options: [nosniff]
```

Changed the port if you wish.

Then, create the directory for the certiticats and the registry:
```bash
mkdir {certs,registry}
```

For other servers to leverage your local registry, it needs to work via HTTPS, so we need to create the certificate:

```bash
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/registry.local.key -x509 -days 365 -out certs/registry.local.crt
```

For the FQDN, use the domain set above in the `docker-compose.yml`.


#### Testing

Let's test with a simple alpine image. We'll see in the next post a real use case.

```bash
docker pull alpine:3.13
```

Let's tag the image now. When the first part of the tag is a hostname and port, Docker interprets this as the location of a registry, when pushing.

For my local images, I always start their name with `b55-`, but this is just my own convention :).

```bash
docker tag alpine:3.13 registry.local:5000/b55-alpine-313
```

Push the image to the local registry running at `registry.local:5000`:

```bash
docker push registry.local:5000/b55-alpine-313
```

Remove the locally-cached alpine image, so that you can test pulling the image from your registry. This does not remove the registry.local:5000/ image from your registry.

```bash
docker image remove alpine:3.13
docker image remove registry.local:5000/b55-alpine-313
```

Then pull the image from the registry to see if it's working.

```bash
docker pull registry.local:5000/b55-alpine-313
```

It should pull the image :).

### Using images from the local registry on others servers

Now, to pull images from the registry on others servers, we will need to add the certificate to these servers. This is because we are using a self-signed certificate. But to be honest, for a local service, I don't see the point of the hassle of getting one from letsencrypt or others.

We just need to add the certificate to the docker configuration.

To do so, copy the created crt file above to the other servers that will need it (via `scp` for example). Place the file in `/etc/docker/certs.d/registry.local:5000`. Adapt with the right hostname and ports.

Be Careful, the files needs to be named `ca.crt`!

You may need to create the `certs.d` directory if it doesn't exist yet.

```bash
mkdir -p /etc/docker/certs.d/registry.local:5000
scp user@server:/path/to/registry.local.crt /etc/docker/certs.d/registry.local:5000/ca.crt
```

You now need to restart docker:

```bash
sudo systemctl restart docker.service
```

**Nota**: You need to add the certificate to all your docker swarm nodes. As any of the nodes could need to pull one of the local registry images[^2].

Then, you can try pulling the image, with as usual:

```bash
docker pull registry.local:5000/b55-alpine-313
```

And it should pull the image :).

### Registry UI?

There are many docker registry web UI available. Seems that the most maintained and popular one is [Joxit's one](https://github.com/Joxit/docker-registry-ui). I let you test it because on my end I don't care about a web UI for my registry, and instead I prefer a CLI app: [reg](https://github.com/Joxit/docker-registry-ui).

Reg is very nice and light. I installed it on my laptop but I could have installed it directly on the rpi managing the registry. I might do it to so I always have it where the registry is. But in the meantime, the installation was very fast. Just download the right release and make the binary executable (and available in your `$PATH`).

Only drawback of using reg is that there is no way of ignoring TLS validation, so when using a self-signed tls certificate like me, it means you need to add the certificate to your system configuration. So on the machine you are using reg, you need to add the crt file in `/usr/share/ca-certificates/` and then run (as root or sudo) `update-ca-certificates`.

Then a simple `reg ls registry.local:5000` will list the available images. `reg -h` to see all available commands, and voilà!



In the next post, I'll show some useful example and usage on the cluster :).



[^1]: This is the villain before `cell` in the manga Dragon Ball. Because my cluster nodes are named cell (manager) and ptitcellX (workers), I decided to named the preprod node with the name of the previous villain…

[^2]: As always, `tmux` and its `synchronize-panes` is really helpful :).
