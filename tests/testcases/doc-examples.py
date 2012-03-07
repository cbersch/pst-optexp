#!/usr/bin/env python
import re

with open("../../pst-optexp.dtx") as f:
    data = ''.join(f.readlines())
    
pat = re.compile('(?P<comm>(?:%\s*)?)(?:\\*\\\\ON\\*)?(\\\\begin{pspicture}[^\n]*\n)((?:(?P=comm)[^\n]*\n)*?)((?P=comm)\s*\\\\end{pspicture})', re.S)
g = pat.findall(data)

f = open("doc-examples.tex", "w")

for m in g:
    if re.match(m[0] + r"\\end{pspicture}", m[3]) and m[2].find('#') == -1:
        main = (m[2] + m[3]).replace(m[0], '').replace('^^A', '%').replace('*\\ON*', '').replace('*\\OFF*', '')
        main = re.sub(r"\*\\label{[^}]*}\*", "", main)
        f.write(m[1] + main + "\n\n")

f.close()
