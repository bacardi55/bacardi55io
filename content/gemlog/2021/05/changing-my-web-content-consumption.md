---
Title: "Changing the way I consume content on the internet"
date: 2021-05-09T03:30:00+02:00
lang: en
---

# Changing the way I consume content on the internet

## Context

For some times, I was looking for reducing the time spent reading stuff on either my computer or phone screens. I have the habit of following lots of RSS feeds and opening lots of articles from the fediverse or other places I want to read and leave them in opened tabs. I also leave some feeds unread so I can be sure not to forget them as well. It usually ends up with a massive amount of tabs opened that I often forgot because I have so many.
I don't think I suffer (much) of FOMO (Fear Of Missing Out) if that's what you think reading this first sentences (I'm currently writing a lot bigger article that will talk about this), but I want to follow specific topics and enjoy reading blog posts for fellow tech or non tech smart people :). I don't care too much about missing info on social media or other, just that when I see an article that I think I'll enjoy, I want to make sure I put the chances to read it. Too often, I see some tabs on subject that became too old or on things that I don't care about anymore, I then just close them without hard feelings^^.

I started using Wallabag (via wallabag.it) to save articles for later a long time ago, but that didn't help "enough". It just changed the fact that some articles where now in wallabag as unread instead of in my RSS feed reader.

As you can guess, this is not very optimal. Having 100s of tabs opened is not performant (specially with the current state of the bloated web) and isn't really practical. Having my RSS reader or wallabag with unread articles helps me read them on my phone on the move so often I end up with articles opened everywhere.

And then came gemini… Which I do love (hence why you are reading this content only on the gemini space) that added not only new great content to read, but also another set of tools: new browser (I use both Amfora and Lagrange on my laptop, Ariane on my phone), new gemini/rss feed reader (I chose comitium), …

So I started thinking of a better way, both in term of ease of consumption and at the same time reducing my time on "regular" screens for a better sleep and less eyes fatigue.


## The basic ideas

The screen part of this quickly pushed me towards having a e-ink screen in the middle of this mainly for reading. I believe it is the best thing after real paper. I do love reading on paper but that wouldn't be a good thing for the environment. I already have lots of books (>100) and manga (>1200) at home so I use enough paper as it is^^.

I had many ideas around an e-ink device:
* Build a tablet device with a RaspberryPi 0W and an e-ink screen. Touchscreen e-ink was very rare and quite expensing and I wasn't sure of the quality would be worth the money.
* Build a small laptop type of device (think PiTop but with an e-ink screen). That was like my plan B if nothing better existed.
* Use a simple ebook reader device built for reading. Most of them are on systems very closed and flexibility would have been an issue. Reading gemini content on it would have been hacky at best.
* Use a remarkable2 or similar (like supernote 5x) but that was for me the same as issue as a ebook reader.
* I even thoughts on buying an e-ink screen as a 3rd external screen for my laptop, but same issue as touchscreen e-ink, very rare and very expensive.
* And then I finally found something very close to what I wanted: an Android tablet with an e-ink screen!

I would have prefer a linux e-ink tablet but I guess it is too soon (or too optimistic to find these)^^.

Anyway, the advantages where:
* As it is android, I can install FOSS app simply with F-droid. I know that the minimum things I need are available on it (see below)
* With the USB OTG port, I can connect my physical keyboard (or my small "on the move" keyboard via bluetooth), so I can use it as a writing device for gem/blog posts too without all the distraction of a computer.
* I can easily share files between devices using syncthing (app available on F-droid) which is a great piece of software to keep folder synchronized between devices.
* Even though it is an Android tablet, the e-ink screen limits what I can do on it and thus help me keep it a "distraction free" device.
* Bonus, it works great to take hand written notes too. I prefer taking hand written notes, it helps me remember better, so I usually have a notebook and a pen. But taking notes the whole week on it was a great experience and I can easily sync them via syncthing to have them on my laptop too.

So finally, I ended up buying the Onyx Boox Air that had very good review except for the included pen and I bought the Noris digital Jumbo (disclaimer: I have no affiliation whatsoever with Onyx or Staedtler ^^). It is an expensive device but after one week I can say it is worth the money, at least for me and my usage. I really enjoy using it daily, both for using it as a "pen and paper" to take notes and as a reading device. One of the advantage of an e-ink screen device is the autonomy, I only charged it once for a full week usage (both reading and note taking). I don't use much the frontlight to be honest but I find it awesome!

A very pleasant surprise was that because it is an e-ink device, it is not by default activated with google services and you have to manually enable them and connect your google account… Well, that's nice for me that didn't want to anyway :)
Also, I can fully use the device without creating an Onyx account either, I still get the update from the servers so that was as well one less thing to worry about.

I just used the default included browser once to go to F-droid and download their APK and installed it manually. Then I only installed app from there.


## "Distraction free" reading device

The e-ink screen helps limiting the "distraction" apps that would need a higher refreshing rate like games or video streaming (eg: youtube or twitch). Limiting myself with F-droid without any alternative installed like the google-play is even better.

In the end, all I installed (so far) are:
* Ariane: A gemini browser
* F-droid: To install all the other apps
* FairEmail: Email app. I've been using k9 on my phone for so many years that I thought I may try something else
* Fennec: Web browser (Firefox)
* KOReader: ebook reader
* Markor: Mainly for the markdown editor where I can write with an external keyboard
* Readrops: RSS feeds, connected to my freshrss instance.
* Wallabag: A read it later app connected to my wallabag.it account (wallabag is opensource and can be easily selfhosted. I mainly use this service instead of selfhosting it to help the project)

I know what you might say. FairEmail isn't really a "no distraction" app. Well, yes and no. I've removed the auto emails fetching and all notification. I mainly use it to share links with friends when I read something I like. I usually use signal as an IM app but you must have google services for it so I won't have it on this device.


## My "new" content consumption workflow

I enforced myself new "rules" when I started using this device:

General rule: 30min to 1h before going to bed, if I want/"must" be behind a(ny) screen, it must be on the e-ink one. It does help for better sleep and eyes fatigue. I admit, I haven't followed the rules every nights this week, but 5 out of 7 is a good start.

For the web:

- When looking at my RSS feeds, for the articles I want to read, I open them to have a quick look at it. Either I decide to read it now or save it in wallabag (via the firefox add-on) and close it right away. Sometimes, I admit I still leave some links opened in a tab when I think I'll have time to read them during the day. If that's the case, I can simply close the tab and mark the article as read in wallabag. If not, I now clean the tabs in the morning based on the reading of the night before. Very easy and quick as I now have a lot less tabs few opens.
- At the end of the day, my RSS feeds must be empty. It doesn't mean I must read everything but at least I have saved the article I want and trashed the others. If I'm being honest I do have one feed that is excluded for this nightly purge^^.

Using wallabag like this makes me classify contents faster and just this already saves me some time and helps me keep focus on the thing i really want to :).


For gemini:

Unfortunately, Wallabag doesn't support gemini. I created [a github issue](https://github.com/wallabag/wallabag/issues/5272) for it, so we never know :). Gemini links can still be added but the content is not loaded. It can still be used though to share gemini links between devices.
On gemini, I have a lot less feeds and they only are gemini feeds, so less content than in my web rss feed reader. I try to follow feeds on gemini if the author provides both. That's also why I only update comitium feeds every 6 hours and not more.

Anyway, gemini content being less numerous, I use a way simpler process: I just browse my comitium feed page on each device. It is simply and neatly displayed and thus I can easily see the content of the day (and past days) and usually access the one I want. There are usually less than 10 new gemlog entries per day in my comitium feeds page so I don't really need the same level of centralization that I have through wallabag for the webs. Usually, when I find a gemini page I want to read via the fedi, the mailing list or others places, I add the capsule feed in comitium so I can see it on the tablet too. If it's not a feed but just a very specific page, I can still save it in wallabag as a sharing mechanism between device as a worst case. I may try to find something better in the future if the feature request of adding gemini content is refused by the wallabag team.


## Conclusion

I may write about the other usage I have with my Boox Air, but to be honest, its great to see how I could both reduce the time spent on a regular screen and as well enjoy even more all the beautiful content available online, both on the web and gemini, but this post is already way too long so I'll stop here.

A cool thing also that I noticed, is that reading on an e-ink device makes me feel more my level of fatigue (less blue-light stimulation) and thus I usually end up in bed earlier these nights.

That doesn't prevent me from doing other things than reading, for example, most of this article has been written on it (with my physical keyboard plugged in, or I would have given up a long time ago :D).
