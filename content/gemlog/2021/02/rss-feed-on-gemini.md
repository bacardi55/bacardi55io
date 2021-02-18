---
title: "RSS feed for my gemini capsule"
date: 2021-02-18T00:55:00+01:00
---

Today, I reworked a bit this gemini capsule so that both visitors can subscribe to my blog posts or gemlog posts.

On [my blog](https//bacardi55.io), I list on the homepage both blog posts and gemlog posts.
Clicking on a gemini post on the blog brings you to dedicated page explaining how to reach gemini and link gemlog via their gemini link.
Gemlog content is not available via http (without a proxy at least).

I did the same for the RSS feed that lists both gemlog and blog posts and point gemlog content to the same dedicated page on my blog.

If you are interested, I have explained how I setup this [here](gemini://gmi.bacardi55.io/posts/2021/02/mixing-blog-and-gemlog-on-homepage-and-rss-with-hugo.gmi).

For this gemini capsule, I decided to do a bit differently. As you can see on the root page of this capsule, I separate the gemlog posts and blog posts into 2 different lists.
Also, each content type has its own full listing page ([/gemlog/](gemini://gmi.bacardi55.io/gemlog/) and [/posts/](gemini://gmi.bacardi55.io/posts/)).

Today, I also added an RSS feed for both. I also decided not to have a mixed RSS feed with both content mixed.
I will let the visitors decide if they want to follow my blog (tech content) and / or my gemlog (more personal content).

[Blog Posts RSS feed](gemini://gmi.bacardi55.io/posts/index.xml).
[Gemlog Posts RSS feed](gemini://gmi.bacardi55.io/gemlog/index.xml).

You can look at the [git repo of this blog](https://github.com/bacardi55/bacardi55io) to see how it is all managed via hugo.
