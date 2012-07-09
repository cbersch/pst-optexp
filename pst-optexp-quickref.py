#!/usr/bin/env python
import re

with open("pst-optexp.dtx") as f:
    data = ''.join(f.readlines())
pat = re.compile((r'(\\[a-z]+item|\\[a-z]*desc)(?:\[[^\]]+\])?(\{[a-zA-Z0-9]+\}.*$)'
                  r'|(\\ifGERMAN\s*\\chapter)') , re.MULTILINE)

g = pat.findall(data)

f = open("pst-optexp-quickref.tex", "w")

f.write(r"""\documentclass[landscape]{scrartcl}
\usepackage[latin1]{inputenc} 
\usepackage[T1]{fontenc}
\usepackage{lmodern} 
\usepackage{amsmath, marvosym} 
\usepackage{bera}
\usepackage{xcolor}
\definecolor{DOrange}{rgb}{1,.4,.2}%
\usepackage{ltxdockit}
\usepackage{multicol}
\usepackage[margin=1cm]{geometry}
\newenvironment*{cmdlist}
  {\list{}{%
  \setlength{\parskip}{0pt}%
  \setlength{\topsep}{0pt}%
    \setlength{\partopsep}{0pt}%
    \setlength{\labelsep}{0pt}%
    \setlength{\labelwidth}{10pt}%
    \setlength{\leftmargin}{10pt}%
    \setlength{\parsep}{0pt}%
    \setlength{\itemsep}{0pt}}}
  {\endlist}
\renewenvironment*{optionlist}
  {\list{}{%
  \setlength{\parskip}{0pt}%
  \setlength{\topsep}{0pt}%
    \setlength{\partopsep}{0pt}%
    \setlength{\labelsep}{0pt}%
    \setlength{\labelwidth}{10pt}%
    \setlength{\leftmargin}{20pt}%
    \setlength{\parsep}{0pt}%
    \setlength{\itemsep}{0pt}}}
  {\endlist}
\def\styleitem#1{\item[#1]\prm{psstyle}\par}
\def\numitem#1{\item[#1]=\prm{num}\par}
\def\valitem#1#2{\item[#1]=\prm{#2}\par}
\def\intitem#1{\item[#1]=\prm{int}\par}
\def\psnumitem#1{\item[#1]=\prm{pscode}\par}
\def\optitem#1#2{\item[#1]=#2\par}
\makeatletter
\def\choitem#1#2{\item[#1]=\ltd@verblist{#2}}
\def\boolitem#1{\item[#1]=\ltd@verblist{true,false}}
\def\envitem#1{\item[{\textbackslash begin\{#1\}\ldots\textbackslash end\{#1\}}]}
\def\cmditem#1{%
  \item[\textcolor{DOrange}{\textbackslash#1}]%
  \begingroup
  \ltd@syntaxsetup
  \ltxsyntaxfont
  \let\@tempa\@empty
  \ltd@parseargs}
\makeatother
\newcommand{\dipoledesc}[1]{\cmditem{#1}[opt](in)(out){label}}
\newcommand{\tripoledesc}[1]{\cmditem{#1}[opt](in)(center)(out){label}}
\newcommand{\fiberdipoledesc}[1]{\cmditem{#1}[opt](in)(out){label}}
\begin{document}\ttfamily\small
\begin{multicols}{3}
\section*{Cheat sheet for pst-optexp (v3.0)}
""")

cmdenv=False
optenv=False

for m in g:
    if m[0].startswith(r'\psargitem') or m[0].startswith(r'\poeitem'):
        continue
    if re.match(r'\\(cmditem|[a-z]+desc)', m[0]):
        if optenv:
            f.write("\\end{optionlist}\n\\vspace{7pt}%\n\n")
            optenv = False
        if not cmdenv:
            f.write("\\begin{cmdlist}\n")
            cmdenv = True
    elif re.match(r'\\ifGERMAN', m[2]):
        if optenv:
            f.write("\\end{optionlist}\n\\vspace{7pt}%\n\n")
            optenv = False
        elif cmdenv:
            f.write("\\end{cmdlist}\n\\vspace{7pt}%\n\n")
            cmdenv = False
    else:
        if cmdenv:
            f.write("\\end{cmdlist}\n")
            cmdenv = False
        if not optenv:
            f.write("\\begin{optionlist}\n")
            optenv = True

    f.write(m[0] + m[1] + "\n")

if optenv:
    f.write("\\end{optionlist}")
elif cmdenv:
    f.write("\\end{cmdlist}")

f.write(r"""\end{multicols}
\end{document}""")
f.close()
