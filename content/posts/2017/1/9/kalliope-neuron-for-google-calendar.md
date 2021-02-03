---
title: Kalliope neuron for google calendar
date: 2017-01-09
tags:
- kalliope
- home_automation
---


## Introduction

Even though I'm not a big fan of using Google (or any GAFAM) products, I must use this one for managing some of my meetings.

So, I worked and published a neuron that allows [Kalliope](https://github.com/kalliope-project/kalliope) to talk to google calendar so that kalliope can tell me what are my next meetings. The idea of the neuron is very simple and only work on read only.

## Installation

### Configuring your google calendar

First, you need to create an app in your [google developer console](https://console.developers.google.com) and allow the google calendar API.
For this you can go directly via [this wizzard](https://console.developers.google.com/flows/enableapi?apiid=calendar&authuser=1&pli=1)

or follow the step 1 of [this tutorial](https://developers.google.com/google-apps/calendar/quickstart/python)

Copy / pasting the relative steps here:

* Use this wizard to create or select a project in the Google Developers Console and automatically turn on the API. Click Continue, then Go to credentials.
* On the Add credentials to your project page, click the Cancel button.
* At the top of the page, select the OAuth consent screen tab. Select an Email address, enter a Product name if not already set, and click the Save button.
* Select the Credentials tab, click the Create credentials button and select OAuth client ID.
* Select the application type Other, enter the *name of your app*, and click the Create button.
* Click OK to dismiss the resulting dialog.
* Click the file_download (Download JSON) button to the right of the client ID.
* Move this file to your working directory and rename it client_secret.json.


### Installing Kalliope neuron

As any other neurons, just do

```bash
      kalliope install --git-url https://github.com:bacardi55/kalliope-google-calendar.git
```

And now, you need to configure the neuron to make it works.
The way I'm doing it, is:

* Create a hidden directory in my kalliope's home for the google calendar secret files (do not put them in a public git repo ^^).

```bash

    mkdir /home/pi/.google_calendar
    mv /home/pi/client_secret.json ~/.google_calendar/
```

* Configure your brain:
```yaml

    ---
      - name: "Google-agenda-next"
        signals:
          - order: "what are my next meetings"
        neurons:
          - google_calendar:
              credentials_file: "/home/pi/.google_calendar/credentials.json"
              client_secret_file: "/home/pi/.google_calendar/client_secret.json"
              scopes: "https://www.googleapis.com/auth/calendar.readonly"
              application_name: "App name"
              max_results: 3
              locale: fr_FR.UTF-8 # needs to be an installed locale
              file_template: "templates/fr_google_calendar.j2"
```

Remember to update the path if they are not the same and the application name as well.
Your local needs to be installed as well on your system.
And write your own template :)

Here is my example:

```jinja

    {% raw %}
    {% if count > 0 %}
        Your next meetings are
        {% for event in events %}
            on {{ event['time']['weekday'] }}, {{ event['time']['day'] }}, {{ event['time']['month'] }}, à {{ event['time']['hour'] }} hour, {{ event['time']['minute'] }} :
            {{ event['summary'] }}
        {% endfor %}
    {% else %}
        You don't have any meeting coming up
    {% endif %}
    {% endraw %}
```

## Limitation

Neuron is *read only* so you can't create calendar events from this neuron, but I'm always happy to integrate pull requests :)
