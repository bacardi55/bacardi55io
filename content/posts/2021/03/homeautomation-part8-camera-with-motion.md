---
title: "Home Automation, part 8: Entry door detection with Motion and NodeRed"
date: 2021-03-23T23:59:13+01:00
tags:
- homeautomation
- nodered
- domoticz
- raspberry pi
- telegram
categories:
- selfhosting
---

## Context

In this post, I'll describe how I use motion, NodeRed, MQTT and Telegram to manage everything related to my entry door camera.

The TLDR; is: when the camera pointing at the entry door sees some movement, it will:
- sent a MQTT message right away (that triggers an alert on my phone via Telegram);
- Start recording video;
- Take pictures in the meantime. Pictures are scp to another server in the house and outside;
- Once the video is done (no more movement), it will save it on drive and send it to my phone via Telegram
- Option: Ability to request a snapshot (picture of the entry as of right now) via Telegram.

### Used devices / software

- A [raspberry pi 0W](https://www.raspberrypi.org/products/raspberry-pi-zero-w/) with a [fisheyes picamera](https://www.pishop.us/product/rpi-camera-h-fisheye-lens-supports-night-vision/), running [motion](https://motion-project.github.io/), named in this blog "PiCam" for simplicity (named in reality `nickylarson`);
- [NodeRed](https://nodered.org/) and [Mosquitto](https://github.com/eclipse/mosquitto) installed on my [homelab cluster](https://bacardi55.io/pages/home-lab/);
- [Telegram](https://telegram.org/) on my phone

## PiCam Installation

The following are installed not on the homeautomation cluster but on the PiCam (aka `NickyLarson`).

### Motion

#### Installation

On raspbian/RaspberrypiOS or debian, you can install it as usual:
`sudo apt install motion`

##### Configuration

I let you read the [motion documentation](https://motion-project.github.io/motion_download.html) and you can find my full [motion.conf here](https://github.com/bacardi55/scripts55-cleaned/blob/main/nickylarson/motion.conf), but the important pieces are:

```motion.conf
daemon on
```
Run motion as deamon.

```motion.conf
videodevice /dev/video0
v4l2_palette 17
```
This works for the pi camera, [see here](https://motion-project.github.io/motion_config.html#basic_setup_picam), adapt if you are using something else.


```motion.conf
webcontrol_localhost on
```

To enable control of motion via http requests from localhost. This is needed for the MQTT handler script to request a snapshot (picture of "right now").

```motion.conf
target_dir /var/motion/pictures/
snapshot_filename %v-%Y%m%d%H%M%S-snapshot
picture_filename %v-%Y%m%d%H%M%S-%q
movie_filename %v-%Y%m%d%H%M%S
timelapse_filename %Y%m%d-timelapse
```

To indicates where files are stored and how they are named.

```motion.conf
on_event_start /home/pi/scripts/alert_motion_start.sh
on_event_end /home/pi/scripts/alert_motion.sh
```

And where the magic happens, indicates the script to run when an event starts or ends.

#### Motion Events Scripts

As configured above, we need 2 scripts, one for when an event starts and one when an event stops.

##### Alert Starts

The `alert_motion_start.sh` script looks like this:

```bash
#!/bin/bash

# This script is run after the event starts.

logfile="/tmp/alert.log"
date=$(date)

echo "" >> "$logfile"
echo "$date" >> "$logfile"
echo "Motion event started" >> "$logfile"

# Get home mode.
echo "Starting alert" >> "$logfile"
mode=$(curl -s -X GET http://<IPOfNodeRed>:<PortOfNodeRed>/api/home/mode | jq -r ".house_mode")

echo "current house mode: $mode" >> "$logfile"

if [ -z "$mode" ]; then
    mode="empty"
fi

# If mode is not manual or full, raise an alert
if [ "$mode" != "full" ] && [ "$mode" != "Manual" ]; then
    mosquitto_pub -h <MosquittoServerIP> -p <MosquittoPort> -t home/entry/motion -m 1 -q 2
fi
```

Or the latest version always [here](https://github.com/bacardi55/scripts55-cleaned/blob/main/nickylarson/alert_motion_start.sh).

The 2 main parts are:
```bash
mode=$(curl -s -X GET http://<IPOfNodeRed>:<PortOfNodeRed>/api/home/mode | jq -r ".house_mode")
```

This asks NoredRed via http GET request the current house mode. It means that NodeRed shoud respond the home mode on this URI. We'll see below how this works.

```bash
# If mode is not manual or full, raise an alert
if [ "$mode" != "full" ] && [ "$mode" != "Manual" ]; then
    mosquitto_pub -h <MosquittoServerIP> -p <MosquittoPort> -t home/entry/motion -m 1 -q 2
fi
```
This will send an alert via MQTT if the house mode is not full or manual (this mode disable everything). It should never be the case anyway as I disable the camera and motion when I'm home (more below) but before I used to have the camera enabled at night.

As you have guessed, you will need to install `mosquitto-clients` to get the `mosquitto_pub` command.


##### Alert Ends

The end script looks like this:

```bash
#!/bin/bash

# This script is run after the event end.

logfile="/tmp/alert.log"
date=$(date)

echo "" >> "$logfile"
echo "$date" >> "$logfile"

# Get home mode.
echo "Event end alert" >> "$logfile"
mode=$(curl -s -X GET http://<IPOfNodeRed>:<PortOfNodeRed>/api/home/mode | jq -r ".house_mode")

echo "current house mode: $mode" >> "$logfile"

if [ -z "$mode" ]; then
    mode="empty"
fi

# If mode is not manual or full, raise an alert
if [ "$mode" == "Away" ]; then
    # Retrieve latest video:
    file=$(ls -t /var/motion/pictures/*.mp4 | head -1)
    curl -X POST  http://<IPOfNodeRed>:<PortOfNodeRed>/api/home/entry/camera/event/end -F "file=@$file" > /dev/null 2>&1
fi
```
Latest version on git [here](https://github.com/bacardi55/scripts55-cleaned/blob/main/nickylarson/alert_motion.sh).

As for the starts script, the 2 important parts are:

```bash
mode=$(curl -s -X GET http://<IPOfNodeRed>:<PortOfNodeRed>/api/home/mode | jq -r ".house_mode")
```
To request current house mode, and:

```bash
if [ "$mode" == "Away" ]; then
    # Retrieve latest video:
    file=$(ls -t /var/motion/pictures/*.mp4 | head -1)
    curl -X POST  http://<IPOfNodeRed>:<PortOfNodeRed>/api/home/entry/camera/event/end -F "file=@$file" > /dev/null 2>&1
fi
```
In this case, I retrieve the latest mp4 file (video captured by motion), and send it via HTTP request to NoredRed. I didn't find a better solution than an HTTP request to send a file but it works well. We'll see below how to configure NodeRed to react accordingly.

Make sure that the path, video format and naming match the values in the script!

You should now be able to start / stop motion with:

```bash
# systemctl {start,stop} motion.service
```

Now that motion is configured and working, let's see how NodeRed can control it via MQTT.

### MQTT handler

In order for NodeRed to controll the PiCam via MQTT, PiCam needs to be be able to listen and interact with MQTT. For this, I created a python script for all the MQTT interaction. The script is too long to be fully copied within a blog post, but you can find it [here](https://github.com/bacardi55/scripts55-cleaned/blob/main/nickylarson/mqtt-gateway.py). The script will basically:

- Subscribe to the right topic (`client.subscribe("home/entry/#")`) on start;
- listen to message for 2 topics:
  - `home/entry/snapshot`: In case I request via telegram a picture of "right now" Use requests to send the file once available;
  - `home/entry/camera`: to enable / disable motion:
    - Depending on the value, motion is {enabled,disabled} via `subprocess.Popen("sudo systemctl {start,stop} motion.service", shell=True, stdout=subprocess.PIPE).stdout.read()`.

The paho.mqtt.client python library is used by the script so you need to install it:
```bash
pip3 install paho-mqtt
```

Also, the `requests` library is used to send the snapshot via http.

```bash
pip3 install -U requests
```

Have a look to the [full script](https://github.com/bacardi55/scripts55-cleaned/blob/main/nickylarson/mqtt-gateway.py) it will help :).

To start the script at launch, I added this cron job:
```cron
@reboot sleep 30 && /usr/bin/python3 /home/pi/scripts/mqtt-gateway.py > /tmp/mqtt-gateway.log 2>&1
```
via `crontab -e`.

Ok, now that PiCam is ready, we need to configure NodeRed.


## On NodeRed

On the NodeRed side, we need to configure:
- The HTTP requests endpoints:
  - `/api/home/mode`: A GET request to retrieve the home status;
  - `/api/home/entry/camera/event/end`: Receive the "end event" generated video file;
  - `/api/home/entry/camera/snapshot`: When a snapshot is received.
- MQTT messages to be sent to:
  - Enable/Disable Motion;
  - Request a snapshot.

### NodeRed flows

#### House Mode (GET)

![NodeRed API Get Home](/images/posts/2021/03/nodered-api-gethome.png)

The `prep response` function only set the house mode (global variable) in the payload that is then converted to JSON and send as the response of the API call with the 200 status code.

#### Event End (POST with attachment)

![NodeRed API Events](/images/posts/2021/03/nodered-api-eventends.png)

This one is a bit more complex. Basically, when receiving the API request with the file in the received payload (in my case `msg.req.files[0].buffer`), the buffer is copied it to a specific file (`/data/camera/entry.mp4` in my case).
Then, a 200 response is sent back and the video is then sent to me via telegram. To send a video, all I need is to indicate that the type is video and content is the path to the file, with a caption saying «Home Intrusion!».

#### Snapshot (POST with attachment)

![NodeRed Snapshot](/images/posts/2021/03/nodered-api-snapshot.png)

The snapshot works the same way as above.

![NodeRed MQTT message for entry cam](/images/posts/2021/03/nodered-mqtt-entrycam.png)

When, via telegram, I request a snapshot, (bottom part of the screenshot), an MQTT message is sent to start motion (see above with the MQTT handler). There is a 1 minute delay just to make sure motion is correctly started. Then a request is actually sent for the snapshot over MQTT.

The MQTT handler described above is then taking care to request the snapshot and then send it back to nodered.

#### Enable/Disable Motion

See the previous screenshot. In there, we see the simple camera on/off settings that is then sent over MQTT so that the MQTT handler listen to when start/stop motion.

## Bonus

### Backup pictures as arrive

I have a script that runs to check if there are new files (pictures) created by motion. I do this because pictures are created on the fly from motion. It means that on top of the video I will have pictures too. Because a potential attacker can see the PiCam when entering and potentially destroy it before the video has been fully taken, at least the picture are saved to another machine quickly.

To do this, I use `inotifywait` to react on new files. First, install it via:
```bash
sudo apt-get install inotify-tools
```

This is my shell script that scp files as they appear in the motion directory (look at the configuration to see where they go):

```bash
#!/bin/sh

logfile="/tmp/watcher.log"
date=$(date)

which inotifywait >/dev/null || err "you need 'inotifywait' command (sudo apt-get install inotify-tools)"
pkill -f "inotifywait -m /var/motion/pictures -e create -e moved_to" # kill old watcher

inotifywait -m /var/motion/pictures -e create -e moved_to |
    while read path action file; do
        #echo "The file '$file' appeared in directory '$path' via '$action'"
        echo "" >> "$logfile"
        echo "$date" >> "$logfile"
        scp "$path$file" <user>@<server>:/path/to/directory >> "logfile" 2>&1
        echo "Copying new files $file" >> "$logfile"
    done
```

Then, I start this script at boot with a cron job as well:
```cron
@reboot sleep 50 && sh /home/pi/scripts/motionfiles_watcher.sh
```

In reality, pictures uploaded to this other local server will then be exported to an external one too, but that's not part of this blog post.

### Clean old files

As the picture directory can grow quickly, I have a cleaning script that runs daily:

```bash
#!/bin/sh

logfile="/tmp/cleaning.log"
date=$(date)

echo "" >> "$logfile"
echo "$date" >> "$logfile"
echo "Cleaning old images" >> "$logfile"

sudo find /var/motion/pictures/ -mindepth 1 -mtime +4 -delete >> "$logfile" 2>&1

echo "Cleaning done" >> "$logfile"
echo "" >> "$logfile"
```

Started via cron job as usual:
```cron
0 7 * * * sh /home/pi/scripts/motionfiles_dailyclean.sh
```

This post is wayyyyy longer than expected, so I'll stop here, but feel free to reach out for additional info (:.
