---
title: "Deploying my own Gemini capsule with gmnisrv"
date: 2021-02-10T19:19:03+01:00
tags:
- gemini
- gmnisrv
categories:
- selfhosting
---

I've been following Gemini for a bit of time and as I liked the concept and I love to play with new things, I decided to launch my own gemini capsule (aka, my own "site" on the gemini "web").

You can access it here: [gemini://gmi.bacardi55.io](gemini://gmi.bacardi55.io)

**Disclaimer**: The result is not perfect yet. For now I've only put my blog posts but internal links to other content or images do not fully work yet but I'll fix this later.

I do plan to create specific content on gmi at some point, for things that are not really "blog post" material but still worth typing for my future self :D.

I'd like to highlight and thanks some posts that convince me of doing it:
- [Samsai introduction to gemini](https://samsai.eu/post/introduction-to-gemini/)
- [Sylvain Durand blog post](https://sylvaindurand.org/discovering-the-gemini-protocol/) (and his other post around using hugo to generate gmi file, but more on that in another article)
- [totallinuxlinks](https://lottalinuxlinks.com/my-gemini-capsule-has-launched/)

And others that I've seen in my RSS feeds or on mastodon :).


## Gemini you say ?

For those that don't know, as said on the [gemini website](https://gemini.circumlunar.space/):

> Gemini is a new, collaboratively designed internet protocol, which explores the space inbetween gopher and the web, striving to address (perceived) limitations of one while avoiding the (undeniable) pitfalls of the other.

I suggest you read more about it on the [FAQ page](https://gemini.circumlunar.space/docs/faq.html) that contains all the necessary informations :).


## Gemini server setup

I was looking for an extra lightweight server and trying to avoid Go or Rust for server part. In the end, I I selected [gmnisrv](https://git.sr.ht/~sircmpwn/gmnisrv), developed by [Drew Devault](https://drewdevault.com/) in C. Easy to install, self manage certificate and very light to run on an old raspberry pi.

### Installation

You should already have openssl installed, but if not, install it with your packet manager.

Also, on the [project page](https://git.sr.ht/~sircmpwn/gmnisrv) it says that [scdoc](https://git.sr.ht/~sircmpwn/scdoc) is optional, but I couldn't install without it, so I ended up installing it too.

To install scdoc:

```bash
git clone https://git.sr.ht/~sircmpwn/scdoc
cd scdoc
make
sudo make install
```

Then, to install gmnisrv:

``` bash
git clone https://git.sr.ht/~sircmpwn/gmnisrv
cd gmnisrv
mkdir build
cd build
../configure --prefix=/usr
make
sudo make install
```

### Configuring the server

Copy the default config file at the right place:
```bash
cp /usr/share/gmnisrv/gmnisrv.ini /etc/gmnisrv.ini
```

And edit it as needed for the certificate path and the files path.

I use `/srv/gemini/gmi.bacardi55.io` as the path where my \*.gmi files will be.

For now, let's create a default hellowolrd page:

```bash
echo "hellowolrd55!" > /srv/gemini/gmi.bacardi55.io/index.gmi
```

### Creating a systemd service

To automate the (re)start of the server, I created a systemd service. To do so, I created `/etc/systemd/system/gmnisrv.service` with the following content:

```systemd
[Unit]
Description=Gemini Server gminisrv
After=network.target

[Service]
Type=simple
# Another Type: forking
User=gemini
ExecStart=/usr/bin/gmnisrv
Restart=always

[Install]
WantedBy=multi-user.target
```

As you can see, I use a dedicated `gemini` user on my system to run it as a limited users.

Then, enable the service and then start it:

```bash
sudo systemctl enable gmnisrv
sudo systemctl start gmnisrv
```

Remember also that it uses port 1965, so if you selfhost at home, don't forget to open the port and redirect flow on this port on the right server.

To test locally first, edit your `/etc/hosts` to map the domain config in the server file and the IP of the server in a gemini client.

You can find a list of clients on [this page](https://github.com/kr1sp1n/awesome-gemini). On my side, I used [gmni](https://git.sr.ht/~sircmpwn/gmni) but any client will do.

To test it works from the outside, either install a cli/tui client on an external server or test it via an online portal like [this one](https://portal.mozz.us/gemini/gemini.circumlunar.space/).


And voilà, you should see your hellowolrd page :)

In the next post, I talk about how I use my blog generator [Hugo](https://portal.mozz.us/gemini/gemini.circumlunar.space/) to generate both this blog and the gemini pages.
