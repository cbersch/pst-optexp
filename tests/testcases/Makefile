ifeq ($(DEBUG),)
LATEX = latex -interaction=nonstopmode 2>&1 >/dev/null
DVIPS = dvips -q 2>&1 >/dev/null
PS2PDF = ps2pdf -dALLOWPSTRANSPARENCY 2>&1 >/dev/null
else
LATEX = latex -interaction=nonstopmode 
DVIPS = dvips
PS2PDF = ps2pdf -dALLOWPSTRANSPARENCY
endif

export TEXINPUTS := ../..:
export DVIPSHEADERS := ../..:

HEADER=header
OBJECTS=$(filter-out $(HEADER).tex, $(shell ls *.tex))
FILELIST=$(basename $(OBJECTS))
GENTEX=connectall doc-examples testcases
FILELIST_ALL=$(FILELIST) $(GENTEX)
POE=../../pst-optexp.sty ../../pst-optexp.pro

.PHONY: all veryclean

all: $(addsuffix .pdf, $(FILELIST) $(GENTEX))

connectall.tex: connectall.py $(POE)
	./connectall.py

doc-examples.tex: ../../pst-optexp.dtx doc-examples.py $(POE)
	./doc-examples.py

testcases.tex: $(addsuffix .tex, $(filter-out $(GENTEX) $(HEADER), $(FILELIST)))
	$(RM) -f $@
	@{ $(foreach file, $(basename $^), \
		echo "\\\\bgroup\section{$(file)}\\\\input{$(file)}\\\\egroup\\\\newpage";) } >> $@

%.pdf: %.ps
	$(PS2PDF) $<

%.ps: %.dvi
	$(DVIPS) $<

%.dvi: %.tex $(POE)
	$(LATEX) -jobname=$* '\input{$(HEADER)}\input{$<}\end{document}'
#	rm -f $*.aux $*.log $*.tmp $*.out

veryclean: 
	$(RM) $(addsuffix .pdf, $(FILELIST) $(GENTEX)) \
	      $(addsuffix .ps, $(FILELIST) $(GENTEX)) \
	      $(addsuffix .tmp, $(FILELIST) $(GENTEX)) \
	      $(addsuffix .tex, $(GENTEX))
