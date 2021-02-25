---
Title: "My thoughts on Gemini favicon.txt"
date: 2021-02-25T23:30:00+01:00
---

This gemlog entry is a summary of my thoughts about the favicon.txt thing in Gemini.
I will not discuss here the drama that happened on both the [mailing list](https://lists.orbitalfox.eu/archives/gemini/2021/thread.html) and on [Amfora github](https://github.com/makeworld-the-better-one/amfora/issues) page as I don't think it would bring any value here.

**Disclaimer**: These are just my thoughts… I'm not part of the Gemini core team nor a long time Gemini user (only a couple of weeks). So I'm neither saying I am right nor that the Gemini community should listen to me. It is just a way to put my thoughts about it "on paper".


## Context

Last week-end, by total randomness while checking my Gemini server logs, I notice many errors indicating a missing favicon.txt file… I am well aware of the favicon.ico in the web world but this favicon.txt was a first for me.

I started looking around but didn't find much on the web. I did find more on Gemini though with a [page describing a proposal RFC for a favicon.txt](gemini://mozz.us/files/rfc_gemini_favicon.gmi) file at the root of the capsule. The summary of the RFC is that a single favicon.txt file containing only one emoji would serve as the favicon.

Continuing some research, I found that my beloved Gemini browser [Amfora](https://github.com/makeworld-the-better-one/amfora) has a configuration setting to use favicon as the tab "name" and thought it might be cool.

Following this "discovery", my nerdbrain thought: "oh something new, let's play with this". So right away I created a favicon.txt and enabled favicon in Amfora setting.

I [talked about it on mastodon](https://framapiaf.org/@bacardi55/105755213984788082) and received a interesting [response](https://bsd.network/@solene/105758145681937128) telling me that « that is exactly what gemini is trying to avoid ».

I then stopped a bit thinking about it as just "a nice new thing" and put it into the context of my understanding and my feeling of what Gemini is and / or should be.


## Situation

The state of Gemini is, as stated on the [specification page](gemini://gemini.circumlunar.space/docs/specification.gmi) « Although not finalised yet, further changes to the specification are likely to be relatively small. ».
So even though the main ideas around Gemini are already decided, there are still some possibilities to make evolution happens (whatever other people might thought about this).
That being said, it does not mean that anything should be added anyway, but the door is not fully closed.

The favicon RFC itself has been created some time ago, in early June 2020, so it is not really new. Until not long ago, the motivation part was empty but it is funny to see that after all the drama from the mailing list, the motivation part now state « To spread a bit of joy around geminispace. » (and I do like the motivation there, even more after reading all those email threads).


## My take on it

Again, I'm neither the creator nor even an early adopter of Gemini so I'm no expert. I'm not a regular user of gopher either so again my point of view is not only just mine but from a very new Gemini user.
And to be faire, I do believe that there are good arguments for both side (and that the geminispace needs to joy…).

### Why do I think it wouldn't be that bad to have them?

It is known that accessing a content/page on Gemini should only take one request. Having a favicon would break this.
But this would be mitigated by caching the favicon during a session (like amfora I believe) and limit that request to one by session, which would be ok…

I also do think it is fun and mostly harmless, and if capsule owners find emoji that they really like and represent them, why not, as long as it stay fully optional and that all clients still works without one without degradation.


### Why do I believe favicon should not be used?

I am a big fan of having a single request per "content" (page) protocol. It makes it so efficient and resilient that I don't like the idea of messing around with this principle.

It also feel like this is a feature coming from the web that was adapted to Gemini. And I strongly believe we should stop thinking of web things regarding Gemini, and for once, even as nerd enthusiast, focus more on what the goal is than on "cool features". But this is very subjective both in term of what's "cool" vs "useful".

Even though very unlikely, it could still be used to do some tracking through it and that for me might one of the biggest "red flag" for its usage.


## My choice

For those browsing this Gemini page with a client having favicon enabled, you can see that… I am not using a favicon.

Indeed, my personal believe for this is that it shouldn't be part of Gemini because in the end it doesn't add anything to the content and break a bit Gemini philosophy, in my opinion at least.

Yes, for now, with the small (but growing fast!) number of Gemini capsules online, emoji "collision" (= multiple capsules using the same emoji) is very unlikely. But at some point there is a statistically high possibility that it will happen. And when that will be the case, favicon will be entirely useless.

That last part plus the potential tracking behind it makes me think it is not a good idea.

It seems that the creator of Amfora decided to [remove it as well after some thoughts](https://github.com/makeworld-the-better-one/amfora/issues/199#issuecomment-783645893).

That being said, I will not get too mad if that becomes part of Gemini, but I will not use one for my capsule nor enable it in any client.


## A small conclusion…

This post is wayyyy longer than I expected… But it does open the question about what Gemini governance should be…

Should it be a more "democratic" and/or participative way or should the creator(s) always act as the Benevolent Dictator for Life (BDFL) and make all the final decisions?

I don't know which system is better (if any), there are advantages and drawbacks for both… But at the meantime it seems that the BDFL system is failing a bit for Gemini right now as the BDFL is very quiet (but that's normal, I insist, that everyone has a life outside of community stuff!).
Would it be a good time to change it or not, well, when I read the mailing list I'm not sure. So I'm hopping our BDFL is reflecting on the final decision and will publicly express himself soon.

It would help to put this drama behind the Gemini community and move forward together and not against. It is the best way to have a weird bipolar Gemini space where some capsules would need "advanced" clients to browse them because of non compliant standards. It would then go back to the same browser war that we saw on the web and the result of having a single engine dominating the space… And at this point a new standard will emerge to replace Gemini yet again…

I will conclude by saying that History has shown us that given the possibility to do "bad", at some point someone will. So the Gemini community really needs to keep that in mind when thinking of "mainly harmless features". Mainly is not strictly and thus a slippery slope!
