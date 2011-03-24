#!/usr/bin/env python
# -*- coding: utf-8 -*-

from types import TupleType

dipoles=(("lens", "lens=1 1"),
         ("lens", "lens=-1 -1"),
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
         "doveprism")

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

\begin{document}
"""

def dipole_testcases(dipole, options):
    start = r"\begin{pspicture}(10,5)\newpsstyle{Beam}{beamExtended, fillstyle=solid, fillcolor=red, opacity=0.2}"
    case_1 = r"\pnode(! 0 %d add 0.5 %d add){A}\pnode(! 4 %d add 0.5 %d add){B}\%s[%s, compname=Dipole](A)(B){}\drawbeam[addtoBeam={%s}]{(A)}{Dipole}{(B)}."

    testcase = case_1 % (0, 0, 0, 0, dipole, options, "beamwidth=0.1")
    testcase += case_1 % (0, 1.5, 0, 1.5, dipole, options, "startvec=1 -0.05, beamwidth=0.1")
    testcase += case_1 % (0, 3, 0, 3, dipole, options, "startvec=1 0.05, beamwidth=0.1")
    stop = r"\end{pspicture}" + "\n\n"
    
    return start + testcase + stop

for d in dipoles:
    if isinstance(d, TupleType):
        opt = d[1]
        dipole = d[0]
    else:
        opt = ""
        dipole = d

    document += dipole_testcases(dipole, opt)

document += r"\end{document}"

f = open("connectall.tex", "w")
print >> f, document
f.close()
