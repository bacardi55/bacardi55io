---
title: Kalliope updates, part 2
date: 2017-11-02
tags:
- kalliope
- kalliope_cli
- kalliope_remote
category:
---


I've been using Kalliope again lately so I've had to work on my neurons and external app to make sure it still works on latest Kalliope version.

This quick block post is about the state of my Kalliope related code, the next one will be about my kalliope + kodi + domoticz setup so far :)


## Neurons:

Neurons that are working (on README / samples files have been updated):

- [Domoticz](https://github.com/bacardi55/kalliope-domoticz): Manage switch or get value (light, temperature, ...) to Domoticz
- [Google Calendar](https://github.com/bacardi55/kalliope-google-calendar): Get your meeting from Google Calender
- [Google Maps](https://github.com/bacardi55/kalliope-gmaps): Google Maps integration (ask about address, itinerary (car or tube), ...)
- [MPD](https://github.com/bacardi55/kalliope-mpd): Manage MPD (and mopidy spotify) via Kalliope
- [Repeat](https://github.com/bacardi55/kalliope-repeat): Ask kalliope to repeat stuff (i use it only via API)
- [TodoTxt](https://github.com/bacardi55/kalliope-todotxt): Manage todo lists via Kalliope
- [Uber](https://github.com/bacardi55/kalliope-uber): Ask about time to get a driver or price for a ride
- [World wild time](https://github.com/bacardi55/kalliope-wwtime): Ask time in any city in the world


### Not working neurons:

- [List all orders](https://github.com/bacardi55/kalliope-list-available-orders): Will fix it soon(ish) ^^
- [PI Camera](https://github.com/bacardi55/kalliope-picamera) (no plan to work on it soon)
- [Web Scrapper](https://github.com/bacardi55/kalliope-web-scraper): Get info from web page by scrapping web page (for page without API or RSS). My most urgent neuron to fix! :)


## External tools:

### Kalliope CLI

I've fixed the CLI app and improved it quite a lot. Now you can the list of orders and send any text orders, with autocompletion :)

This quick youtube video show some of these features (except autocompletion):
[KalliopeCLI demo video](https://www.youtube.com/watch?v=cQNnZI4n9BI&feature=youtu.be)


### Kalliope Remote

It is kinda half working / half broken at the moment.
The app is still able to list all orders, and putting some of them in the ignore list.
Each order that doesn't require a parameter can be fired by a click.

The full text order input still works too so you can send an order via text.

The audio input doesn't work anymore but i'll fix this soon.
