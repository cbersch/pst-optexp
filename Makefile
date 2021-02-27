.SUFFIXES : .tex .ltx .dvi .ps .pdf .eps

PACKAGE = pst-optexp

LATEX = latex

ARCHNAME = $(PACKAGE)-$(shell date +"%y%m%d")

ARCHFILES = Makefile README Changes \
	    $(addprefix $(PACKAGE), -quickref.pdf .dtx .ins .pdf -DE.pdf)

PS2PDF = GS_OPTIONS=-dPDFSETTINGS=/prepress ps2pdf

all : doc-all Changes

doc-all: doc doc-DE doc-code quickref 

doc: $(PACKAGE).pdf
doc-DE: $(PACKAGE)-DE.pdf
doc-code: $(PACKAGE)-code.pdf
quickref: $(PACKAGE)-quickref.pdf

dist: $(ARCHFILES)
	mkdir -p $(PACKAGE)
	cp $(ARCHFILES) $(PACKAGE)
	zip -r $(PACKAGE).zip $(PACKAGE)
	$(RM) -rf $(PACKAGE)/

$(PACKAGE).dvi: L = english
$(PACKAGE)-DE.dvi: L = ngerman
$(PACKAGE)-code.dvi: L = english
%.dvi: $(PACKAGE).dtx $(PACKAGE).sty $(PACKAGE).ist $(PACKAGE).pro

	if [ "$@" = "$(PACKAGE)-code.dvi" ]; then \
		sed 's/^\\OnlyDescription//' < $(PACKAGE).dtx > tmp.dtx; \
	else cp $(PACKAGE).dtx tmp.dtx; \
	fi

	$(LATEX) -jobname=$(basename $@) '\newcommand*{\mainlang}{$(L)}\input{tmp.dtx}'
	$(LATEX) -jobname=$(basename $@) '\newcommand*{\mainlang}{$(L)}\input{tmp.dtx}'
	splitindex -m "" $(basename $@).idx
	if test -e $(basename $@)-idx.idx; then \
	  makeindex -s gind.ist -t $(basename $@)-idx.ilg \
	        -o $(basename $@)-idx.ind $(basename $@)-idx.idx; \
	fi
	if test -e $(basename $@)-doc.idx; then \
	  makeindex -s $(PACKAGE).ist -t $(basename $@)-doc.ilg \
	  	-o $(basename $@)-doc.ind $(basename $@)-doc.idx; \
	fi
	$(LATEX) -jobname=$(basename $@) '\newcommand*{\mainlang}{$(L)}\input{tmp.dtx}'	
	splitindex -m "" $(basename $@).idx
	if test -e $(basename $@)-idx.idx; then \
	  makeindex -s gind.ist -t $(basename $@)-idx.ilg \
	        -o $(basename $@)-idx.ind $(basename $@)-idx.idx; \
	fi
	if test -e $(basename $@)-doc.idx; then \
	  makeindex -s $(PACKAGE).ist -t $(basename $@)-doc.ilg \
	  	-o $(basename $@)-doc.ind $(basename $@)-doc.idx; \
	fi
	$(LATEX) -jobname=$(basename $@) '\newcommand*{\mainlang}{$(L)}\input{tmp.dtx}'
	$(RM) -f tmp.dtx

%.ps: %.dvi
	dvips $< 
%.pdf: %.ps
	$(PS2PDF) -dALLOWPSTRANSPARENCY $< $@

$(PACKAGE)-quickref.tex: $(PACKAGE)-quickref.py $(PACKAGE).dtx
	python $<

$(PACKAGE)-quickref.pdf: $(PACKAGE)-quickref.tex
	pdflatex $<

$(PACKAGE).sty $(PACKAGE).pro $(PACKAGE).ist: $(PACKAGE).ins $(PACKAGE).dtx
	tex $<

Changes: Changes.py $(PACKAGE).dtx
	python $<

clean :
	$(RM) $(foreach prefix, $(PACKAGE) $(PACKAGE)-code $(PACKAGE)-DE $(PACKAGE)-quickref, \
	        $(addprefix $(prefix), .dvi .ps .log .aux .bbl .blg .out .tmp \
	           .toc .idx .ind .ilg .hd \
	           -idx.idx -idx.ilg -idx.ind -doc.idx -doc.ilg -doc.ind .hd)) \
	      $(PACKAGE)-quickref.tex

veryclean : clean
	$(RM) $(addprefix $(PACKAGE), .pdf -DE.pdf -code.pdf -quickref.pdf .sty .pro .ist) Changes
