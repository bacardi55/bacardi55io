---
Title: "Gemini tinylog format RFC - A call for help :)"
date: 2021-06-09T00:30:00+02:00
lang: en
---

# Gemini tinylog format RFC - A call for help :)

Following [@Adele gemlog post](gemini://adele.work/gemlog/2021-06-09_Tinylog_structuration.gmi), I'm writing to a quick post to raise awareness (if possible) around the tinylog format in the gemini space.

## Tinylog you say?

The original idea comes from [Drew](gemini://friendo.monster/) that created both a [tinylog format and a tool (lace)](gemini://friendo.monster/log/lace.gmi) to display a timeline with the entries of the tinylog you want to follow.

Tinylogs is a microblogging simple format for gemini. By creating a standard format, it allows tools like the original [lace](https://gitlab.com/uoou/dotfiles/-/blob/master/stow/bin/home/drew/.local/bin/lace) to display a nice timeline of the different entries of the tinylog you subscribed too.

## A standardised format?

I've started using this daily and with other gemini author like [@adele](gemini://adele.work) and [@szczezuja](gemini://szczezuja.space/), started to modify / improve a bit the format describe by Drew.

That's why I've created a [git repository](https://codeberg.org/bacardi55/gemini-tinylog-rfc) with a draft of a kind of RFC for the tinylog format, based on Drew's original idea (and fully compatible with it).

I'd love to have feedbacks / comments / pull requests from anyone to improve it further. There are already a couple of topic being discussed in the issue tracker.

## Other tools?

There are not many tools around tinylogs yet. The original of course is the mentioned [lace](https://gitlab.com/uoou/dotfiles/-/blob/master/stow/bin/home/drew/.local/bin/lace) from Drew.

Adele worked on an online [capsule manager called cockpit](https://codeberg.org/pollux.casa/cockpit) allowing tinylog edition and subscription management.

I've also started working on a tool in golang lately called gtl (for Go TinyLog…) and have been using it daily for some time now and quite happy about it. It is a cli tool for now, but a tui version will also be available soon. You can check out [gtl github page](https://github.com/bacardi55/gtl), there is also a screenshot of it in action.

## What's next?

Well, as said, we'd love some feedback on the tinylog format so feel free to comment on codeberg or even email me directly.

Also, I've seen many other gemini author using a kind of microblogging format and I'd love to have a better standard like for gemini feeds so it gets easier for everyone :).

