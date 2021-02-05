---
title: "Moving away from GlusterFS to a shared folder mounted via sshfs for my cluster storage"
date: 2021-02-04T19:18:13+01:00
categories:
- selfhosting
description: From GlusterFS on rpi hard drive to sshfs on NAS
tags:
- sshfs
- glusterfs
- dockerswarm
- homelab
---

*What? 2 article in 2 days? Am I sick or something? :D*

## Context
As I written at the beginning of the [selfhosting series](/categories/selfhosting/) about my [docker swarm cluster](/tags/dockerswarm/), I have used so far a [GlusterFS volume mounted on all nodes of the swarm](/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/). It has worked well until now, but the truth is I believe it was too heavy for the raspberry pi (mainly on the pi2 and 3) and had a few issues with it over the years (issues when mounting the drive with only part of the data and other small glusterfuck^^).

As I finally invested and installed a NAS[^1] at home recently (more on this later), I decided to leverage it for the storage of the cluster.

**Disclaimer**: *I know that it is not the best way of managing this, specially when having a bigger usage and that GlusterFS is made for this and is one of the best choice. But for a selfhosted cluster with almost no traffic based on raspberry pi, it was overkilled.*


## Setup

On all raspberry pi, I had to install sshfs:
```bash
sudo apt install sshfs
```

Then, enable the `user_allow_other` to manage access permissions and right through sshfs:
```bash
sudo vim /etc/fuse.conf
```

And uncomment `user_allow_other`.

Create the directory where the remote directory will be mounted, eg (on all cluster's node):
```bash
sudo mkdir -p /mnt/nas_storage/
```

Now, create an ssh key on all nodes if it is not already the case (without passphrase) with `ssh-keygen`.

Add each keys in the `authorized_keys` files of the right user.

You can test if it works as expected (and add the server in the `known_hosts` file):

```bash
sshfs -o allow_other user@server:/path/to/remote/directory/ /mnt/nas_storage
```

If your data are in `/mnt/nas_storage`, it works. Now you can unmount it for now:

```bash
fusermount -u /mnt/nas_storage
```

To automount on demand the sshfs directory, edit the `/etc/fstab` file and add:

```fstab
user@server:/path/to/remote/directory /mnt/nas_storage/ fuse.sshfs noauto,x-systemd.automount,_netdev,users,IdentityFile=/path/to/sshkey.pub,allow_other,reconnect 0 0
```


[^1]: Based on [Helios64](https://wiki.kobol.io/helios64/intro/) for the hardware, [armbian](https://www.armbian.com/) and [openmediavault](https://www.openmediavault.org/) for the software. Detailed blog post to follow.
