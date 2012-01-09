#!/usr/bin/env python
import re

with open("../../pst-optexp.dtx") as f:
    data = ''.join(f.readlines())
    
pat = re.compile('(?P<comm>(?:%\s*)?)(\\\\begin{pspicture}[^\n]*\n)((?:(?P=comm)[^\n]*\n)*?)((?P=comm)\s*\\\\end{pspicture})', re.S)
g = pat.findall(data)

f = open("doc-examples.tex", "w")
f.write(r"""\documentclass[a4paper]{scrreprt}
\usepackage[utf8]{inputenc} 
\usepackage[T1]{fontenc}
\usepackage{lmodern} 
\usepackage{amsfonts, amsmath, marvosym} 
\usepackage{bera}
\usepackage[dvipsnames,x11names,svgnames]{xcolor}
\usepackage{nicefrac}
\usepackage{calc, ragged2e}
\usepackage{pst-optexp}
\usepackage{pst-tree, pst-func, pst-circ}
\newcommand{\poeTR}[1]{\TR{\ttfamily#1}}
\definecolor{spot}{rgb}{1,.4,.2}%
\newpsstyle{Refline}{linecolor=gray!60}
\newif\ifGERMAN\GERMANfalse
\newif\ifENGLISH\ENGLISHtrue
\begin{document}
""")

for m in g:
    if re.match(m[0] + r"\\end{pspicture}", m[3]) and m[2].find('#') == -1:
        main = (m[2] + m[3]).replace(m[0], '')
        main = re.sub(r"\*\\label{[^}]*}\*", "", main)
        f.write(m[1] + main + "\n\n")

f.write(r"\end{document}")
f.close()
