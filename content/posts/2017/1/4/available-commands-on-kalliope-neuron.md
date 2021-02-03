---
title: Available commands on kalliope neuron
date: 2017-01-04
tags:
- kalliope
- home_automation
---


And we keep going with the blog post series about [Kalliope](https://github.com/kalliope-project/kalliope) :)

## Why

Let's introduce here a simple neuron I developed that let you know what you can ask.

I know it might sound dumb, but it can be handy when other people leaving with you don't know as much as you your kalliope setup :) (Or as well, to make Kalliope answer when friends ask why i use it, I can make kalliope answers with the list of available orders).

This is why I developed the small neuron [list_available_orders](https://github.com/bacardi55/kalliope-list-available-orders).

## Installation:

As per the previous neuron, kalliope let you install via the command line the neuron:

```bash
    kalliope install --git-url https://github.com/bacardi55/kalliope-list-available-orders.git
```

No additional library are required for this neuron.

## usage

### brain
Create you brain file, eg:

```yaml

    ---
      - name: "All-orders"
        signals:
          - order: "what can I ask"
        neurons:
          - list_available_orders:
              query_replace_text: "and the argument"
              ignore_machine_name: 1
              file_template: "templates/en_all_available_orders.j2"
```


The query_replace_text option is the text you want instead of "{{ query }}" (or any arguments).
I put this option because otherwise Kalliope says open/close bracket which is a bit weird :)


### template

You can use 2 variables in the template, ```nb_orders``` for the number of available orders and ```orders```, a list of order. More description about the order [here](https://github.com/bacardi55/kalliope-list-available-orders#return-values).


This template will simply make Kalliope speak out loud the number of orders and then all of them If no order are found, a simple "order not found" sentence will be said by Kalliope.

```jinja
    {% raw %}
    {% if nb_orders > 0 %}
        You have {{ nb_orders }} available orders:
        {% for order in orders %}
            {{ order }}
        {% endfor %}
    {% else %}
        No order found.
    {% endif %}
    {% endraw %}
```

