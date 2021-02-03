---
title: Kalliope system status neuron
date: 2017-02-21
tags:
- kalliope
- home_automation
---


## Introduction

Couple of days ago, I created a very simple neuron to retrieve some system data and have an idea of the system kalliope runs on. It was in the same idea of the [poorsman loganalyser I talked about before](node/31).

In all honesty, most credits goes to [this github repository](https://github.com/edouardpoitras/jasper-status) I found that did almost all the job for me.

## What does it do ?

So far, it returns the following variable that can then be used in a template or say_template:

* running_since
* os: OS name
* os_version: Kernel version
* system_name: Name of your host
* system_nb_core: Number of core
* cpu: % of CPU usage
* memory: % of memory usage
* disk: % of disk usage

Look at the [readme](https://github.com/bacardi55/kalliope-system-status) for an up to date list :)

## Installation

The usual:

```bash
  kalliope install --git-url https://github.com/bacardi55/kalliope-system-status.git
```

## Usage

Create a brain file like this:

```bash
      - name: "System-status"
        signals:
          - order: "Step into analysis mode, please"
        neurons:
          - system_status:
              say_template:
                - "I'm running on {{os}}, kernel {{os_version}}, with {{system_nb_cores}} cores.    C P U usage {{cpu}} %  memory usage {{memory}} %  disk usage {{disk}} %"
              cache: False
```

Or create a more complex template :)

I'll add more into this, but if you have idea, PR on github or comment on this post :)
