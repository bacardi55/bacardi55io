#!/bin/bash

cd ~/workspace/perso/bacardi55iov2

sleep 5

hugo && cp ~/workspace/perso/bacardi55iov2/public/index.xml ~/workspace/perso/bacardi55iov2/public/rss.xml && rsync -azvhP --delete ~/workspace/perso/bacardi55iov2/public/ pi@cell:/mnt/sshfs/helios/cluster-data/containers-data/bacardi55io/public
