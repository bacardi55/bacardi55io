---
title: Kalliope Remote web app
date: 2016-12-28
tags:
- kalliope
- home_automation
- kalliope_remote
category:
description:
---


## Introducing [Kalliope remote](https://github.com/bacardi55/kalliope-remote)

While I still have to finish introducing the neurons I made for Kalliope, I took a bit of time since last week end to work on a side project for [Kalliope](https://github.com/kalliope-project/kalliope): [Kalliope-remote](https://github.com/bacardi55/kalliope-remote)

It is a simple [Single Page Apllication](https://en.wikipedia.org/wiki/Single-page_application) that leverage Kalliope API to display the list of available neurons and launch them via the web page.

![kalliope remote](/images/posts/kalliopeember.png)

The idea behind this app is to be able to set it up on my raspberry pi touchscreen where Kalliope is installed so that user that don't know available orders can look for it and even fire them without talking to [Kalliope](https://github.com/kalliope-project/kalliope). I will also be able to use it from my phone later on as well as it can be useful in case i'm not near the mic but the audio is loud enough :)

## How

* [EmberJS](http://emberjs.com/) as my JS framework and tools around it like [ember-cli](https://ember-cli.com/), ….
* [Twitter Bootstrap](http://getbootstrap.com/) (via the [EmberJS addon](http://kaliber5.github.io/ember-bootstrap/))
* [Kalliope](https://github.com/kalliope-project/kalliope) Rest API of course

### Additional notes

**Edit 30th of December**: The PR has been validated and merged into core. Only thing needed is to configure Kalliope to allow CORS request. [Here is explained how.](https://github.com/kalliope-project/kalliope/blob/master/Docs/settings.md#rest-api)

At the moment, the REST API of Kalliope doesn't allow request from different origin, thus blocking the request from the JS app (even if both are the same server, as port are different). To fix this, I've commited [this patch](https://github.com/kalliope-project/kalliope/pull/157) which add an option in the settings file to allow CORS requests.

I'm planing on adding another pull request later to add a configurable list of origin, so keep looking github ^^.

As for the integration of the PR into the main repo, it might be on standby while waiting for possible move to Django (see discussion in the [pull request thread](https://github.com/kalliope-project/kalliope/pull/157))

## What it does now

Basically, when the app loads it will request the list of synapse from your Kalliope set up and will display them nicely on the page.

* List all synapses available on your kalliope instance
* Allow you to launch synapse that has no parameter in the order

## What's next ?

* Managing orders with parameters inside
* Better test coverage ^^
* Leveraging the browser local storage to allow ignoring synapses (so you list only the one you desire)
* Managing other type of signals (event)


It's still early project but does already allow you some remote management :)
