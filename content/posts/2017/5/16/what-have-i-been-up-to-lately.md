---
title: What have I been up to lately
date: 2017-05-16
tags:
- docker
- selfhosting
---


# Still alive ?

Yes! I know I've posted a lot in January / February and disappeared a bit after that ^^.
I have been busy at work and at home, and to be honest I started working on another topic of my "todo geek list" :
Reinstalling my servers where I host my application and retake ownership of my data.

I also wanted to switch for manual installing all software on my servers and leveraging docker to put the app within container (and also improve a bit my knowledge in this area^^)

Here is what I have setup so far (all on docker containers):

* At home (on a RaspberryPi 3):
  * [Gogs](https://gogs.io/),
  * [DroneCI](https://github.com/drone/drone),
  * [Wallabag](https://wallabag.org) to save article for later,
  * [Shaarli](https://github.com/shaarli/Shaarli) to save interesting links,
  * [Lutim](https://lut.im/) to share images,
  * [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/) for monitoring
  * [Nginx](https://wiki.nginx.org/) to manage all the app behind it on the same ports 80/443
  * HTTPS everywhere (via [letysencprypt](https://letsencrypt.org))



* On a Digital Ocean droplet:
  * My [mastodon](https://github.com/tootsuite/mastodon) instance and a [feed2toot](https://feed2toot.readthedocs.io/en/latest/) bot
  * A [Mattermost](https://about.mattermost.com/) chat (opensource slack)
  * [Prometheus](https://prometheus.io/) for monitoring (link to my RPI Grafana)
  * HTTPS everywhere (via [letysencprypt](https://letsencrypt.org))

As you can see, i have been busy (with this, work, my life and of course starcraft2 ^^"), but unfortunately, I'm not done yet^^

My todolist still contains:

* Migrate all my repos from github to Gogs (at least mirroring)
* Add mattermost bots (hubot and RSS)
* Monitoring alerts via email (?)
* Redo mail server
* Backup automated policy


# Ok... That's cool, but why ?

Well, since a long time now, I'm trying to advocate for data privacy, self hosting a trying to stop feeding (too much) the GAFAM. I'm hosting my own server mail since 10 years as well as my websites (like this blog), but i wanted to go further and take ownership again of my data.

For those who speaks french and didn't see it (old from 2007… but still so true), i recommend this great video of Benjamin Bayart:
[Internet or minitel 2.0](https://www.fdn.fr/actions/confs/internet-libre-ou-minitel-2-0/) (For non French people, look up online what Minitel was :)).

From what I read on mastodorn, it seems B. Bayart might do a new version of that talk :).
I don't really want to explain why you should care about your data, there are a lot of good articles online.


# Sounds cool, i want to do it!

I'm planing to transform this experience into a series of blog posts:

* Continuous integration setup: Gogs , DroneCI  and automatic builds when a push happens. Bonus: push notification on a private channel of my mattermost instance.
* Mastodon and feed2toot bot (will be an update of my previous post about feed2toot as I don't plan to rewrite the good installation doc)
* Cool / useful apps selfhosted apps on RaspberryPi: Wallabag, Shaarli and Lutim
* Mattermost and Hubot
* Monitoring, graph and alerts

I'll update this post to add the link to the post series.

Talk to you soon!
