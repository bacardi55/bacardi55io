---
title: "Managing this site and my gemini capsule with Hugo"
date: 2021-02-13T19:16:03+01:00
tags:
- gemini
categories:
- selfhosting
draft: true
---

## Context

When I [started my gemini capsule](/2021/02/10/deploying-my-own-gemini-capsule-with-gmnisrv/), I quickly put a basic mirror of this blog on it as a temporary thing. I do have a goal to write specific content on my gemini capsule. If you want, you can read about the reasons why I write on gemini, I wrote an [article on my gemini gemlog about it (Gemini link)](gemini://gmi.bacardi55.io/gemlog/2021/02/my-first-gemini-post.gmi).

I worked on it in the past days to achieve something closer to my needs:
- Having a different weblog and gemlog "sites", meaning at least the homepage should be different. The homepage of the blog only list the blog posts. The homepage of my capsule should first list the latest gemlog posts with a link to all gemlog posts and then latest blog posts with link to full list pages.
- Create blog posts and gemlog posts dedicated list pages on the gemini capsule (not needed on the blog where only the posts are displayed)
- Blog posts must be readable easily via gemini, so cleaned from markdown formatting and displaying links according to gemini specifications, not markdown.
- 1 tool to manage both content types, I didn't want to use 2 different static site generator (or editing files manually)
- RSS feed for the blog posts on the weblog, RSS feed for the gemlog posts on the capsule (That part is not done yet).
- (Optional: List gemlog entries on the blog somewhere so at least title would be visible to web visitors)

Maybe everything I want to achieve is doable with hugo only, but I couldn't figure out…

## Generating the site and the capsule

### Configure Hugo

First, I created a gemlog content type in my hugo directory:
```bash
cd /path/to/hugo/directory/
mkdir content/gemlog/
```

Then, I created the first gemlog entry. I follow the following path:
```bash
content/gemlog/<year>/<month>/<filename>.md
```

Just by adding this, I notice that the RSS feed was displaying both posts and gemlog entries, so I copied the RSS template from the theme I’m using to change:
```
{{ range first 10 .Site.RegularPages }}
```
to:
```gotemplate
{{ range first 10 (where site.RegularPages "Section" "in" "posts") }}
```

So that part is already taken of.

Now, let’s configure hugo to generate gmi files.
I was inspired by the following blog posts (thanks!):
- [Drew Devault article on using Hugo and Gemini (only via gemini)](gemini://drewdevault.com/2020/09/27/Gemini-and-Hugo.gmi)
- [Sylvain Durand blog post on using hugo for gemini (WEB)](https://sylvaindurand.org/gemini-and-hugo/)
- [Stéphane HUC post on using hugo for gemini and gopher (WEB and French)](https://doc.huc.fr.eu.org/fr/web/hugo/hugo-gemini-gopher/)

But that didn’t work for me. The .gmi files generated for the posts were not great and links didn’t work.

But it worked great to manage the homepage and the section pages (that I do not use on the weblog version). To do so, I added this to the config.toml:

```toml
[mediaTypes]
  [mediaTypes."text/gemini"]
    suffixes = ["gmi"]

[outputFormats]
  [outputFormats.Gemini]
    name = "gemini"
    isPlainText = true
    isHTML = false
    mediaType = "text/gemini"
    protocol = "gemini://"
    permalinkable = true
    path = "/gemini/"

[outputs]
  home = ["HTML", "RSS", "gemini"]
  page = ["HTML"]
  section = ["gemini"]
```

This will allow generation of a new type of files (.gmi), but only for the homepage and the section pages (posts and gemlog).

I also added a new config parameter to indicate the geminiBaseUrl. That is because I made the choice (not sure why) to use a different subdomain for my capsule instead of the same. But that give me the possibility in the future to use different servers (at least not on the same network) without difficulties.

```toml
[params]
  geminiBaseUrl = "gemini://gmi.bacardi55.io"
```

### Creating the template files

Let’s start with the homepage template for the gemini version `layout/index.gmi`:

You can find the full code [here](), but the main parts are:

```gotemplate
{{ range first 5 (where site.RegularPages "Section" "in" "gemlog") }}
  {{- $dateFormat := site.Params.dateFormat -}}
  {{- $dateFormat := .Date.Format $dateFormat -}}
=> {{ $geminiBaseUrl }}/{{ replace .File.Path ".md" ".gmi" }} {{ .Title }} - {{ $dateFormat }}
{{ end }}

=> {{ $geminiBaseUrl }}/gemlog/index.gmi  All my Gemlog posts
```

And:
```markdown
{{ range first 5 (where site.RegularPages "Section" "in" "posts") }}
  {{- $dateFormat := site.Params.dateFormat -}}
  {{- $dateFormat := .Date.Format $dateFormat -}}
=> {{ $geminiBaseUrl }}/{{ replace .File.Path ".md" ".gmi" }} {{ .Title }} - {{ $dateFormat }}
{{ end }}

=> {{ $geminiBaseUrl }}/posts/index.gmi  All my Blog posts
```

These 2 blocks will list the last 5 gemlog entries (and a link to all gemlog entries) and then last 5 blog posts (and a link to all blog posts).

The replace are here to change the .md in the link to .gmi.

To be able to change the title of the section page (from `Posts` and `Gemlog`), I created the 2 section root files:

In `content/posts/_index.md`:
```yaml
---
title: Gemlog Posts
---
```

In `content/gemlog/_index.md`:
```yaml
---
title: "Blog Posts"
---
```

Then, creating the section template files (`layouts/_default/section.gmi`):

```gotemplate
# {{ .Title }}
{{ $geminiBaseUrl := site.Params.geminiBaseUrl }}

{{ range .Pages }}
  {{- $dateFormat := site.Params.dateFormat -}}
  {{- $dateFormat := .Date.Format $dateFormat -}}
=> {{ $geminiBaseUrl }}/{{ replace .File.Path ".md" ".gmi" }} {{ .Title }} - {{ $dateFormat }}
{{ end }}
```

Again, replacing the .md into .gmi in the filepath of each content.


### Generating the gemini sites.

#### Creating the structure
Because the way hugo is configure now, the generated files for the gemini sites are in different places. There are files to move around and some other to copy or removed. Let’s look at the part of my deployment shell script that reorganize everything:


```bash
# Move files around to dissociate web and gemini:
mkdir "$workdir/$public_dir/$gemini_output_dir"
mv "$workdir/$public_dir/gemini/index.gmi" "$workdir/$public_dir/$gemini_output_dir/"

cp -r "$workdir/content/posts/" "$workdir/$public_dir/$gemini_output_dir/"
cp -r "$workdir/content/gemlog/" "$workdir/$public_dir/$gemini_output_dir/"

mv "$workdir/$public_dir/posts/gemini/index.gmi" "$workdir/$public_dir/$gemini_output_dir/posts/"
mv "$workdir/$public_dir/gemlog/gemini/index.gmi" "$workdir/$public_dir/$gemini_output_dir/gemlog/"

rmdir "$workdir/$public_dir/gemini/"
rmdir "$workdir/$public_dir/posts/gemini"
# Section are only for gemini output, posts is now empty.
rmdir "$workdir/$public_dir/posts"
rmdir "$workdir/$public_dir/gemlog/gemini"
# Because I don't want the gemlog files to be available at all on the blog (https):
rm -rf "$workdir/$public_dir/gemlog"
rm "$workdir/$public_dir/$gemini_output_dir/posts/_index.md"
rm "$workdir/$public_dir/$gemini_output_dir/gemlog/_index.md"
```


Basically:
- Creating a new gemini output directory (let’s say `_gemini_`)
- Moving `public/gemini/index.gmi` to `public/_gemini_/`
- Copy all blog posts (still in markdown) into `public/_gemini_/posts`
- Copy all gemlog posts (still in markdown) into `public/_gemini_/gemlog`
- Remove useless files and empty directory.
- I also remove the `public/gemlog` directory so gemlog posts are not accessible from the web version even if you know the path.


To give you an idea, directory structure looks like this at this point of the script:

```bash
tree -L 2 public/_gemini_
public/_gemini_
├── gemlog
│   ├── 2021
│   └── index.gmi
├── index.gmi
└── posts
    ├── 2013
    ├── 2016
    ├── 2017
    ├── 2018
    ├── 2020
    ├── 2021
    └── index.gmi
```

The last issue is that at this point, except the homepage (`_gemini_/index.gmi`) and the 2 sections pages (`_gemini_/posts/index.gmi` and `_gemini_/gemlog/index.gmi`), all the other files are still in markdown…

This is where [this awesome python library](https://github.com/makeworld-the-better-one/md2gemini) comes to help as it can create gemini files based on markdown files (taken care of links and others).


My shell deployment script will now call a python script[^1] that will read all markdown file, create the gemini equivalent and remove the files.

The python script looks like this

```python
#!/usr/bin/python3

from md2gemini import md2gemini
import os
from pathlib import Path

result = list(
    Path("/path/to/hugo/project/public/_gemini_/").rglob("*.[mM][dD]"))

print("%d files to be converted…" % len(result))

print("Starting convertion")
for path in result:
    print("Loading file: %s " % path)
    with open(path, "r") as f:
        gemini = md2gemini(
            f.read(),
            links="paragraph",
            frontmatter=True,
            base_url="<geminidomain>/posts", # change to your needs.
            plain=True,
            md_links=True)
        #print(gemini)
        p = str(path).replace(path.suffix, '.gmi')
        print("Creating file: %s" % p)
        g = open(p, "a")
        g.write(gemini)
        g.close()

        print("Removing file: %s" % path)
        os.remove(path)
    print("--")
```

You will need the mentioned library before running this script, you can install it with:

```bash
pip3 install md2gemini
```

You can look at the [full shell script here]() and the full repo of [this blog here]().

Again, this will be improved into a single (python) script in the near future.

[^1]: I started with a shell script as at first it was only 2 lines (1 to generate content via `hugo` and a simple `rsync` command). Knowing what I know now, I would have just made 1 python script. I still plan to upgrade this into one clean python script at some point :).
