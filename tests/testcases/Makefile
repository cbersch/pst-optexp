LATEX = latex -interaction=nonstopmode
OBJECTS=$(shell ls *.tex)
FILELIST=$(basename $(OBJECTS))
POE=$(shell kpsewhich pst-optexp.sty pst-optexp.pro)
GENTEX=connectall doc-examples testcases
TESTCASE_HEADER=header

.PHONY: all veryclean

.INTERMEDIATE: $(addsuffix .tex, $(GENTEX)) $(addsuffix .tmp, $(FILELIST))

all: $(addsuffix .pdf, $(FILELIST) $(GENTEX))

connectall.tex: connectall.py $(POE)
	./connectall.py

doc-examples.tex: ../../pst-optexp.dtx doc-examples.py $(POE)
	./doc-examples.py

testcases.tex: $(addsuffix .tex, $(filter-out $(GENTEX) $(TESTCASE_HEADER), $(FILELIST)))
	@{ $(foreach file, $(basename $^), 
		echo "\bgroup\section{$(file)}\input{$(file)}\egroup";) } > $@

%.pdf: %.ps
	ps2pdf $<

%.ps: %.dvi
	dvips -q $< 2>&1 >/dev/null

%.dvi: %.tex $(POE)
	$(LATEX) -jobname=$* '\input{header}\input{$<}\end{document}' 2>&1 >/dev/null 
	rm -f $*.aux $*.log

veryclean: 
	$(RM) $(addsuffix .pdf, $(FILELIST)) \
	      $(addsuffix .ps, $(FILELIST))
