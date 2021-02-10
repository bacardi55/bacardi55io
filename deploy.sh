#!/bin/bash

cd ~/workspace/perso/bacardi55iov2
rm -rf ./public/*

sleep 2

hugo

sleep 2

# To keep old RSS filename.
cp ~/workspace/perso/bacardi55iov2/public/index.xml ~/workspace/perso/bacardi55iov2/public/rss.xml

#rsync -azvhP --delete ~/workspace/perso/bacardi55iov2/public/ pi@cell:/mnt/sshfs/helios/cluster-data/containers-data/bacardi55io/public

rsync -avzhP --delete public/gemini/ pi@ryosaeba:/var/gemini/gmi.bacardi55.io/
