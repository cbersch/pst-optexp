#!/usr/bin/env python
import re

with open("pst-optexp.dtx") as f:
    data = ''.join(f.readlines())
pat = re.compile(r'(\\[a-z]+item|\\[a-z]*desc)(?:\[[^\]]+\])?(\{[a-zA-Z0-9]+\}.*)$', re.M)

# pat = re.compile('(?P<comm>(?:%\s*)?)(?:\\*\\\\ON\\*)?(\\\\begin{pspicture}[^\n]*\n)((?:(?P=comm)[^\n]*\n)*?)((?P=comm)\s*\\\\end{pspicture})', re.S)
g = pat.findall(data)

f = open("pst-optexp-cheatsheet.tex", "w")

f.write(r"""\documentclass[landscape]{scrartcl}
\usepackage[latin1]{inputenc} 
\usepackage[T1]{fontenc}
\usepackage{lmodern} 
\usepackage{amsmath, marvosym} 
\usepackage{bera}
\usepackage{ltxdockit}
\usepackage{multicol}
\usepackage[margin=1cm]{geometry}
\newenvironment*{cheatlist}
  {\list{}{%
    \setlength{\partopsep}{0pt}%
    \setlength{\labelwidth}{10pt}%
    \setlength{\leftmargin}{10pt}%
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
  \item[\textbackslash#1]%
  \begingroup
  \ltd@syntaxsetup
  \ltxsyntaxfont
  \let\@tempa\@empty
  \ltd@parseargs}
\makeatother
\newcommand{\dipoledesc}[1]{\cmditem{#1}[options](in)(out){label}}
\newcommand{\tripoledesc}[1]{\cmditem{#1}[options](in)(center)(out){label}}
\newcommand{\fiberdipoledesc}[1]{\cmditem{#1}[options](in)(out){label}}
%\setlength{\parskip}{0pt}
%\setlength{\topsep}{0pt}
\begin{document}\ttfamily\small
\begin{multicols}{3}
\begin{cheatlist}
""")
envopen=''
for m in g:
    if m[0].startswith(r'\psargitem'):
        continue
    if m[0] == r'\cmditem':
        f.write(m[0] + m[1] + "\n")

f.write(r"""\end{cheatlist}
\end{multicols}
\end{document}""")
f.close()
