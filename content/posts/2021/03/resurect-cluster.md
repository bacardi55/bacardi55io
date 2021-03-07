---
title: "RCA of my homelab cluster downtime"
date: 2021-03-07T16:10:53+01:00
tags:
- docker
- dockerswarm
- selfhosting
- homelab
- raspberry pi
categories:
- selfhosting
---

## Context

For the few readers of this blog, or my flew follower on Mastodon, you may have saw a very long downtime for this blog last week (and other services less visible).

Indeed, my cluster was down from last Tuesday morning (±8am from what I could saw from logs and my [statping dashboard](/2020/04/28/my-home-lab-2020-part-5-external-application-status-with-statping/)). And it was down until sometime in the middle of the night between Friday and Saturday (I think around 2am).


## The issue

**TLDR;** the memory card of the manager node of the cluster died…

Ok, a little more details:

So on tuesday morning, seeing the alert from statping, I did a quick check to load the blog locally. It was not working… Ok I thoughts, what are the status of all worker nodes (As the blog container is placed only on workers)?

All worker nodes seemed ok, having some containers running well on them. Hmm, maybe the traefic containers was down on the manager? Trying connecting via ssh to my manager (`cell`) took a long time for some reasons… I was connected quickly but the prompt took forever to get displayed.

Looking at the logs, a shit tone of errors in there, I understood that something was more wrong than usual… Being already time to start working, I had to do something fast. At this point I thought a quick reboot would fix this and that I would have time to investigate later. Well that didn't go as planned.

A reboot later, I ssh to `cell` again, and, first it took a long time for the node to be accessible again, and two, it took as long as before the reboot to get back a prompt to work on…

Looking at the services running (`docker services ls`), I saw that all containers that needed to run on workers nodes were working, but no containers was running on the manager (too bad when the manager needs to handle the entry connection through traefic for all web services^^).

I tried running some commands but quickly realized that the system was in read-only… Well, that explains that nothing run correctly here…

Knowing the classic issue of microSD card sometime failing, I stopped the manager, removed the card and tried running fsck on it. I didn't save the results of fsck, but basically failed. I tried dd the image from the card to my laptop but dd also crashed with some errors… Ok, this is bad I thought…

Thanks to [Alex](https://social.nah.re/@alex) advices on IRC, I tried [ddrescue](https://doc.ubuntu-fr.org/ddrescue) to save the data. I started it Tuesday at lunch time hoping to save it.

Now, in the end, what did I want to save? All data are stored on my NAS and mounted via SSHFS as [explained here](/2021/02/04/moving-away-from-glusterfs-to-a-shared-folder-mounted-via-sshfs-for-my-cluster-storage/) so in reality, it was mainly to save the system to avoid reinstalling a new node manager.

Well, it didn't go as planned and thus the long downtime… But more on this later.

So, I ran ddrescue for quite some time! At first at I was optimistic and based on IRC logs this was the progress:
``` IRC logs
run time: 1h50 - read errors 14
run time: 6h45 - pct rescued: 86%
run time: 8h15 - pct rescued: 95,17% # (400+ errors at this point)
# At this point, it started the second pass to try accessing data
run time: 10h20 - pct rescued: 98,04%
run time: 12h - pct rescued 98,27%
```
Was more than 2 am at this point so I went to sleep… In the morning, I check and it was still around 98.39%, 5th passed. Seemed that ±400MB (on a 32GB card) couldn't be retrieved…

Well, lost for lost, I still tried mounting the generated image. And it worked and everything seemed there… I was not much confident but still copied the generated image with dd on a new card I had laying around, put it in the raspberry pi and booted it crossing most my fingers (not easy to type with crossed fingers btw :p).

And… The pi booted and I could ssh it! I didn't believe at first, but the system was running, and not in read only! And was responding fast! In a parallel dimension, most probably an alternative version of me started to dance… Maybe^^.

Anyway, so I was on the system that seems to work, so first thing, I checked if containers were running… But as before the issue, nothing was running on the manager. I tried manually starting simple containers on the manager, with or without swarm, but I couldn't make it work. I did insist a bit and fix part of it but after 1h of having something not really working (but a bit more than 1h ago!), I decided to stop. To be honest, it was more a game of finding what happened and if I could fix it. But in reality, I couldn't trust the system anymore being corrupted with data lost.


So this is at that point that I faced reality: I needed to reinstall completely at least the manager node. Did it took me the whole week to fix it? Not at all, just priority management.


## What to do?

At that point, I had in mind the following choices:
- Promote a worker as a node manager. I wasn't 100% if doable while the main manager was down to be honest and didn't check because I didn't want to go that road
- Reinstall quickly the manager. I wasn't 100% sure either if I could reinstall the pi as is. I would probably have needed to reinit a new swarm cluster anyway. I didn't go that road either
- Reinstall and improve…

As a good nerd, I decided to leverage this as an opportunity to improve the cluster. What did I do? I bought a new pi4 to replace the pi2 that was way to weak anyway, most swarm services containers were configured to not used the pi2. I also changed the "cluster rack". The old one was failing a bit (I did purchase a cheap one the first time I admit) so I thought why not.

I decided not to fix anything until the week end when I could do all in one (change cluster rack, replace pi2 with pi4) and as well reinstall all the pi anyway after checking the integrity of their microSD card.


## Friday Night Cluster Clinic

So on Friday, after receiving the new cluster box, the new pi and a couple of new microSD card, I started the operation "Cluster revival"!

### The plan

The plan was very easy:

0. Install new hardware (new cluster with new pi). This basically took me the most time!
1. Check all SD cards with fsck (fixed a couple of errors on 1 other card);
2. Reinstall latest debian on all SD Card (including hostname, hosts and ssh);
3. Start all pis, check and fix if needed IP addresses given by my router. Had to change the mac address of the old pi2 to the new pi4 to get the same IP for new node;
4. System updates (and remove MS VsCode repo…) and basic install (vim, tmux, htop, docker, docker-compose, sshfs, …)[^1];
5. Mount files from NAS (containers config and data);
5. Recreate and configure swarm cluster;
6. Restart containers.


### Drinking your own champagne

As the CMO of my company would say, I decided to "drink my own champagne", which is a classy way of the saying "eating your own dog food" and only follow my [cluster related blog posts](/pages/home-lab/) to reinstall everything… And it went better than I expected!

I went through the [docker swarm setup](/2020/03/27/my-home-lab-2020-part-3-docker-swarm-setup/) and [running services with traefic](/2020/03/30/my-home-lab-2020-part-4-running-services-over-https-with-traefik/) and everything was in there except 1 command to create the external `traefic-net` network. I then added it to the post as well.

To be honest, I do think having done this writing helped me first understand better what I was doing back then, but also helped me reset my cluster very fast! That's why I write this blog, as I explained a while back in [this post](/2020/04/25/why-do-i-write-on-this-blog/).

Everything is back to normal now (hopefully :))!


## Further thoughts

I'm still unsure if I would need to declare another manager in the cluster. That would be helpful if the problem happen another time. I would just need to change the IP of the NAT redirection from the old to new manager… That would be an easy thing to do. I would then just need to update docker-compose file to not avoid manager but just avoid the main manager (`hostname == cell` in the deploy/placement area).

I'll write later about this if I decide that this is the goal to take.

I'm also thinking that maybe I should have some full images (dd) backups of the 4 nodes but that feel a bit overkilled. As said, all data are on the NAS anyway. But we'll see what I'll do in the future about that!

Also: Don't trust microSD card ;).


[^1]: Using tmux `:set synchronize-panes` to do everything on the 4 rpis at the same time!
