---
title: Home Automation, part 2 - NodeRed, Mosquitto and Domoticz on my docker swarm cluster
date: 2020-04-14T20:00:30+02:00
tags:
- homeautomation
- selfhosting
- nodered
- mosquitto
- domoticz
- dockerswarm
- swarmservice
categories:
- selfhosting
description:
---

# Context

Following up with [my home automation concepts and architecture post](/posts/2020/04/12/my-home-automation-system-part-1-context-and-architecture/), today I'll talk about the installation and configuration of the most important parts: [NodeRed](https://nodered.org/) (Brain and Orchestrator, as well as web dashboard), [Mosquitto](https://mosquitto.org/) ([MQTT](https://fr.wikipedia.org/wiki/MQTT) message broker) and [domoticz](https://www.domoticz.com) (Z-wave devices controller).

This post assumes that your setup is at least similar to [my homelab setup](/pages/home-lab/), the TLDR; is:
>  A docker swarm cluster with GlusterFS shared volume running on top of Raspberry Pis :)

This post assume you have also a similar setup or that you understand enough docker and the swarm engine to adapt it to your different needs (Kubernetes, docker standalone, etc...) :-).

Also, this post is not a detailed explanation of what are NodeRed, Domoticz and Mosquitto. If you have no idea what they are or do, I suggest reading a bit more about it.

Ok? Let's go then!


# Installation

I want to install all three (NodeRed, Mosquitto and Domoticz) on my existing cluster, so this is what we will do, but Domoticz will be a bit different due to the need to use a Z-wave controller USB stick.

## Domoticz "standalone" with docker-compose

Because I use domoticz to manage my z-wave devices, it means it needs to access the z-wave USB stick controller. For this with docker, it means you need to run a container with the `--device` option. Unfortunately, at the time of setting it up, this wasn't possible yet with docker swarm (It seems it will be at some point though :)). So my quick and dirty workaround was to simply launch the Domoticz container on one node of the cluster (the one with the USB stick, in my case, I took my manager but that may not be the idea to be honest^^ But that's quick to change if I want to someday :)).

So to do this, all I had to do was to plug the z-wave controller USB stick on my selected raspberry pi (cell[^1] in my case) and create the data directories. If you follow the [same setup as me](/posts/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/)[^2]:

```bash
mkdir /mnt/cluster-data/{containers-data,services-config}/home-automation/
mkdir -p /mnt/cluster-data/containers-data/home-automation/domoticz/config
```

And the configuration file `/mnt/cluster-data/services-config/home-automation/docker-compose-domoticz.yml`:

```docker-compose.yml
version: "3"

services:
  domoticz:
    image: joshuacox/mkdomoticz:arm
    devices:
      - "/dev/ttyUSB0:/dev/ttyUSB0" #adapt if needed
    restart: always
    ports:
      - 8080:8080 #changeme
    volumes:
      - /mnt/cluster-data/containers-data/home-automation/domoticz/config:/config
```

*Nota: As said previously on this blog, I don't publish (yet) my building files and private registry so I use public docker images on my blog post example. When using containers, you should either build your own (more on this and self hosted registry later) or at least have a very strong understanding of how the public image you use is built and what it does before using it. Using unknown containers on your platform is a security risk!*

Start Domoticz service with `docker-compose` directly:

```bash
docker-compose -p domoticz -f /mnt/cluster-data/services-config/home-automation/docker-compose-domoticz.yml up -d
```

`-p domoticz` is to set the name of the service because I didn't want to use the folder name, as it will be used for the swarm services. I could have used homeautomation_domoticz for consistency I guess, but I wanted to highlight that this service is not run like the other (yet T_T).

And voilà, Domoticz should run on `http://<IPAddress>:8080` (or other port if you change it - and you should).

Ok, now we have Domoticz running, let's continue!

## Creating our Swarm Stack with NodeRed and Mosquitto

For NodeRed and Mosquitto, I will simply make them run like any [other services on my docker swarm setup](/posts/2020/03/30/my-home-lab-2020-part-4-running-services-over-https-with-traefik/), by creating a homeautomation stack containing these 2 services. I don't want these services to be available outside my network so I don't configure Traefik with labels on them and use custom port that are blocked at my router level.

Create the right structure, if you follow the same as my filesystem structure (or adapt it :)):

```bash
mkdir -p /mnt/cluster-data/containers-data/home-automation/nodered/data
mkdir -p /mnt/cluster-data/containers-data/home-automation/mosquitto/{config,data,log}
```

Then, create the `/mnt/cluster-data/services-config/home-automation/docker-compose.yml` as usual:

```docker-compose.yml
version: "3.7"

services:
  node-red:
    image: nodered/node-red:latest
    environment:
      - TZ=Europe/Paris #changeme
    ports:
      - "1880:1880" #changeme
    volumes:
      - /mnt/cluster-data/containers-data/home-automation/nodered/data:/data
    networks:
      - homeautomation-net
    deploy:
      placement:
        constraints:
          - node.role == worker

  mosquitto:
    image: eclipse-mosquitto
    ports:
      - "1883:1883" #changeme
      - "9001:9001" #changeme
    volumes:
      - /mnt/cluster-data/containers-data/home-automation/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf
      - /mnt/cluster-data/containers-data/home-automation/mosquitto/data:/mosquitto/data
      - /mnt/cluster-data/containers-data/home-automation/mosquitto/log:/mosquitto/log
    networks:
      - homeautomation-net
    deploy:
      placement:
        constraints:
          - node.role == worker

networks:
  homeautomation-net:
```

Then create the configuration file for Mosquitto. My own is `/mnt/cluster-data/containers-data/home-automation/mosquitto/config/mosquitto.conf`:
```ini
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
```
Because I want to have persistent data. See the [official documentation](https://mosquitto.org/man/mosquitto-conf-5.htmls://mosquitto.org/man/mosquitto-conf-5.html) for more options.

If you change `/mosquitto/data/` or `/mosquitto/log/mosquitto.log`, make sure to also update the `docker-compose.yml` file with the right paths.

As usual, I force containers to run on worker nodes and not on the manager (where there are already specific services running like Treafik, Domoticz, ...).

*Nota: As said previously on this blog, I don't publish (yet) my building files and private registry so I use public docker images on my blog post example. When using containers, you should either build your own (more on this and self hosted registry later) or at least have a very strong understanding of how the public image you use is built and what it does before using it. Using unknown containers on your platform is a security risk!*

Deploy the stack:
```bash
docker stack deploy homeautomation -c /mnt/cluster-data/services-config/home-automation/docker-compose.yml
```

You can go to `http://<clusterIP>:1880` to see if NodeRed is working correctly.

To test if Mosquitto is working correctly, I'm using the following command from my laptop:
```bash
mosquitto_sub -h "10.0.0.101" -p 5883  -t "#"
```
(You need to install `mosquitto-clients` to do so)


Delete the stack:
```bash
docker stack rm homeautomation
```

And voilà for the installation!


# Configuration

And now we have all our 3 software running, it's time to configure them! Obviously, configuring home automation tools like Domoticz or orchestrator like NodeRed is highly dependant of your use cases so I keep this part very thin just to highlight some of the things I had to do. NodeRed and Mosquitto are normally running, all you need is [create flows with NodeRed](https://nodered.org/docs/tutorials/first-flows) (we'll see this later on).

Domoticz needs some additional configuration though to connect the z-wave controller and enable the MQTT relay.

First, go to Domoticz Web UI. If you didn't change the port, it is available at `http://<ClusterIpAddress>:8080`.

## Z-wave USB stick

To be able to manage z-wave devices, we need to setup the z-wave controller USB stick. For this, go to `Setup → Hardware` and add a new «OpenZWave USB» type of hardware:

![OpenZwave USB in domoticz](/images/posts/2020/04/14/homeautomationp2/openzwaveusb.png "OpenZwave USB in domoticz")

Of course, adapt it for your device (may be `/dev/ttyUSB1` or other).

Then, you need to configure the devices that you wish to connect to your z-wave controller and thus to Domoticz.
There are other documentation about this online, I suggest you read this page to start including all your devices:
[https://www.vesternet.com/pages/apnt-85-using-domoticz-with-the-razberry-z-wave-controller#.U_4xlxYU58E](https://www.vesternet.com/pages/apnt-85-using-domoticz-with-the-razberry-z-wave-controller#.U_4xlxYU58E)

This is where every setup might end up being different depending on devices you want to include (eg: remotes or buttons don't work the same as detector for example). If you feel lost about these and don't find resources online, you can also [contact me](/pages/about-me/) :).


## MQTT relay

Ok, we have our z-wave controller installed and configured (you should have devices shown when clicking on the `setup` button next to your z-wave USB stick) and see devices on the `setup → devices` menu link.

What we want now, is for Domoticz to send and receive messages (device status update or command to send to devices) via MQTT to our Mosquitto broker. For this, go to `setup → hardware` again and create a new hardware «MQTT Client Gateway with LAN interface»:

![MQTT client in domoticz](/images/posts/2020/04/14/homeautomationp2/mqtt.png "MQTT client in domoticz")

Obviously, you need to put your Cluster IP address and the port declared in your `docker-compose.yml` file (`1883` by default).

Don't forget to set the "Publish Topic" to `out + /`. The login password fields are optional and needed only if you enabled Mosquitto authentication.

The official documentation should help you if you have difficulties: [https://www.domoticz.com/wiki/MQTT#Add_hardware_.22MQTT_Client_Gateway.22](https://www.domoticz.com/wiki/MQTT#Add_hardware_.22MQTT_Client_Gateway.22)

Your Domoticz is ready to send and receive MQTT messages and manage Z-wave devices connected to your controller USB stick. If you already setup a sensor device, you should see updates from it via MQTT. For this, if you have installed `mosquitto-clients`, you can launch:
```bash
mosquitto_sub -h "<ClusterIP>" -p 1883  -t "#"
```
Update the <clusterIP> and optionally the port and wait a bit, you should see a Domoticz message like this[^3]:

```bash
{
   "Battery" : 100,
   "RSSI" : XX,
   "description" : "",
   "dtype" : "Temp + Humidity",
   "id" : "XXX",
   "idx" : XX
   "name" : "TempOffice",
   "nvalue" : 0,
   "stype" : "XXXXXX",
   "svalue1" : "24.6",
   "svalue2" : "23",
   "svalue3" : "2",
   "unit" : 0
}
```

Of course this is an example but you should have something similar. Later in this series, we'll see how I handle these messages with NodeRed and resend information in a more useful format for the other automation flows.

# Conclusion

This posts is already longer than expected so I'm stopping it here, but there are a lot of other things to say :-). I don't intend to replace official documentation as well on how to use any of this tools. I'll focus in the next posts about the different flows I have setup at home (eg: automation flows, routine, multi room music system, CEC bridge, …), that should be funnier that basic setup stuff :).



[^1]: As explained on [this post](/posts/2020/03/24/my-home-lab-2020-part-2-glusterfs-setup/#fnref:6)
[^2]: I follow the same setup rules as for my swarm services, it makes more sense for backups, but more on that later.
[^3]: Obviously, this highly depends on the devices setup.
