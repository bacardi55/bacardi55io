---
title: Alternate css classes easily in twig
date: 2013-02-02T21:00:00+01:00
tags:
- twig
category:
description:
---


Today, I wanted to style a little bit my project.
The basic way in classic PHP project would be to use the iterator variable of your `for loop` with the use of `modulo`.

For example:

``` php
    {% raw %}<div class="<?php echo ($i % 2 == 0) 'odd' : 'even' ; ?>"></div>{% endraw %}
```

In twig, when you use a loop, there are several variables that you can use like `loop.index`, `loop.first`, `loop.last`. I won't copy/paste the official documentation here, you can read it here [twig loop documentation](http://twig.sensiolabs.org/doc/tags/for.html).

To use the modulo function in twig, just use

``` twig
    {% raw %} {{ 10 % 2 }} {% endraw %}
```

And there you go, as simple as in PHP.

Then, using twig, you can do this:

``` twig

    {% raw %} {% if loop.index % 2 == 0 %} {% endraw %}
```

Or in my case I needed this :

``` twig

    {% raw %} {% if loop.parent.loop.index % 2 == 0 %} {% endraw %}
```

To be able to use the index of my parent loop :)

On [this blog](http://nerdpress.org/2012/02/14/modulo-in-twig/), I found the following tips :

``` twig

    {% raw %} {% if loop.index divisibleby(2) %} {% endraw %}
```

Isn't it beautiful ? But it gets even better!

``` twig

    {% raw %} {{ cycle(['odd', 'even'], loop.index) }} {% endraw %}
```

And there you go, thank you [twig](http://twig.sensio.org "twig") !
