export TEXINPUTS := ../..:
export DVIPSHEADERS := ../..:

LATEX = latex -interaction=nonstopmode
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
	@{ $(foreach file, $(basename $^), \
		echo "\\\\bgroup\section{$(file)}\\\\input{$(file)}\\\\egroup\\\\newpage";) } >> $@

%.pdf: %.ps
	ps2pdf $<

%.ps: %.dvi
	dvips -q $< 2>&1 >/dev/null

%.dvi: %.tex $(POE)
	$(LATEX) -jobname=$* '\input{$(HEADER)}\input{$<}\end{document}' #2>&1 >/dev/null 
#	rm -f $*.aux $*.log $*.tmp $*.out

veryclean: 
	$(RM) $(addsuffix .pdf, $(FILELIST) $(GENTEX)) \
	      $(addsuffix .ps, $(FILELIST) $(GENTEX)) \
	      $(addsuffix .tmp, $(FILELIST) $(GENTEX)) \
	      $(addsuffix .tex, $(GENTEX))
