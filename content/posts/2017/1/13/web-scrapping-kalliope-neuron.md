---
title: Web scrapping Kalliope neuron
date: 2017-01-13
tags:
- kalliope
- home_automation
category:
description:
---


## Introduction


One of the things I use Kalliopé for is reading information on web sites, eg: reading the latest news of the French sport site "léquipe" or other sites. For this, I'm using the [RSS neuron](https://github.com/kalliope-project/kalliope_neuron_rss_reader) that works quite well :)

Unfortunately, some sites have decided that RSS feeds are too "has been" and if people wants to see what's new, they either have to follow the site on Twitter or just come on the site everyday… I found this behavior quite distasteful as I'm still a heavy RSS users…

So in order to be able to ask Kalliopé to read information on line for me, even when no RSS feed is available, I created a simple web scraper neuron.


## Installation

```bash
    kalliope install --git-url https://github.com/bacardi55/kalliope-web-scraper.git
```

## Configuration

Once installed, the neuron is pretty simple: you give it a URL, an html tag that contains the list of data you want Kalliopé to read. Then on this list you give Kalliopé what is the html tag for the title and the html for the description.

For example, on google news:

The main selector is : "div.top-stories-section div.section-content div.story" and will return a list of elements (each news are in a div.story tag).
Then, for each news, you indicate how to retrieve the title within this ''… div.story", eg: h2.esc-lead-article-title > a > span
And finally, same for the content of the news: div.esc-lead-snippet-wrapper


Here is a full example of my google news brain file:

```yaml

    ---
      - name: "Google-news-en"
        signals:
          - order: "what are the latest news"
        neurons:
          - web_scraper:
              url: "https://news.google.com"
              main_selector: "div.top-stories-section div.section-content div.story"
              title_selector: "h2.esc-lead-article-title > a > span"
              description_selector: "div.esc-lead-snippet-wrapper"
              file_template: "templates/en_web_scraper.j2"
```

Then, as usual, you need to create the template to indicate to Kalliopé how you want to hear these info, here is an example:

```jinja
    {% raw %}
    {% if returncode != 200 %}
        Error while retrieving web page.
    {% else %}
        {% for g in news: %}
            Title: {{ g['title'] }}
            Summary: {{ g['content'] }}
        {% endfor %}
    {% endif %}
    {% endraw %}
```

Neuron should work on any pages.
Main drawback here is that you are dependent of the site HTML, which is often more changing than an RSS feed or an API… but at least that does the job :)
