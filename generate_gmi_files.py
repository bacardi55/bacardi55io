#!/usr/bin/python3

from md2gemini import md2gemini
import os
from pathlib import Path

result = list(
    Path("/home/bacardi55/workspace/perso/bacardi55iov2/public/_gemini_/").rglob("*.[mM][dD]"))

print("%d files to be converted…" % len(result))

print("Starting convertion")
for path in result:
    print("Loading file: %s " % path)
    with open(path, "r") as f:
        gemini = md2gemini(
            f.read(),
            links="paragraph",
            frontmatter=True,
            base_url="gmi.bacardi55.io/posts",
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


