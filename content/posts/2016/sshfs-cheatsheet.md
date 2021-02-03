---
title: Sshfs cheatsheet
date: 2016-12-03
tags:
- sshfs
- tips
category:
description:
---


Mount a remote directory:
```bash
sshfs login@machine:/path/to/source/code /path/to/mountpoint
```

Unmount:
```bash
fusermount -u /path/to/mountpoint/
```

Force unmount (sudo or as root)
```bash
umount -l /path/to/mountpoint
```
