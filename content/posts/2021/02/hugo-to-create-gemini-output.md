---
title: "[DRAFT] Using Hugo to manage both this blog and my gemini capsule"
date: 2021-02-12T19:19:33+01:00
tags:
- gemini
- hugo
categories:
- selfhosting
draft: true
---

## Using Hugo to generate your gemini files

## Deploying with rsync

I use the simplest solution for deployment, I have a deploy.sh script that will build the site both for http and gemini and then rsync the files to the right places. The rsync part of it for gemini looks like this:

```bash
rsync -avzhP --delete public/gemini/ <use>@<server>:/var/gemini/gmi.bacardi55.io/
```
