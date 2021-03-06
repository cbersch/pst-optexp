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

document=r"""\section{Automatically generated testcases for all device macros provided by pst-optexp and connections of them}
"""

def dipole_testcases(dipole, options, i):
    start = "\\subsection{%s with options %s}\n" % (dipole, options)
    device = "\\pnode(! 0 %f add 0.5 %f add){A}\n\\pnode(! 4 %f add 0.5 %f add){B}\n\\%s[%s, compname=D%dC%d](A)(B)\n"
    beam = "\\drawbeam[%s]{(A)}{D%dC%d}{(B)}\n"
    widebeam = "\\drawwidebeam[%s]{(A)}{D%dC%d}{(B)}\n"

    testcase = "\\subsubsection{Drawing single beams}\n"
    testcase += "\\begin{pspicture}[showgrid=true](14,5)\\newpsstyle{Beam}{beaminside=false}\n"
    testcase += device % (0, 0, 0, 0, dipole, options, i, 1)
    testcase += beam % ("beampos=0.1, linecolor=red", i, 1)
    testcase += beam % ("beampos=0, linecolor=black", i, 1)
    testcase += beam % ("beampos=-0.1, linecolor=green", i, 1)
    testcase += device % (0, 1.5, 0, 1.5, dipole, options, i, 2) 
    testcase += beam % ("beampos=0.1, beamangle=-3, linecolor=red", i, 2)
    testcase += beam % ("beampos=0, beamangle=-3, linecolor=black", i, 2)
    testcase += beam % ("beampos=-0.1, beamangle=-3, linecolor=green", i, 2)
    testcase += device % (0, 3, 0, 3, dipole, options, i, 3)
    testcase += beam % ("beampos=0.1, beamangle=3, linecolor=red", i, 3)
    testcase += beam % ("beampos=0, beamangle=3, linecolor=black", i, 3)
    testcase += beam % ("beampos=-0.1, beamangle=3, linecolor=green", i, 3)
    testcase += r"\end{pspicture}" + "\n\\vspace{1cm}\n\n"

    testcase += "\\subsubsection{Drawing wide beams}\n"
    testcase += r"\begin{pspicture}[showgrid=true](14,6)\newpsstyle{Beam}{fillstyle=solid, fillcolor=red, opacity=0.2}"
    testcase += (device % (0, 0, 0, 0, dipole, options, i, 4)) + (widebeam % ("beamwidth=0.1", i, 4))
    testcase += (device % (0, 1.5, 0, 1.5, dipole, options, i, 5)) + (widebeam % ("beamangle=3, beamwidth=0.1", i, 5))
    testcase += (device % (0, 3, 0, 3, dipole, options, i, 6)) + (widebeam % ("beamangle=-3, beamwidth=0.1", i, 6))
    testcase += (device % (0, 4.5, 0, 4.5, dipole, options, i, 7)) + (widebeam % ("beamwidth=0.1, beamdiv=10", i, 7))
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

f = open("connectall.tex", "w")
print >> f, document
f.close()
