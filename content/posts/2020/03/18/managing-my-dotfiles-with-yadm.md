---
title: Managing my dotfiles with Yadm
date: 2020-03-18T20:06:27+01:00
tags:
- dotfiles
- yadm
categories:
- laptop
description: Simple yet powerful tool to manage dotfiles efficiently
---

This will be a very short post about [Yadm](https://yadm.io/), « Yet another dotfiles manager», that shines by its simplicity and efficiency :-).

I decided a while ago to start managing my dotfiles with Yadm so I can share them between my main laptop and a recovery machine (a [Pinebook](https://www.pine64.org/pinebook/)). A very good idea in my opinion as it really speed up my [new laptop](/posts/2020/03/15/buying-linux-laptop/) setup :).


# Why would one need a dotfiles manager?

Idea is simple, to version and backup them, to deploy them on new machine quickly, etc…

You could also simply do it via git manually (what Yadm does behind the scene anyway) or use tools to do so. There are many other alternatives available or specific workflow / bash script, but I found Yadm so easy to use (if you already know git commands) that I quickly loved it :)


# Yadm - easy to learn and efficient dotfiles manager

I find Yadm to be a very easy to use yet very powerful dotfile manager. With it, I can easily manage files that will be reuse all machines, but as well defining some configuration file variation for specific OS (eg: linux) or for specific machine / hostname.

## Installation

See the [installation page](https://yadm.io/docs/install) for instruction. Most probably, there is a package available for your distribution.


## Usage

First, you need to initialize your repo, like you would do with git[^1]:

```bash
yadm init
yadm add <files>
yadm commit
yadm remote add origin <url>
yadm push -u origin master
```

For more usage information, see the [yadm](https://yadm.io/) website!

If you want to have specific version of config files for a machine, just create the config file with the following name: `<nameOfFile>##OS.HOSTNAME`.

For example, you can see my [dotfiles on gitlab](https://gitlab.com/bacardi55/yadm-dotfiles), with some specific config file for my [Pinebook](https://www.pine64.org/pinebook/) running [Archlinux](https://www.archlinux.org/) (without X by default) like `.asoundrc##Linux.raven` or `.xinitrc##Linux.raven`

Then, Yadm will automatically create a symbolic link between the specific config file for this machine. Eg: if you have a `.vimrc##Linux.raven` and a `.vimrc`, on the machine named "raven" running linux, it will create a symbolic link `~/.vimrc` to `~/.vimrc##Linux.raven`. On other machine, it will use the default `.vimrc` file of my Yadm repository… Pretty neat, right? :)

Look at the [documentation on alternate files](https://yadm.io/docs/alternates#) for more explaination :)


I haven't explored encryption yet as I'm paranoid and didn't take the time to look at how it works yet, that's why you see a `.neomuttrc.tpl` instead of a normal `.neomuttrc` with data encrypted (as well as because I don't want to show some configuration/ports in there^^).


[^1]: If you are not familiar with git commands and concepts, I suggest you to read about it first before playing with Yadm^^.
