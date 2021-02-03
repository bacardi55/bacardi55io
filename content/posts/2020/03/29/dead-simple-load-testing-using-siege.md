---
title: Simple load testing using siege
date: 2020-03-29T14:09:19+01:00
tags:
- load tests
- siege
categories:
- tools
description: Understand how much traffic your servers can take
---

# Context

Today, a really quick post about dead simple [load testing](https://en.wikipedia.org/wiki/Load_testing) using [siege](https://www.joedog.org/siege-home/) instead of continuing the series about [my home lab setup](/categories/homelab/) but I should publish part 4 tomorrow :). This is more a way for me to remember doing this :D.

In the meantime, I was playing yesterday with my monitoring (based on [swarmprom](https://github.com/stefanprodan/swarmprom) for now, but that might change… More on that later) and was wondering about my homelab based on small raspberry pi ability to take a spike of traffic. I was mainly wondering which of my ISP or the cluster would fail first^^.

I used a couple of times apache benchmark in the past but wanted something new and very simple because testing a static site is so easy (as opposed to test a "dynamic" website where users authenticate, create content, etc…).

So I search quickly and found [siege](https://www.joedog.org/siege-home/) that seems to do exactly what I want :)


**Nota**: It may be obvious, but you need to think from where you want to run your load tests. If you just want to test your cluster capabilities to manage requests, you could potentially run it from your laptop on your network. But to really do actual user like traffic, you obviously need to try it from a server outside your home (and it will allow to also test your internet connection capabilities too).


# Installation

As a debian user on all my servers, a simple
```bash
sudo apt install siege
```
did the trick :)

Look at the [documentation](https://www.joedog.org/siege-readme/#install) if it's not available on your distro.

# Start testing

The easy thing to do at first is just generating traffic on your home page to try:
```bash
siege -t1 -c50 -v https://yourdomain.com
```

This means simulating 50 users (`-c50`) during 1 minute (`-t1`) on the home page of the site (`-v https://yourdomain.com`)

And you should get (self explanatory) results like this:
```bash
Transactions:                   1170 hits
Availability:                 100.00 %
Elapsed time:                  59.53 secs
Data transferred:              22.47 MB
Response time:                  2.49 secs
Transaction rate:              19.65 trans/sec
Throughput:                     0.38 MB/sec
Concurrency:                   48.95
Successful transactions:        1170
Failed transactions:               0
Longest transaction:            3.52
Shortest transaction:           1.74
```

You can look at the [man page](https://www.joedog.org/siege-manual/) for a description of all the commands options.

I have a bit of slow response time but giving the number of request on 1min I find it ok (obvisouly, there are usually ±10 requests an hour, most of them from my [statping](https://github.com/statping/statping) instance^^).


I tried 100 users, and even if I still have 100% of success, I can see in the way too long response time (±3s for the shortest, ±6s for the longest).

# Testing on all urls

I wanted to do a better tests when users navigate to any urls of the site. For this, nothing easier with siege as you can give a file with a list of urls as an argument:
```bash
siege -t1 -c50 -f urls.txt
```

To generate the urls.txt file, I simply retrieved all the urls from my [sitemap.xml](/sitemap.xml) file like this:
```bash
grep -oE "https://bacardi55\.io[^<]*" sitemap.xml > urls.txt
```

And then run the above commands with the generated files and voilà :).

That's it for this post, see you tomorrow for the part 4 of my [homelab setup](/categories/homelab/).
