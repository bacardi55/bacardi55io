---
title: Save a file even when you forget sudo
date: 2016-12-03
tags:
- vim
- sudo
- tips
category:
description:
---


If you forget to open a file in vim a sudo/root, you can simply do in vim (sudo needs to be installed):

``` bash
  :w !sudo tee %
```
