---
title: Managing a shopping list with Kalliope
date: 2017-03-16
tags:
- kalliope
- home_automation
- todotxt
---


## Introduction

As promised in my [todotxt neuron post](link://slug/todotxt-a-neuron-to-manage-todolist-compatible-with-todotxt-format), here is a post about how I managed my todolist via [Kalliope](https://kalliope-project.github.io/) !

As it's compatible with [todotxt](http://todotxt.com/) format, you can still use the same file as kalliope to manage your todolists.


## Installation

### Install the neuron

```bash
  kalliope install --git-url https://github.com/bacardi55/kalliope-todotxt.git
```

### Configuration

First things first, you need a todo file (empty or not) that kalliope will use.

For example, I created a simple file in my root directory:

```bash
  touch ~/todo.txt
```

Then you need to choose the name of your project so item can be filtered. It will add +project in your todoline (but won't say it at loud).

In this example, I've choosen ```grocery```

#### Add item

First thing we need, is to add item to our list. To do so, create a new brain file ```todotxt.yml``` in your brain folder and put:

```yaml
  {% raw %}
    - name: "add-item-to-grocery-list"
      signals:
        - order: "think about buying {{content}}"
      neurons:
        - todotxt:
            action: "add"
            todotxt_file: "~/todo.txt"
            action: "add"
            project: "grocery"
            args:
                - content
            say_template: "I added {{added_task.task}} to the grocery list"
  {% endraw %}
```

Here, no need of a template, Kalliope return the item added in the list.

Now, you should be able to look into the todo.txt file and see the added line. Eg: if I said "think about buying milk", I'll have a new line in my todo.txt file like this:
```bash
  milk +grocery
```

#### List items

Now that we have added an item, we want to be able to hear them from kalliope before going shopping.

Add this in your brain file:

```yaml
  - name: "Get-grocery-items"
    signals:
      - order: "grocery list"
    neurons:
      - todotxt:
          action: "get"
          todotxt_file: "~/todo.txt"
          project: "grocery"
          file_template: "templates/grocery.j2"
```

Then, create the template file (here ```templates/grocery.j2```) and add:

```jina
  {% raw %}
  {% if count > 0 %}
      Your grocery list contains:
      {% for task in task_list %}
          {{ task.text  }}
      {% endfor %}
  {% else %}
      You don't have any item in your list
  {% endif %}
  {% endraw %}
```

And here we go! You can now go shopping!

#### Delete items

Once your shopping is done, you want to empty the list, via Kalliope of course!

Add this to your brain file:

```yaml
  {% raw %}
    - name: "clear-shopping-list"
      signals:
        - order: "Clear the shopping list"
      neurons:
        - todotxt:
            action: "del"
            todotxt_file: "~/todo.txt"
            project: "grocery"
            say_template: "{{count}} items have been deleted"
  {% endraw %}
```

And voilà!


#### Send

*Wait wait wait, you can't send it ?*

Hmm, I thought about it, but I didn't thought that it should be done by the todotxt neuron. It's role is only to manage the text file. Adding a send method would break that rule and make it too customized.

*So… no getting that list on my phone ? I have a bad memory you know…*

Of course you can, and of course I'll give you the tip :)

First, I decided to stay simple, no mail server heavy configuration or things like that. You can use sendmail, postfix, ssmtp to send email, this tip should still work.

For this example, I'm using ssmtp to connect to a remote smtp server (own by me) so no big configuration.

Just edit the ```/etc/ssmtp/ssmtp.conf``` file

```bash
  root=mail@example.com
  AuthUser=mail@example.com
  AuthPass=YourMailPassword
  mailhub=mail.example.com:465
  UseTLS=YES
  rewriteDomain=example.com
  FromLineOverride=YES
```

and of course change the example.com :).

There are a lot of documentation out there if you need to set it up to gmail.

So your system can send mail now. I did create a small python script that is like a wrapper to send mail from the system.

[The script can be found here](https://github.com/bacardi55/kalliope-starter55/blob/master/script/sendmail.tpl.py)

Usage:

```bash
  usage: sendmail.py [-h] [-f FROMEMAIL] [-t TO] [-s SUBJECT] [-b BODY]
                     [-c COMMAND] [-v]

  optional arguments:
    -h, --help            show this help message and exit
    -f FROMEMAIL, --fromemail FROMEMAIL
                          From email address
    -t TO, --to TO        To email address
    -s SUBJECT, --subject SUBJECT
                          Email subject
    -b BODY, --body BODY  Email body, used if -c is not present
    -c COMMAND, --command COMMAND
                          Command to generate text body
    -v, --verbose         Verbose mode
```

Ok, so now I have a configured ssmtp and a script to send mail easily via the command line.

I created this one liner bash script that will get (via grep) the content in the todo file and use it as the body of the email, like this:

```bash
  ##!/bin/bash
  /home/pi/kalliope_config/script/sendmail.py -s="[kalliope] Grocery list" -b="`grep +grocery ~/todo.txt`"
```

I named it mail_grocery.sh.

Then, I just leverage the script neuron to fire the bash script


```yaml
  - name: "send-shopping-list"
    signals:
      - order: "send me the shopping list"
    neurons:
      - script:
          path: "script/mail_grocery.sh"
```

And you should be all set !
