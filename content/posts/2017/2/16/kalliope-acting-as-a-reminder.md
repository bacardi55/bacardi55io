---
title: Kalliope acting as a reminder
date: 2017-02-16
tags:
- kalliope
- home_automation
---


*edit: updated on 02/17*

## Introduction

Yesterday, I wanted to add a feature to [Kalliope (my always-on voice controlled personal assistant)](https://github.com/kalliope-project/kalliope) : the ability to reminds me of something later on. I have a very selective memory and forget to do a lot of stuff, so when I think about something important, I can gently ask Kalliope to reminds me to do it (:

## The main use case

The primary use case (there are other things I'd like to do, see the last paragraph about the todolist) is:

**Be able to ask Kalliope to reminds me of something in X minutes.**

This translate into these actions:

- A neuron with an order like "remind me in 10 minutes to leave for my appointment"
- Launching a command that will sleep for 10minutes
- After the delay, the command should make kalliope remind me of my appointment


I didn't / couldn't do a neuron, seeing the dependencies with languages and a need for an async script (kalliope needs to be able to answer commands in the meantime), a neuron was too complex.



## My solution

I ended up creating:

- A synapse that would just fire a python script that would do all the work.
  - The order looks like "remind me {{query}}".
  - The neuron used is the community shell neuron by sending the query to the script.
- A python script that receive the full query (including time to wait and the "thing" to remember
  - The script fire an ["at" command](http://www.linux-france.org/article/man-fr/man1/at-1.html) to program the wake up
  - The command started by "at" will leverage Kalliope API to tell me what to remember.
- A new neuron to make kalliope say dynamic text.


### The repeat neuron

The idea of this neuron is really simple: You send it arguments, and it will send them back as a return value to be used in template or say_template command.

As you can see on [the sample brain file](https://github.com/bacardi55/kalliope-repeat/blob/master/samples/brain.yml), you can do things like "say hello to {{name}}" or what not :).

To install the module, as usual:

```bash
    kalliope install --git-url https://github.com/bacardi55/kalliope-repeat.git
```

Then you can configure your brain as usual.

On synapse I created was this one:

```yaml
      - name: "Repeat-via-api"
        signals:
          - order: "api-repeat-cmd {{ query }}"
        neurons:
          - repeat:
              args:
                - query
              say_template:
                - "{{ query }}"
```

The idea of this one is just to repeat what is in query when an order is sent that starts with "api-repeat-cmd". It's easy enough as I'm sure i will never pronounce a thing like this.

So basically, any API call that will POST an order starting like this will make Kalliope read the text sent.

For example,

```bash
    curl -i --user admin:secret -H "Content-Type: application/json" -X POST -d '{"order":"api-repeat-cmd Hello sir, how are you ?"}' http://kalliope:5000/order/
```

This command will make Kalliope say "Hello sir, how are you".

So now, I have a neuron than can say anytext needed via API.

So leveraging this neuron, my at command could easily send me the text I asked Kalliope to reminds me (eg: "leave for my appointment")


### The python script

**The script needs the "at" program to be installed to run**

The script can be found [here](https://github.com/bacardi55/kalliope-starter55/blob/master/script/reminder.py)

If you look at the script, you will notice it is **heavily** dependent on the language (in my case French, sorry), so you can't just take it and use it, you'll have to update the text in it. I kept the code comments in English to help though


And with this, you can know ask Kalliope to remind you stuff (:


### The remaining part to do

- <del>Add a reminder at a specific time (at support time like 9:30)</del> **edit** Now available
- Delete last/all reminders (via atq and atrm commands)


Keep track of the python script and the example brain file, these features will arrive :).
