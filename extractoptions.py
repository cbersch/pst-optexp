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
pat=re.compile(r"\\paramitem\{([a-z].*?)\}\{(.*?)\}\{(.*?)\}\n")
pat2=re.compile(r"^\\item\[\\param\{(.*?)\}:\]\s*(.*?)\n", re.M)
match=pat.findall(doc)
match2=pat2.findall(doc)
for p in match2:
    match.append(p)

match.sort(cmp=lambda x,y: cmp(x[0].lower(), y[0].lower()))

for o in match:
    if len(o) == 3:
        print o[0] + " & " + o[1] + " & " + o[2] + r"\\"
    else:
        print o[0] + " & \multicolumn{2}{l}{" + o[1] + r"\\"


