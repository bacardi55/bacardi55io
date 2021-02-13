---
title: "My First Gemini specific post"
date: 2021-02-13T01:00:00+01:00
---

Today, I worked on my on my gemini capsule. The first version I published earlier this week when opening my gemini server was basically a copy of my blog page. It could have been ok if the posts where clean but the conversion was a bit too simplistic and links where not in the right format. As well it was not very flexible.

I basically follow these different links for that first version:
- [Drew Devault article on using Hugo and Gemini (only via gemini)](gemini://drewdevault.com/2020/09/27/Gemini-and-Hugo.gmi)
- [Sylvain Durand blog post on using hugo for gemini (WEB)](https://sylvaindurand.org/gemini-and-hugo/)
- [Stéphane HUC post on using hugo for gemini and gopher (WEB and French)](https://doc.huc.fr.eu.org/fr/web/hugo/hugo-gemini-gopher/)

These solution did not work for me, at least not the way I wanted my gemini capsule to be, so I had to adapt the process a bit.

My requirements were:
- Having a different weblog and gemlog "sites", meaning at least the homepage should be different. The homepage of the blog only list the blog posts. The homepage of my capsule should first list the latest gemlog posts with a link to all gemlog posts and then latest blog posts with link to full list pages.
- Create blog posts and gemlog posts dedicated list pages on the gemini capsule (not needed on the blog where only the posts are displayed)
- Blog posts must be readable easily via gemini, so cleaned from markdown formatting and displaying links according to gemini specifications, not markdown.
- 1 tool to manage both content types, I didn't want to use 2 different static site generator (or editing files manually)
- (Optional: List gemlog entries on the blog somewhere so at least title would be visible to web visitors)

I'm not going to detail it in this gemlog entry as I'm going to write a blog post (so available via the web and here) soon on the full solution I'm using as it might be useful for other people joining the gemini fun :).

The summary of how I did it was a mix of what is detailed above (creating a different homepage and section template). Pages are not generated for the gemini output though, only homepage and sections have a gemini output. I run after that a script that will move somes generated files around and more importantly transform all .md files into .gmi files. That part was achieve very easily thanks to the [Md2gemini python library (WEB)](https://github.com/makeworld-the-better-one/md2gemini).


It still miss an RSS feed for my gemini capsule, but that's something I'll work on later and I'll write about it after as well, so stay in touch for the blog posts^^.

In the meantime, for this first gemini only post, I wanted to highlight why, not only did I creat this capsule, but also why I want to publish specific content here (even though I'm not publishing enough content on my weblog already).

Here's why (in no particular order):
- To make the gemini space grow, it is not about replicating what the web is (it is neither the goal nor even possible). Yes, tech and geeky blogs are a good start because they are very often simple enough to be just copied from the web to gemini, but duplicating things will not make people come. Having dedicated, unique and interesting (even though that one is more subjective) content will.
- I see my blog mainly as a list of technical posts about what I'm doing for fun with selfhosting, home automation, code or any cool opensource tools. For those who wants, they can read my article on [why I wrote on my blog](gemini://gmi.bacardi55.io/posts/2020/04/25/why-do-i-write-on-this-blog.gmi).
- It means I often refrain myself of talking about other subjects. The article above is one of the rare example of the kind of post I usually do not write/publish. There are a lot of different reasons for that that I don't want to explain here, but at least some of them are mitigated by the smaller gemini exposure (and lack of tracking). That's not to say I'm going to talk about "touchy" subjects like politic, religion or sex, don't worry :) I'm much rather keep these topics for nice conversation around a drink^^. But I might talk here about things like books or other things I enjoy.
- I like the feeling of discovering gemini and want to participate. It reminds me of the early days of the internet :).
- I selfhosted my first website now something like 15 or 16 years ago now in my student bedroom and loved discovering hosting websites back then. It is fun to discover the gemini hosting game too :).
- They are surely other reasons, one of them being for sure the love doing nerdy stuff :).

That will do it for this first gemini only post! Until the next one :).
