---
title: "My Home Lab 2020, part 6(v1): Temporary backup system"
date: 2020-04-30T18:26:33+01:00
tags:
- selfhosting
- backups
- rsync
- homelab
categories:
- selfhosting
description: A quick solution based on rsync and tar :)
---

# Context

Today, a post about my temporary backup system of my cluster. Wait, « temporary » you say? Why the hell don't you talk about your final non temporary solution?

Well, first of, I talk about what I want, thanks for asking *self* … (Yes, I might be going mad lately…) The main reason behind this temporary solution is because of the lock down due to covid-19, I couldn't (or did not want) to get delivered what I wanted to build a NAS. I'll talk more about the NAS when I get it, but because of an interesting conversation with [nah](https://nah.re) on IRC, I am now waiting for the [Helios64 by Kobol](https://kobol.io/) to be available… So the "real backup" system I want to setup will not happen until then.

For me, waiting that much for saving my cluster data was not an option. Backups are a critical part of a hosting architecture and it should be put in place from the beginning.

## Desired architecture

My goal is to setup [borgbackup](https://borgbackup.readthedocs.io/en/stable/) correctly to do the backup system. I'm already using it for my [digital ocean](https://www.digitalocean.com/) droplets and other cloud servers. I think it is a great tool that does all I want from a backup system: it saves space disk (with deduplication, compression and differencial backups) but still provides an incremental backup mechanism to save history of files… I will talk more about it when I'll setup this desired architecture :)

The NAS will be the borg server in this architecture, hence the waiting part… I could use another machine for this but I'm too lazy to redo it later, so instead I took 30min to create a minimal temporary solution in the meantime.

## Temporary architecture

As I wanted something temporary, and because I'm clearly lazy, I thought of the MVP like this:

- From my cluster, rsync the `/mnt/cluster-data`[^1] directory (where all containers definition and data seat) to another server (outside of the cluster) every 4 hours (I could de more often but data don't change that much :)). For the remote server, I use the raspberry pi in my bedroom called `ryosaeba`[^2] (Only used for the [multiroom sound system](/posts/2020/04/18/home-automation-part-3-multi-room-music-and-sound-system-with-mopidy-and-snapcast/));
- On `ryosaeba`, create every day an archive of the rsync-ed directory. It means that on that server, I have a "live" version (the rsync-ed folder) as well as daily archives of that folder;
- Archives are deleted after 15 days from `ryosaeba` (to save space on my rpi);
- On `ryosaeba`, rsync the archives folder to another raspberry pi (in this case `brook`, the [mopidy](https://mopidy.com) and [snapcast](https://mjaggard.github.io/snapcast/) servers for my [multiroom sound system](/posts/2020/04/18/home-automation-part-3-multi-room-music-and-sound-system-with-mopidy-and-snapcast/)).

The main reasons I rsync the archives directory from one server to another is that I don't trust the storage used in the raspberry pi (a microSD card). When I'll switch to borg with a NAS configured, I will not need this. I will need to put in place a remote storage for the backup though if I want to follow the 3-2-1 backup methodology[^4].

# Installation

**Nota**: This post is about backup-ing directory and creating archives, it will not cover how to backup containers database (I'll write a dedicated posts for that). My solution is to create dump backup inside the cluster-data folder, so they are saved using the backup solution (this temporary one or the one based on borgbackup). But more on that later.

## Rsync cluster data to storage server every 4 hours

Installation is easy, if you are using [raspbian](http://raspbian.org) like me, everything you need is already installed (rsync, ssh and bash) :).

First, ssh to the server you want to backup. In my case, using a [docker swarm cluster](/posts/2020/03/27/my-home-lab-2020-part-3-docker-swarm-setup/) with a [shared GlusterFS volume](/posts/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/) means that I can do it from any of the swarm nodes. I choose to do it from one of the non manager node (as the manager is already the most used one) and more precisely, I do it from the node called `ptitcell3`.

First, you need a [ssh key](https://www.ssh.com/ssh/key/) to be able to send data from `ptitcell3` to `ryosaeba`. For that, on `ptitcell3`:
```bash
ssh-keygen
```
Answer the question and leave empty the passphrase.

Then do a `cat ~/.ssh/id_rsa.pub` and copy the content.

On the backup server (`ryosaeba`), open `~/.ssh/authorized_keys` file and add a new line with the content of `~/.ssh/id_rsa.pub` from `ptitcell3`.

(If your server accept ssh connection with password - which you shouldn't - you can use the `ssh-copy-id user@server` command instead of manually copy/pasting it)

Then, to make sure `ptitcell3` can connect to `ryosaeba`, I'm adding a line in the `/etc/hosts` file on `ptitcell3`:
```
10.0.0.xx   ryosaeba # Adapt the IP address!
```

Normally, you can now ssh from the backup server to the storage one, in my case, on `ptitcell3`:

```bash
ssh ryosaeba
```

If you can connect without passphrase correctly, you can move on :).

It's now time to create the simple bash script that will do the rsync to the remote server. Create a `backup.sh` file with the following content:
```bash
#!/usr/bin/env bash
set -euo pipefail

rsync -azvhP --delete /mnt/cluster-data/ ryosaeba:backups/cluster-data/
```
This rsync command will synchronise the `/mnt/cluster-data` directory to `backups/cluster-data` on the remote server. The `--delete` option will remove files on the remote server that are not present on the cluster anymore. I'm doing it because I want an exact replica of the cluster-data folder. You may want to change it depending on your needs.

Then, add execution right to it: `chmod +x backup.sh`.

Before running it, make sure the remote directory exists, so on `ryosaeba`: `mkdir -p ~/backups/cluster-data`.

Run it once to make sure it works correctly and if it's the case, add it as a cron job. Open the crontab editor (`crontab -e`) and add the following line:
```bash
0 */4 * * * /home/pi/backup.sh
```

This will run the backup.sh script every 4 hours and synchronise `/mnt/cluster-data` (`pticell3`) directory to `backups/cluster-data` (`ryosaeba`).


## Create a daily backup and keep the last 15 archives

Create (on `ryosaeba`), the `create_archive.sh` script:
```bash
#!/usr/bin/env bash
set -euo pipefail

tar -czf /home/pi/archives/daily_$(date +%Y%m%d).tgz /home/pi/backups/ # Creates the daily archive.
find /home/pi/archives/ -mtime +15 -delete # remove archives older than 15 days.
```
This script will handle the creation of the archive (`tar`) and cleaning archives older than 15 days (`find … -delete`)

Make it executable: `chmod +x create_archive.sh`.

Make sure that the archives directory exists, so `mkdir ~/archives`.

Run it to ensure it works correctly (`./create_archive.sh`).

If it does (meaning you see a new archive in the archives folder), you can add it to the cron tasks to be executed every day. Open the crontab editor (`crontab -e`) and add the line:

```bash
30 1 * * * /home/pi/create_archive.sh
```
In this example, the archive will be created every day at 1:30am.


## Rsync archives to 2nd storage server

Now, last thing to do is to synchronise the archives folder on the 2nd storage. First, you need to make sure that the 1st storage server (`ryosaeba`) can ssh to the 2nd storage server (`brook`). For this, use the same as above (`ssh-keygen`, …).

Once ssh is working, create the script that will send the archives to the 2nd storage server (`brook`), so on `ryosaeba`, create the `backup_archives.sh` script:
```bash
#!/usr/bin/env bash
set -euo pipefail

rsync -azvhP --delete /home/pi/archives/ brook:backups/
```
G
Make the script executable: `chmod +x backup_archives.sh`.

Make sure the remote directory exists, so on `brook`: `mkdir ~/backups/`.

And then you can run the script to test it (`./backup_archives.sh`). If it works and you see your tar.gz files being copied to the 2nd server, you can then move this script as a cronjob task. On `ryosaeba`, add the following line in your crontab editor (`crontab -e`):

```bash
30 2 * * * /home/pi/backup_archives.sh
```
Meaning that everyday at 2:30am (1h after the archive creation), the archives directory will be synchronise to `brook`.

**Nota**: If you want to keep all archives on the 2nd storage server and not the last 15 like on the first storage server, you just need to remove `--delete` from the find command in the script :).

# Conclusion

And now, the cluster data are sync-ed every 4 hours to my `ryosaba` server, where everyday a snapshot (tar.gz archive) is taken and put in the archives folder. This folder will contain only the archives from the last 15 days and they will be copied for redundancy to `brook` every day.

I'm planing to write about the databases inside containers backup soon to complement this post.

There will be a second version of this part 6 when using borgbackup and my future NAS server, but that will have to wait for the hardware needed :).


You can follow all posts about my Home Lab setup on the [dedicated page](/pages/home-lab/).


[^1]: Remember my [glusterFS setup](/posts/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/) :)?
[^2]: From the manga [City Hunter](https://fr.wikipedia.org/wiki/City_Hunter).
[^3]: 3-2-1: 3 total copies of the data, 2 local on different medium and 1 remote.

*[MVP]: Minimum Valuable Project
*[NAS]: Network Attached Storage
