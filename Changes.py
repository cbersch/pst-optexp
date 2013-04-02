#!/usr/bin/env python
import re, textwrap

with open("pst-optexp.dtx") as f:
    data = ''.join(f.readlines())

pat = re.compile(r'\\begin{release}{(.*?)}{(.*?)}(.*?)\\end{release}', re.DOTALL)

g = pat.findall(data)

pat = re.compile(r'^%\s*(.*?)\s*(?:%\s*)?$', re.MULTILINE)

with open("Changes", "w") as f:
    for release in g:
        f.write("%-5s%s\n" % (release[0], release[1]))

        txt = re.sub(r'\\opt{([^}]*)}', '\\1', release[2])
        txt = re.sub(r'(\\)cs{([^}]*)}', '\\1\\2', txt)
        txt = re.sub(r'\\see{[^}]*}', '.', txt)
        txt_split = ' '.join(pat.findall(txt)).split('\\item')
        for m in txt_split:
            if m:
                f.write("       *" + "\n           ".join(textwrap.wrap(m, 65)) + "\n")

        f.write("\n")
