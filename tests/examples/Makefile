ifeq ($(DEBUG),)
LATEX = latex -interaction=nonstopmode 2>&1 >/dev/null
DVIPS = dvips -q 2>&1 >/dev/null
PS2PDF = ps2pdf -dALLOWPSTRANSPARENCY 2>&1 >/dev/null
else
LATEX = latex -interaction=nonstopmode 
DVIPS = dvips
PS2PDF = ps2pdf
endif

export TEXINPUTS := ../..:
export DVIPSHEADERS := ../..:

OBJECTS=$(shell ls *.tex)
FILELIST=$(basename $(OBJECTS))
POE=$(shell kpsewhich pst-optexp.tex pst-optexp.pro)

.PHONY: all clean veryclean

.SECONDARY: $(addsuffix .ps, $(FILELIST))

all: $(addsuffix .pdf, $(FILELIST))

connectall.tex: connectall.py $(POE)
	./connectall.py

%.pdf: %.ps
	$(PS2PDF) $<

%.ps: %.dvi
	$(DVIPS) $<

%.dvi: %.tex $(POE)
	$(LATEX) $<
	rm -f $*.aux $*.log

clean: clean
	$(RM) $(addsuffix .ps, $(FILELIST)) \
	      $(addsuffix .dvi, $(FILELIST)) \
	      $(addsuffix .pdf, $(FILELIST))

### Makefile ends here
