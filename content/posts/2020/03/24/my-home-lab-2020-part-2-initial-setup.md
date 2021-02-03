---
title: "My Home Lab 2020, part 2: GlusterFS Setup"
date: 2020-03-24T17:13:41+01:00
tags:
- glusterfs
- homelab
- raspberrypi
- selfhosting
categories:
- selfhosting
description: Initial GlusterFS setup for my swarm cluster
---

# Introduction

As said [previously on this blog](/posts/2020/03/22/my-home-lab-2020-part-1-context-and-architecture-choices/), I've rebuild my "home lab" from scratch lately based on a [docker swarm](https://docs.docker.com/engine/swarm/) architecture and [GlusterFS](https://www.gluster.org/). The goal of this post is to go through the storage setup of our cluster :-)[^1]


## Assumptions

You have your raspberry pi or other servers installed, connected to your network and internet, up to date and you know a minimum your way in a Linux shell :)

If you don't, I suggest reading about it first before following the rest of this post, there is plenty of great documentation online :-).

*Nota*: I always name my based on [manga](https://en.wikipedia.org/wiki/Manga), for all my devices (laptop, desktop, phone, servers, ...)[^2]. So don't be surprise when reading machine name later on :).

## Simple Tip

If like me you use `tmux`, you can easily launch a command on all your servers at once :).

For this, all you need to do is open tmux, create window pane for all your servers and ssh to them. Once you are connected on all the servers on all pane, you can simply do `ctrl(keep pressed) a : `. You'll be shown a prompt `:` to enter a command. Enter `setw synchronize-panes` and validate with enter.

At this point, any key pressed will be send to all servers, so you can type a command once that will be fired on all systems.

To stop it, just redo the same (`ctrl a :` then `setw synchronize-panes`).


## GlusterFS

### Why

To be able to have shared storage across your docker swarm cluster. This allow all servers to share the same files. Having this is mandatory so you don't care anymore on which of these servers your containers are launched because they always have access to data :). Just think of it of a shared drive mechanism, but built for cloud usage.

There are other possible solution to this, but seems like a pretty robust one for cluster storage :).


### Some definitions

Basic Concepts of GlusterFS from their [documentation](https://gluster.readthedocs.io/en/latest/glossary/):

**Distributed File System**[^3]:
>  A file system that allows multiple clients to concurrently access data which is spread across servers/bricks in a trusted storage pool. Data sharing among multiple locations is fundamental to all distributed file systems.

**Brick**[^3]:
>  A Brick is the basic unit of storage in GlusterFS, represented by an export directory on a server in the trusted storage pool. A brick is expressed by combining a server with an export directory

**Node**[^3]:
>  A server or computer that hosts one or more bricks.

**Volume**[^3]:
>  A volume is a logical collection of bricks.

Read the [documentation](https://gluster.readthedocs.io/en/latest/glossary/) for more.


### GlusterFS architecture choice

With GlusterFS you can create the following types of Gluster Volumes:

- Distributed Volumes: (default option): This is for scalable storage with no data redundancy - «files are distributed across various bricks in the volume. So file1 may be stored only in brick1 or brick2 but not on both. Hence there is no data redundancy.»[^4]
- Replicated Volumes: (Better reliability and data redundancy): «Here exact copies of the data are maintained on all bricks.»[^4]
- Distributed-Replicated Volumes: (HA of Data due to Redundancy and Scaling Storage): «In this volume files are distributed across replicated sets of bricks.»[^4]

More detail on [GlusterFS Architecture](https://gluster.readthedocs.io/en/latest/Quick-Start-Guide/Architecture/)


I decided to use a "Replicated Volumes" configuration, making sure I have all files on all nodes (aka on all my raspberry pi).


### Setup a Gluster Replicated Volumes on 4 nodes

On all[^5]:

Install, enable and start gluster deamon:

```bash
sudo apt install glusterfs-server
sudo systemctl enable glusterd.service
sudo systemctl start glusterd.service
```

Then, create the needed volumes (still all on all nodes):

```bash
sudo mkdir /glusterfs/bricks
sudo mkdir /mnt/cluster-data
```

Then, you need to make sure they can contact each other. Either you have a local dns server that manage this (like [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)) or simply edit your `/etc/host` file.

For the rest of this posts, the machine name will be: `cell, ptitcell1, ptitcell2, ptitcell3`[^6]. Cell is my "master" (docker swarm manager) node in the cluster, but this has no impact for GlusterFS.

So now, we have to "link" all the nodes together in a trusted pool storage.

On your first node (`cell` in my case):
```bash
sudo gluster peer probe ptitcell1
sudo gluster peer probe ptitcell2
sudo gluster peer probe ptitcell3
```

Now all nodes should be in the pool storage.

Let's now create the different bricks on all nodes.


On your "master" or first server:
```bash
sudo mkdir /glusterfs/bricks/1/brick
```

on all other nodes (`ptitcell{1,2,3}`):

```bash
sudo mkdir /glusterfs/bricks/2/brick # on ptitcell1
sudo mkdir /glusterfs/bricks/3/brick # on ptitcell2
sudo mkdir /glusterfs/bricks/4/brick # on ptitcell3
```

Then, back on my first node (`cell`):

```bash
sudo gluster volume create cluster-data replica 4 \
	cell:/glusterfs/bricks/1/brick \
	ptitcell1:/glusterfs/bricks/2/brick \
	ptitcell2:/glusterfs/bricks/3/brick \
	ptitcell3:/glusterfs/bricks/4/brick
```
(If you are testing at first and use the root partition, you have to add `force` at the end of the command)

Now we can start the volume :)

```bash
  sudo gluster volume start data
```

Lastly, you need to update your `/etc/fstab` on all your nodes:

```bash
  localhost:cluster-data /mnt/cluster-data glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0
```

To try, you can mount the volume on all nodes:
```bash
  sudo mount.glusterfs localhost:cluster-data /mnt/cluster-data/
```

If everything works, you can now create a file in `/mnt/cluster-data/` and see it on all nodes :-).

With the line in the `/etc/fstab`, now you can reboot your nodes and the volume should automatically mounted :)

# To be Continued... :-)

That's it for now, it doesn't do anything yet, we just have a shared folder between our nodes, but this post is already long enough... So we'll start playing with docker and swarm on the next one.


[^1]: I originally planned to write about glusterFS and Docker Swarm setup in this post but the gluster setup was long enough for 1 post :).
[^2]: Being huge fan since my childhood, I starting doing this with my first laptop when I was ±15 and never stopped since, almost 20 years later...
[^3]: [GlusterFS glossary](https://gluster.readthedocs.io/en/latest/glossary/)
[^4]: [GlusterFS Architecture](https://gluster.readthedocs.io/en/latest/Quick-Start-Guide/Architecture/)
[^5]: Remember the tip above^^
[^6]: As said before... I'm a huge fan of manga, so in this case I was inspired by [Dragon Ball Z](https://en.wikipedia.org/wiki/Dragon_Ball_Z) and the vilain [cell](https://en.wikipedia.org/wiki/Cell_(Dragon_Ball)). "Ptitcell" means "Cell Junior" in French^^.
