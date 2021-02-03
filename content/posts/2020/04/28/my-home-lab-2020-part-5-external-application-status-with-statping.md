---
title: "My Home Lab 2020, part 5: External application status with Statping"
date: 2020-04-28T19:00:43+01:00
tags:
- monitoring
- statping
- status
- selfhosting
- docker
- nginx
- homelab
categories:
- selfhosting
description: Or how to make sure your self-hosted applications are reachable for everyone
---

# Context

Today, a new article for my [Home Lab 2020 series](/pages/home-lab/) to talk about "external application status". What I mean by that, is having a simple tool that will check if your applications are responding by doing a simple http request to the applications.

**Attention**, this is not really a monitoring tool per say. It doesn't check each servers of the cluster resources or availability or any specific server check. It just send a simple http request to an endpoint and check if the service is still available.

In the case of a swarm cluster like me, having all services available does not mean that everything is working correctly on the cluster. For example, a non manager node (`ptitcell{1,2,3}`[^1]) could be down but all services still running. So while having that kind of external application monitoring is very important (simulate a user request), this is definitely not enough for a real monitoring of your cluster, this is why there will be a dedicated post about monitoring later on.

**Attention2**: To be effective, this verification should be done from a server that is not hosting the said services (Otherwise, if the cluster fails, the check won't happen and you won't receive alerts)! If you are selfhosting in your house like me, you should definitely think about hosting this tool outside of your network for better relevance (if not, there are multiple use cases where the check will be positive even though the apps are not reachable from the outside).
# Which tool or services?

There are multiple tools available online SaaS solution to do so (eg:[pingdom.com](https://pingdom.com)). But as you may have guessed, I also want a tool that can be self hosted and is of course opensource.

My requirements are dead simple:

- Opensource and can be selfhosted
- Check every X minutes my different applications
- Alert me when one goes down (or is up again)
- Provides a simple status page
- Provides some statistics (nice to have)



# Statping

I found the perfect tool for my use case: [statping](https://statping.com/)! Check the website for more information but it did answer my main requirements and more. With it, I:

- Have a dedicated status page showing status and some statistics of my services uptime
- Get an email alert when a service change status (up or down) (You can also configure other channel like telegram)
- Have a configurable health check, as I don't want to spam my server but just make sure regularly that the services are working
- Bonus: it checks the ssl certificate as well (useful when using letsencrypt to ensure they are still valid)

## Installation

As said above, it is better to install such a tool outside the "hosting network". Ideally, you could find a friend that agree to host your statping instance (and you could do the same for him) or use a hosting provider for that, some of them can be quite cheap. In my case, I already had a [digital ocean](https://www.digitalocean.com/) droplet with docker running on it (for some services still not self hosted) so I used it to install statping.

As this existing server of mine is not part of a swarm cluster, the installation will be different than usual for the home lab containers. In this case, I'm using docker-compose to run the containers and nginx as reverse proxy (as this is the existing reverse proxy on that server).

### Service definition

First, as usual, create the `/var/containers-data/statping/config/docker-compose.yml`[^2]:

```docker-compose
version: "3"

services:
  statping:
    container_name: statping
    image: hunterlong/statping:latest
    restart: always
    ports:
      - 8080:8080 #todo: changeme
    volumes:
      - /var/containers-data/statping/data:/app
    environment:
      DB_CONN: sqlite
```

Don't forget to create the volume directory, if you haven't change the docker-compose above:

```bash
mkdir -p /var/containers-data/statping/data/
```

### Nginx configuration

I won't go in this post into the global nginx configuration, just the setup of this particular rule. For this I created a new configuration file in `/etc/nginx/sites-enabled/` called `statping.domain.com.conf` (adapt for your domain of course :)) with the following content:

```nginx
upstream statping {
    server 127.0.0.1:8080; # change according to docker-compose.yml file.
}

map $http_upgrade $connection_upgrade {
  default upgrade;
  ''      close;
}

# Listen on http:
server {
  listen 80;
  listen [::]:80;
  server_name statping.domain.com; # changeme

  # For Let's encrypt:
  location /.well-known/acme-challenge {
    root /var/www/html/letsencrypt;
    index index.html;
  }

  # Redirection to https:
  location / {
    return 301 https://$host$request_uri;
  }
}

# Listen on https:
server {
  listen 443 ssl;
  listen [::]:443 ssl;
  server_name statping.domain.com; # changeme

  ssl on;
  ssl_certificate /etc/letsencrypt/live/statping.domain.coms/fullchain.pem; # changeme
  ssl_certificate_key /etc/letsencrypt/live/statping.domain.com/privkey.pem; # changeme
  ssl_trusted_certificate /etc/letsencrypt/live/statping.domain.com/chain.pem; # changeme

  ssl_protocols TLSv1.2;
  ssl_ciphers EECDH+AESGCM:EECDH+AES;
  ssl_ecdh_curve prime256v1;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;

  keepalive_timeout    70;
  sendfile             on;
  client_max_body_size 0;

  gzip on;
  gzip_disable "msie6";
  gzip_vary on;
  gzip_proxied any;
  gzip_comp_level 6;
  gzip_buffers 16 8k;
  gzip_http_version 1.1;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

  location / {
    proxy_pass         http://statping;
    proxy_redirect     off;
    proxy_set_header   Host $host;
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Host $server_name;
  }

  location /.well-known/acme-challenge {
    root /var/www/html/letsencrypt/;
    index index.html;
  }
}
```

You can then restart nginx:
```bash
sudo systemctrl restart nginx.service
```

Then generate the SSL certificate. If like me you are using certbot:
```bash
sudo certbot certonly --webroot -n -m your@email.com --agree-tos -w /var/www/html/letsencrypt/ -d statpint.domain.com
```

### Start/Stop the service

Then, inside the `/var/containers-data/statping/config/` directory, run:
```bash
cd /var/containers-data/statping/config/ && docker-compose up -d
```

and restart nginx:
```bash
sudo systemctrl restart nginx.service
```

If everything worked smoothly, you should be able to access statping from the url: `https://statping.domain.com`.

To stop the service:
```bash
cd /var/containers-data/statping/config/ && docker-compose down
```

Now, you can go to `status.domain.com` and should see the statping page. Connect with `admin/admin` and change the login and password right away before configuring anything else :).


## Configuration

First, go to the settings page to change the global settings like the page name, description, domain, …

If like me, only one message is enough to tell me a service is down (and not a message every X minutes telling me it is still down…), configure the notification for "updates only".

Then you can configure the notification system, I personally chose email for now, but I may switch to telegram at some point, as my [home automation](/categories/homeautomation/) system is based a lot around telegram as well…

After that, all you need is to configure Services (that can be grouped if needed for visibility). For example for testing this blog:

![Statping service config](/images/posts/2020/04/28/homelabp5/statpingservice.png "Statping service config")

Then you can enjoy a nice dashboard with some stats (uptime and response time):

![Statping dashboard](/images/posts/2020/04/28/homelabp5/statpingdashboard.png "Statping dashboard")

![Statping dashboard blog](/images/posts/2020/04/28/homelabp5/statpingdashboard2.png "Statping dashboard blog")

# Conclusion

That's it for now, I will write followup posts for "internal monitoring" (servers and containers) as well as backups, as this series is not over yet! :-)

You can follow all posts about my Home Lab setup on the [dedicated page](/pages/home-lab/).

[^1]: See my cluster [setup](/posts/2020/03/27/my-home-lab-2020-part-3-docker-swarm-setup/).
[^2]: Same warning as usual: either really understand the container your using by looking at the build file or build your own and manage your own docker registry!

*[SaaS]: Software as a Service
