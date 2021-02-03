---
title: Kalliope reminder with snooze
date: 2017-11-07
tags:
- kalliope
- reminder
category:
---


Quick blog post to talk about how I setup Kalliope to remind me stuff, but with a snooze feature.

The default setup of the [neurotimer](https://github.com/kalliope-project/kalliope/tree/dev/kalliope/neurons/neurotimer) let you ask Kalliope to remind you stuff after some time (minutes or hours).

I really like it because I have a poor short term memory, so when I have something to do in 30min, I use the kalliope neurotimer module to help me remember... But sometime, I want Kalliope to remind me again after 5 min because I didn't have the time to do at the time Kalliope reminded me.

Let's take a real life use case:

Let's say I am in a game (starcraft2 fan here ^^) and someone is calling me. When in a game, I can't (don't want to) pick up the phone, but I want to remember to call back the person. For this I'm using the neurotimer to do so, with a sentence like ```"Remind me in XX minutes to YYY"```.

This is the default setup explained in the [neurotimer README file here](https://github.com/kalliope-project/kalliope/tree/dev/kalliope/neurons/neurotimer).

But that is not enough for me, because I may be still in game when being reminded by Kalliope, so I want to have the ability to tell kalliope to remind me again in X minutes, without re-asking the full order like before.

The workflow I want:

```
Me: "Kalliope… remind me in 10 minutes to call back dad"
Kalliope: "I'll remind you in 10 minutes to call back dad"
[… 10minutes later …]
Kalliope: "You asked me to remind you call back dad"
Kalliope: "Do you want me to remind you again?"
  option1: (I want another reminder)
    Me: "Yes"
    Kalliope: "When?"
    Me: "In 5 minutes"
    [… 5 minutes later …]
    Kalliope: "You asked me to remind you to call back dad"

      *Option: Again, I'm in a sort of a loop here, so as long as I say "yes", it will remind me again until I say no (or anything other than yes).*

  Option2:
    Me: "No"
    Kalliope: "Ok, I won't remind you again."
```

So how does it work? I'm using the Neurotimer module, with the Neurotransmitter and the Kalliope memory to do so.

It does bring a limitation though, as you can't have multi reminder with "snooze" as the memory will only remember the last one.

My configuration to do so is the following:

Brain file:

```jinja
  {% raw %}
  ---
    - name: "reminder-synapse"
      signals:
        - order: "remind me to {{ remember }} in {{ time }} minutes"
      neurons:
        - neurotimer:
            minutes: "{{ time }}"
            synapse: "reminder-todo"
            forwarded_parameters:
              remember: "{{ remember }}"
            kalliope_memory:
              reminder_2: "{{ remember }}"
        - say:
            message:
              - "Ok sir, reminder setup"

    - name: "reminder-todo"
      signals:
        - order: "reminder_todo_no_order"
      neurons:
        - say:
            message:
              - "Sir, you asked me to remind you to {{ remember }}"
        - say:
            message: "Do you want me to remind you again ?"
        - neurotransmitter:
            from_answer_link:
              - synapse: "reminder2"
                answers:
                  - "oui"
              - synapse: "no-response"
                answers:
                  - "non"
            default: "no-response"

    - name: "reminder2"
      signals:
        - order: "reminder2-no-order"
      neurons:
        - say:
            message: "When do I have to remind you to {{ kalliope_memory['reminder_2'] }} ?"
        - neurotransmitter:
            from_answer_link:
              - synapse: "reminder-via-memory"
                answers:
                  - "in {{time}} minutes"
              - synapse: "reminder-via-memory"
                answers:
                  - "dans {{time}} minutes"
            default: "no-response"

    - name: "reminder-via-memory"
      signals:
        - order: "reminder-via-memory-no-order"
      neurons:
        - neurotimer:
            minutes: "{{ time }}"
            synapse: "reminder-todo"
            forwarded_parameters:
              remember: "{{ kalliope_memory['reminder_2'] }}"
        - say:
            message:
              - "Ok, I'll remind you in {{time}} minutes to {{ kalliope_memory['reminder_2'] }}"

  {% endraw %}
```

*Nota*: The "no-response" is a default synapse I created that simply answer "ok sir" or something like this :).

And voilà :)
