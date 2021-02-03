#!/bin/bash

cd ~/workspace/perso/bacardi55iov2

sleep 5

hugo -D && cp ~/workspace/perso/bacardi55iov2/public/index.xml ~/workspace/perso/bacardi55iov2/public/rss.xml && rsync -azvhP --delete ~/workspace/perso/bacardi55iov2/public/ pi@cell:/mnt/cluster-data/containers-data/bacardi55io/public
