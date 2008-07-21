#!/usr/bin/python

import re
def compare(x, y):
    a=x[0].lower()
    b=y[0].lower()
    if (a < b):
        return -1
    elif (a > b):
        return 1
    else:
        return 0

doc=file('pst-optexp-doc.tex').read()
pat=re.compile(r"\\paramitem\{(.*?)\}\{(.*?)\}\{(.*?)\}\n")

match=pat.findall(doc)
match.sort(cmp=lambda x,y: cmp(x[0].lower(), y[0].lower()))

for o in match:
    print o[0] + " & " + o[1] + " & " + o[2] + r"\\"

