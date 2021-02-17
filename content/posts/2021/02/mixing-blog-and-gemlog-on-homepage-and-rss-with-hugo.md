---
title: "Mixing blog and gemlog content on my blog homepage and RSS feed"
date: 2021-02-16T23:26:03+01:00
tags:
- gemini
- hugo
categories:
- selfhosting
---

## Context

After [launching my Gemini capsule a last week](https://bacardi55.io/2021/02/10/deploying-my-own-gemini-capsule-with-gmnisrv/) and [explaining how I manage both this blog and gemlog with Hugo](https://bacardi55.io/2021/02/13/managing-this-site-and-my-gemini-capsule-with-hugo/), I decided to also modify the homepage of this blog and the linked RSS feed.

What I wanted was simple:
- List on the homepage blog and gemlog posts in the same "feed"
- Prefix the gemlog post title with `{Gemini} - `
- Link Gemini posts to [a dedicated page](https://bacardi55.io/pages/gemini), using web anchor to go to the title directly (thanks [@alex](https://social.nah.re/@alex) for the great idea)
- Do the same on the RSS feed (links to the gemini web page, anchored at the gemlog post title).
- Description of the gemlog post in the RSS feed will display a generic message about gemini, not the gemlog content (otherwise, there is no point of not making them available on the website too.)

## Setup

### Setup the dedicated Gemini page

Let's start with creating a dedicated Gemini page. For that, I created the file `content/pages/gemini.md` with the following content:

```gotemplate
---
title: "My Gemlog page"
slug: "gemini"
layout: gemini
---
```

Basically to be able to customize the title and specify a specific layout to be able to use a dedicated template.

Then, let's create the template `layouts/_default/gemini.html`. The important part to manage the list of gemlog posts is:
```gotemplate
<h3>All my gemlog posts:</h3>
  <ul class="note list">
    {{ range where site.RegularPages "Section" "gemlog" }}
      {{- $url := replace .File.Path ".md" ".gmi" -}}
      <li class="item" id="{{- .File.UniqueID -}}">
        <a href="gemini://gmi.bacardi55.io/{{- $url | urlize -}}">
          {{- .Title -}}
        </a>
      </li>
    {{ end }}
  </ul>
```
As you can see, I'm simply using the file unique ID (managed by Hugo) as the anchor id.

Let's just add a link to this page in the navigation menu, so in the `config.toml` file, I added:

```toml
[[params.nav.custom]]
  title = "Gemini"
  url = "/pages/gemini"
  weight = 3
```

Now by generating the site with the `hugo` command, the gemini pages should be available via the menu.

You can see it in action [here](https://bacardi55.io/pages/gemini).

The full Gemini page template can be found [here](https://github.com/bacardi55/bacardi55io/blob/main/layouts/_default/gemini.html).
You can see the full configuration file [here](https://github.com/bacardi55/bacardi55io/blob/main/config.toml).

Ok, so the page is now there to be linked from the homepage and the RSS feed.

### The homepage

Hugo, by default, will list the "main section" content. In my case, it was only posts before. By editing the `config.toml`, I can tell hugo that the "main content" is composed of both gemlog and posts:

```toml
[params]
  mainSections = ["posts", "gemlog"]
```

The homepage should now list both type of content, but gemlog title are not modified and links point to the html version of the gemlog, so let's change that by editing the listing template. In the case of the theme I'm using and overriding, I needed to create a `layout/partials/note-list.html`.

The important part is there:
```html
{{- range $paginator.Pages -}}
  {{- $relURL := replace .RelPermalink "#" "%23" -}}
  {{- $relURL = replace $relURL "." "%2e" -}}
  <li class="item">
    {{ if eq .Type "gemlog" }}
      {{- $gurl := replace .File.Path ".md" ".gmi" -}}
    <a class="note" href="/pages/gemini#{{- .File.UniqueID -}}">
    {{ else }}
    <a class="note" href="{{- $relURL -}}">
    {{ end }}
    <p class="note title">
      {{ if eq .Type "gemlog" }}{Gemlog} - {{ end }}
      {{- .Title | safeHTML -}}
    </p>
    {{- if .Date -}}
      <p class="note date">{{- .Date.Format $dateFormat -}}</p>
    {{- end -}}
    </a>
  </li>
    {{- end -}}
```

Basically, when looping on all content, I check if the type of content (`.Type`) is `gemlog`, and if that's the case I put the URL to the gemini page `/pages/gemini` with the anchor to the right entry, using again the `.File.UniqueID` to get it. I also change the title by adding the suffix `{Gemlog} -` for gemlog posts.

I kept the same code as before in case of a blog post (using `.Permalink` rewritten and default title).

So now my homepage list both content, with special title and links for gemlog entries.

You can see the full configuration file [here](https://github.com/bacardi55/bacardi55io/blob/main/config.toml).
The full note-list template can be found [here](https://github.com/bacardi55/bacardi55io/blob/main/layouts/partials/note-list.html).

### The RSS feed

Last part was the RSS feed and it works the same way (except the template is a xml template and not html). So by copying and adapting the default RSS template of the theme I'm using like below, I managed to have the same behavior as the homepage.

The interesting part of the `layouts/partials/rss.xml` file is:
```xml
{{ range first 25 site.RegularPages }}
  <item>
    <title>{{ .Title }}</title>
      {{ if eq .Type "gemlog" }}
        <link>{{- .Site.BaseURL -}}/pages/gemini#{{- .File.UniqueID -}}</link>
        <description>This is a Gemini Log (gemlog) post only visible via the Gemini space. To learn more about what is Gemini and my gemini specific content, please <a href="{{- .Site.BaseURL -}}/pages/gemini">read here</a></description>
      {{ else }}
        <link>{{ .Permalink }}</link>
        <description>{{ .Content | html }}</description>
      {{ end }}
    <pubDate>{{ .Date.Format "Mon, 02 Jan 2006 15:04:05 -0700" | safeHTML }}</pubDate>
    {{ with .Site.Author.name }}
      <author>{{.}}</author>
    {{end}}
    <guid>{{ .Permalink }}</guid>
  </item>
{{ end }}
```
Same kind of things, if the type is "gemlog", then I put a special link with anchor to the gemini page and prefix the title.

The full RSS template can be found [here](https://github.com/bacardi55/bacardi55io/blob/main/layouts/_default/rss.xml).

## Conclusion

This is me going deeper in the world of having a "similar but different" online presence on the web and on the gemini space. Hopefully that will also help someone else :).

You can find all my gemini related blog post [here](https://bacardi55.io/tags/gemini/).
