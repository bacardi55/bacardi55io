---
title: Kalliope GoogleMaps neuron
date: 2017-02-21
tags:
- kalliope
- home_automation
---


## Introduction

If you follow me on twitter or github, you may have seen this new neuron coming, otherwise, let me introduce to you the [Google Maps neuron](https://github.com/bacardi55/kalliope-gmaps) :)

The goal as you can guess is to leverage the Google Maps API to get direction, distance or direction from an origin point to a destination (it doesn't handle multi origin or destination yet).

## What can you do ?

* Ask for the address of a place (eg: "what is the address of the Eiffel tour")
* Ask for the distance / time between 2 places. (how far is "address A" from "Address B")
  * Ask for the directions between 2 places, on top of distance/time. (how to go from "Address A" to "Address B")

The synapse has a lot of options, so you can set your transportation mode (driving, walking, tube, …), the language, the units system, …
Read the [readme file](https://github.com/bacardi55/kalliope-gmaps/blob/master/README.md) as it contains more information (and more up to date).

## Installation

### Neuron

Usual neuron installation:

```bash
  kalliope install --git-url https://github.com/bacardi55/kalliope-gmaps.git
```

Will install the neuron and the [google maps services python library)[https://googlemaps.github.io/google-maps-services-python/docs/2.4.5/)

### Synapse

Get the distance and time between 2 locations

```yaml
  - name: "Gmaps-distance"
    signals:
      - order: "distance between {{origin}} and {{destination}}"
    neurons:
      - gmaps:
          gmaps_api_key: "*********"
          mode: "driving"
          language: "en"
          units: "metric"
          traffic_model: "pessimistic"
          args:
            - origin
            - destination
          file_template: "templates/en_gmaps.j2"
```

Get the address of a place by its name

```yaml
  - name: "Gmaps-place-address"
    signals:
      - order: "get address of {{search}}"
    neurons:
      - gmaps:
          gmaps_api_key: "******************"
          language: "en"
          units: "metric"
          args:
            - search
          file_template: "templates/en_gmaps.j2"
```

You can find more up to date example on the [github readme page](https://github.com/bacardi55/kalliope-gmaps/blob/master/README.md)

### template

Here is a single template file to handle multiple use cases:

```jinja
  {% raw %}
  {% if status == "KO" %}
      Sorry, but the search didn't work, Sir
  {% elif status == "OK" %}
      {% if search %}
          {% if origin %}
              Distance between {{ origin }} and {{ search }} is {{ distance }}.
              You need around {{time}} to go there
              {% if time_traffic %}
                  You need to plan {{time_traffic}} with the current traffic
              {% endif %}
          {% else %}
              Address of {{search}} is {{destination}}
          {% endif %}
      {% elif destination %}
          Distance between {{oringi}} and {{destination}} is {{distance}}
          You need about {{ time }} to go there.
          {% if time_traffic %}
            Plan {{ time_traffic }} with current traffic.
          {% endif %}
      {% endif %}

      {% if directions %}
          To go to {{destination}}, you need
          {% for direction in directions %}
              {{ direction }}
          {% endfor %}
      {% endif %}

  {% endif %}
  {% endraw %}
```

Of course, you can simplify by splitting it into several templates depending on the arguments you send.


## What's next

Obviously, the Gmaps API is so rich that the possibility for this neuron are limitless… But at least this first version let you do the basics…

What I have in mind for next updates:

* multi origin / destination
* Leverage more API from google maps

As always, ideas or pull requests are more than welcome!
