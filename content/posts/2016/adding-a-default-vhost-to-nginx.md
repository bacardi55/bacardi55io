---
title: Adding a default «vhost» to nginx
date: 2016-12-07T21:00:00+01:00
tags:
- nginx
category:
description:
---


Today I wanted to install this blog on my new [nginx](http://nginx.org "nginx") server. As this site is simply static html file, I thought why not using it as well to try to learn how to use it.

So I created my server :


```nginx

    {% raw %}
    server {
      listen *:80;
      server_name bacardi55.org;
      root /var/www/b-55-log/web;

      access_log  /var/log/nginx/blog_access.log;
      error_log   /var/log/nginx/blog_error.log;
    }
    {% endraw %}
```

Then, I wanted to add two other domain to redirect to this one:


```nginx

    {% raw %}
    server {
      listen *:80;
      server_name domaine2.tld domaine3.tld;
      access_log /var/log/nginx/other_domaine.access.log;

      rewrite        ^ http://bacardi55.org permanent;
    }
    {% endraw %}
```

But It didn't work as I didn't have a default server.
The redirection wasn't working as nginx considered my blog server the default. So the to 2 other vhost kept working and wasn't redirected. I didn't like that because I don't want this blog to be indexed 3 times by search engines.

So to correct this, I had to create a default server that redirect everything that didn't match any of my other server_name.
This is what I put in my conf file:

```nginx

    {% raw %}
    server {
      listen *:80 default;
      server_name _;
      access_log /var/log/nginx/default.access.log;

      server_name_in_redirect off;

      root  /var/www/;
    }
    {% endraw %}
```

Be careful though, I followed the documentation and put

```listen 80 default;```

And there you go :)


But it didn't work. I actually had to put the `IP:80` instead of just `80` as in the official doc.

I may have miss something in my nginx that make it doesn't work but if than can help someone other than me :).

PS: Thanks to my friend [Rustx](http://blog.teknicity.net/) to advising me not to use the IP address but only *:80.
