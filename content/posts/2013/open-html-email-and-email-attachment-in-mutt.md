---
title: Open html email and email attachment in mutt
date: 2013-03-07T21:00:00+01:00
tags:
- mutt
- email
category:
description:
---


## Quick intro

I don't write a lot about it, but I use [mutt](http://mutt.org) to read my emails. You can easily guess why:

- Less memory consuming than thunderbird or evolution;
- Faster;
- Managed by keyboard;
- Used in a terminal :)

For those who know me, they know that I really don't like using my mouse. I find that each time I remove my hand from my keyboard to go on my mouse, I loose time. That's why I'm using [vim](http://vim.org) (that and the fact that it's the best editor :p</troll>), or why I'm using a tiling Window Manager ([i3](http://i3wm.org)) or why I'm using mainly application that run inside a terminal.

It's simply more consistent with the way I use my computer to work and code.

Using mutt might seems like a real nerdy thing to do in 2013 but if you configure it properly, it's as good as any (but less RAM consuming) :).

## Html email

I have to admit, I also use mutt because in my opinion, email should only be text. I hate html email and I hate even more when people send html email without the text alternative.

But, we're in 2013 and I receive html email every day. When some of them don't have the text alternative, I can't always decide to throw it and ignore it (even if I often do). Sometime, even important email and not only spam can be in html only.

They are several options to handle this and I choose to use the ``~/.mailcap`` file that contains a list of programs to use depending on the [mime type](https://en.wikipedia.org/wiki/Internet_media_type) of the file.

To read html email inside mutt, just add this in your `~/.mailcap`:


```bash
    text/html; links %s; nametemplate=%s.html
    text/html; links -dump %s; nametemplate=%s.html; copiousoutput
```

**You need to have links installed**.

And now, you'll be able to click on the html attachment and see the content of the email easily :).


## Open email attachment

Ok, so now that we have done this for the html email, I'm sure you understood how to be able to open other attachment files: You just need to add new lines in your mailcap file :).

Here is my mailcap file as an example:

```bash
    text/html; links %s; nametemplate=%s.html
    text/html; links -dump %s; nametemplate=%s.html; copiousoutput
    text/*; less
    image/*; gpicview %s
    application/pdf; evince %s
    application/msexcel; soffice %s
    application/msword; soffice %s
    application/vnd.ms-excel; soffice %s
    application/vnd.openxmlformats-officedocument.wordprocessingml.document; soffice %s
```

I'm using gpicview for all images, soffice for office document (libre office and MS office document), less for text and evince for pdf.

You can add more line here for other type of file (eg: video, sound, …).

All you have to do now is press « v » on a email that has attachment and then press enter on the attach file and it will be open by the right program.


## Bonus

If you don't know the mime type of a file, you can use ^e (ctrl+e) on a attached file in mutt to know the mime type. Then you just need to copy it and paste it in your mailcap file and choose which program will handle the files with this mime type :).


Hope this helped some of you :)
