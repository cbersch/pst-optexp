#!/usr/bin/env python
# -*- coding: utf-8 -*-

from types import TupleType

dipoles=(("lens", "lens=1 1"),
         ("lens", "lens=-1.5 -1.5"),
         ("lens", "lens=-2 1"),
         ("lens", "lens=1 -2 "),
         ("lens", "lens=1 0"),
         ("lens", "lens=-1 0"),
         ("lens", "lens=0 1"),
         ("lens", "lens=0 -1"),
         "pinhole",
         "crystal",
         "optbox",
         "optplate",
         "optretplate",
#         ("optdetector", "dettype=round"),
#         ("optdetector", "dettype=diode"),
         "optdiode",
         ("doveprism", "doveprismsize=1"))

tripoles=("mirror",
          ("mirror", "mirrorradius=2"),
          ("mirror", "mirrorradius=-2"),
          ("beamsplitter", "bsstyle=plate"),
          "beamsplitter",
          "optgrid",
          "pentaprism",
          "rightangleprism",
          "optprism")

document=r"""\documentclass{scrartcl}
\usepackage[latin1]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[ngerman]{babel}
\usepackage{lmodern}
\usepackage{textcomp}
\usepackage{pst-optexp}
\title{Automatically generated testcases for all device macros provided by pst-optexp and connections of them}
\begin{document}
\maketitle
"""

def dipole_testcases(dipole, options, i):
    start = "\\section{%s with options %s}\n" % (dipole, options)
    device = r"\pnode(! 0 %f add 0.5 %f add){A}\pnode(! 4 %f add 0.5 %f add){B}\%s[%s, compname=D%dC%d](A)(B){}"
    beam = r"\drawbeam[addtoBeam={%s}]{(A)}{D%dC%d}{(B)}."

    testcase = "\\subsection{Drawing single beams}\n"
    testcase += r"\begin{pspicture}[showgrid=true](14,5)\newpsstyle{Beam}{beamInside=false}"
    testcase += device % (0, 0, 0, 0, dipole, options, i, 1)
    testcase += beam % ("startpos=0.1, linecolor=red, n=3", i, 1)
    testcase += beam % ("startpos=0, linecolor=black", i, 1)
    testcase += beam % ("startpos=-0.1, linecolor=green", i, 1)
    testcase += device % (0, 1.5, 0, 1.5, dipole, options, i, 2) 
    testcase += beam % ("startpos=0.1, startvec=1 -0.05, linecolor=red", i, 2)
    testcase += beam % ("startpos=0, startvec=1 -0.05, linecolor=black", i, 2)
    testcase += beam % ("startpos=-0.1, startvec=1 -0.05, linecolor=green", i, 2)
    testcase += device % (0, 3, 0, 3, dipole, options, i, 3)
    testcase += beam % ("startpos=0.1, startvec=1 0.05, linecolor=red", i, 3)
    testcase += beam % ("startpos=0, startvec=1 0.05, linecolor=black", i, 3)
    testcase += beam % ("startpos=-0.1, startvec=1 0.05, linecolor=green", i, 3)
    testcase += r"\end{pspicture}" + "\n\\vspace{1cm}\n\n"

    testcase += "\\subsection{Drawing extended beams}\n"
    testcase += r"\begin{pspicture}[showgrid=true](14,6)\newpsstyle{Beam}{beamExtended, fillstyle=solid, fillcolor=red, opacity=0.2}"
    testcase += (device % (0, 0, 0, 0, dipole, options, i, 4)) + (beam % ("beamwidth=0.1", i, 4))
    testcase += (device % (0, 1.5, 0, 1.5, dipole, options, i, 5)) + (beam % ("startvec=0.05, beamwidth=0.1", i, 5))
    testcase += (device % (0, 3, 0, 3, dipole, options, i, 6)) + (beam % ("startvec=-0.05, beamwidth=0.1", i, 6))
    testcase += (device % (0, 4.5, 0, 4.5, dipole, options, i, 7)) + (beam % ("beamwidth=0.1, beamdiv=5", i, 7))
    testcase += r"\end{pspicture}" + "\n\\vspace{1cm}\n\n"
    return start + testcase

i = 1
for d in dipoles:
    if isinstance(d, TupleType):
        opt = d[1]
        dipole = d[0]
    else:
        opt = ""
        dipole = d
    document += dipole_testcases(dipole, opt, i)
    i += 1

document += r"\end{document}"

f = open("connectall.tex", "w")
print >> f, document
f.close()
