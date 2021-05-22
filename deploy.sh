#!/bin/bash

workdir="/home/bacardi55/workspace/perso/bacardi55iov2"
public_dir="public"
gemini_output_dir="_gemini_"
favicontxtpath="$workdir/static/favicon.txt"

cd "$workdir"
echo "Removing old public files in $workdir/$public_dir/"
rm -r "$workdir/$public_dir/" && mkdir "$workdir/$public_dir/"

# Generate outputs
hugo

# To keep old RSS filename.
cp "$workdir/$public_dir/index.xml" "$workdir/$public_dir/rss.xml"

# Move files around to dissociate web and gemini:

echo "Creating gemini output directory $workdir/$public_dir/$gemini_output_dir"
mkdir "$workdir/$public_dir/$gemini_output_dir"
echo "moving $workdir/$public_dir/gemini/index.gmi to $workdir/$public_dir/$gemini_output_dir/"
mv "$workdir/$public_dir/gemini/index.gmi" "$workdir/$public_dir/$gemini_output_dir/"

echo "Copying all posts to gemini capsule, from $workdir/content/posts/ to $workdir/$public_dir/$gemini_output_dir/"
cp -r "$workdir/content/posts/" "$workdir/$public_dir/$gemini_output_dir/"
echo "Copying all gemlog posts to gemini capsule, from $workdir/content/gemlog/* to $workdir/$public_dir/$gemini_output_dir/gemlog/"
cp -r "$workdir/content/gemlog/" "$workdir/$public_dir/$gemini_output_dir/"

echo "Moving $workdir/$public_dir/posts/gemini/index.gmi to $workdir/$public_dir/$gemini_output_dir/posts/"
mv "$workdir/$public_dir/posts/gemini/index.gmi" "$workdir/$public_dir/$gemini_output_dir/posts/"
echo "Moving $workdir/$public_dir/gemlog/gemini/index.gmi to $workdir/$public_dir/$gemini_output_dir/gemlog/"
mv "$workdir/$public_dir/gemlog/gemini/index.gmi" "$workdir/$public_dir/$gemini_output_dir/gemlog/"
echo "Moving Posts RSS files:"
mv "$workdir/$public_dir/posts/index.xml" "$workdir/$public_dir/$gemini_output_dir/posts/"
echo "Moving Gemlog RSS files:"
mv "$workdir/$public_dir/gemlog/index.xml" "$workdir/$public_dir/$gemini_output_dir/gemlog/"

#echo "Copying favicon.txt"
#cp "$favicontxtpath" "$workdir/$public_dir/$gemini_output_dir/"

echo "deleting files from output"
echo "$workdir/$public_dir/gemini"
rmdir "$workdir/$public_dir/gemini/"
echo "$workdir/$public_dir/posts"
rmdir "$workdir/$public_dir/posts/gemini"
# Section are only for gemini output, posts is now empty.
rmdir "$workdir/$public_dir/posts"
echo "$workdir/$public_dir/gemlog"
rmdir "$workdir/$public_dir/gemlog/gemini"
echo "$workdir/$public_dir/gemlog/gemini"
# Because I don't want the gemlog files to be available at all on the blog (https):
rm -rf "$workdir/$public_dir/gemlog"
echo "$workdir/$public_dir/gemlog"
rm "$workdir/$public_dir/$gemini_output_dir/posts/_index.md"
echo "$workdir/$public_dir/$gemini_output_dir/posts/_index.md"
rm "$workdir/$public_dir/$gemini_output_dir/gemlog/_index.md"
echo "$workdir/$public_dir/$gemini_output_dir/gemlog/_index.md"

sleep 1

# Now we have move and replace all files generated by Hugo, but we still need to convert md files to gmi files:
cd "$workdir/"
/usr/bin/python3 ./generate_gmi_files.py

echo "Everything has been generated, going to synchronize weblog and gemlog, you have 5 seconds to cancel it"

sleep 5

# Now we can actually deploy:

echo "Deploying Blog"
rsync -azvhP --delete --exclude "_gemini_" ~/workspace/perso/bacardi55iov2/public/ pi@cell:/mnt/sshfs/helios/cluster-data/containers-data/bacardi55io/public

echo "Deploying Capsule"
rsync -avzhP --delete ~/workspace/perso/bacardi55iov2/public/_gemini_/ pi@cell:/mnt/sshfs/helios/cluster-data/containers-data/gemserv/data/gmi.bacardi55.io/
echo "Deploying tinylog"
scp tinylog.gmi pi@cell:/mnt/sshfs/helios/cluster-data/containers-data/gemserv/data/gmi.bacardi55.io/
