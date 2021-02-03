---
title: An Uber neuron for Kalliope
date: 2017-03-18T14:30:00+01:00
tags:
- kalliope
- home_automation
- uber
---



## Introduction

Today I realized that I didn't write about a neuron I did for Kalliopé to interact with the [Uber API](https://developer.uber.com/) that I've done a couple of weeks following a "silly bet" with my brother after I've done the [Google maps neuron](https://github.com/bacardi55/kalliope-gmaps)

The basic idea was to see what could be done **without validating any drive order**. Indeed, as of now, I find it too dangerous that someone could by a voice command order a driver (or anything payment related).

Plus, to do this automatic order, you need more permission (end user permission as opposed to server to server permissions) and that complexified too much the neuron (coded in a 7h flight ^^).


## The neuron

### What can it do ?

Basically, [this Uber neuron](https://github.com/bacardi55/kalliope-uber) let you ask for how long to get a Uber based on an address and a Uber type (X, Black, Pool, …)

It also let you put an optional end address. In that case, you will also have a estimation of the cost and the duration of a drive from a start address to this destination.


### Installation

```bash
  kalliope install --git-url https://github.com/bacardi55/kalliope-uber.git
```


### Usage:

#### Brains

Get the estimated time to get a ```driving_mode``` driver based on geolocation data

```yaml
  {% raw %}
    - name: "Uber-time-estimate"
      signals:
        - order: "how long for a driver to pick me up"
      neurons:
        - say:
            message: "Calculating"
        - uber:
            uber_api_key: "***********************"
            start_longitude: "***"
            start_latitude: "****"
            driving_mode: "uberX"
            say_template: "A {{driving_mode}} driver can be there in {{ time_to_get_driver }} minutes"
  {% endraw %}
```

Get the estimated time to get a ```driving_mode``` based on a text address

```yaml
  {% raw %}
    - name: "Uber-time-estimate-by-address"
      signals:
        - order: "how long for a driver to pick me up"
      neurons:
        - say:
            message: "Calculating"
        - uber:
            uber_api_key: "***********************"
            gmaps_api_key: "**********************"
            start_address: "*********"
            driving_mode: "uberX"
            say_template: "A {{driving_mode}} driver can be there in {{ time_to_get_driver }} minutes"
  {% endraw %}
```

Get the estimated time to get a ```driving_mode```, the price and the ride duration

```yaml
  {% raw %}
    - name: "Uber-time-and-price"
      signals:
        - order: "how much for a rider to work"
      neurons:
        - say:
            message: "Calculating"
        - uber:
            uber_api_key: "***********************"
            driving_mode: "uberX"
            start_longitude: "***"
            start_latitude: "****"
            end_longitude: "*****"
            end_latitude: "******"
            say_template: "A {{driving_mode}} driver can be there in {{ time_to_get_driver }} minutes. Traject will take about {{ duration }} and would cost {{ estimate }}"
  {% endraw %}
```

Get the estimated time to get a ```driving_mode```, the price and the ride duration to go to an address givin in argument

```yaml
  {% raw %}
    - name: "Uber-time-and-price-by-addresses"
      signals:
        - order: "how much for a rider to {{end_address}}"
      neurons:
        - say:
            message: "Calculating"
        - uber:
            uber_api_key: "***********************"
            gmaps_api_key: "**********************"
            start_address: "*********"
            driving_mode: "uberX"
            say_template: "A {{driving_mode}} driver can be there in {{ time_to_get_driver }} minutes. Traject will take about {{ duration }} and would cost {{ estimate }}"
            args:
                - end_address
  {% endraw %}
```

Get the estimated time to get a ```driving_mode```, the price and the ride duration based on addresses given in arguments

```yaml
  {% raw %}
    - name: "Uber-time-and-price-by-start-address"
      signals:
        - order: "how long for a driver to pick me up {{start_address}} to go to {{end_address}}"
      neurons:
        - say:
            message: "Calculating"
        - uber:
            uber_api_key: "***********************"
            gmaps_api_key: "**********************"
            driving_mode: "uberX"
            say_template: "A {{driving_mode}} driver can be there in {{ time_to_get_driver }} minutes. Traject will take about {{ duration }} and would cost {{ estimate }}"
            args:
                - start_address
                - end_address
  {% endraw %}
```


see more example in the [sample directory](https://github.com/bacardi55/kalliope-uber/blob/master/samples/)

enjoy!
