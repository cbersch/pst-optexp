.SUFFIXES : .tex .ltx .dvi .ps .pdf .eps

PACKAGE = pst-optexp

LATEX = latex

ARCHNAME = $(PACKAGE)-$(shell date +"%y%m%d")
ARCHNAME_TDS = $(PACKAGE).tds

ARCHFILES = $(PACKAGE).dtx $(PACKAGE).ins Makefile \
            README Changes \
            $(PACKAGE).pdf $(PACKAGE)-DE.pdf

PS2PDF = GS_OPTIONS=-dPDFSETTINGS=/prepress ps2pdf

all : doc doc-DE quickref

doc : $(PACKAGE).pdf

doc-DE : $(PACKAGE)-DE.pdf

quickref: $(PACKAGE)-quickref.pdf

dist : doc doc-DE quickref
	tar chvzf $(ARCHNAME).tar.gz $(ARCHFILES)
	@ echo
	@ echo $(ARCHNAME).tar.gz

$(PACKAGE).dvi: L = english
$(PACKAGE)-DE.dvi: L = ngerman
%.dvi: $(PACKAGE).dtx $(PACKAGE).sty $(PACKAGE).ist $(PACKAGE).pro
	$(LATEX) -jobname=$(basename $@) '\newcommand*{\mainlang}{$(L)}\input{$(PACKAGE).dtx}'
	$(LATEX) -jobname=$(basename $@) '\newcommand*{\mainlang}{$(L)}\input{$(PACKAGE).dtx}'
	splitindex -m "" $(basename $@).idx
	if test -e $(basename $@)-idx.idx; then \
	  makeindex -s gind.ist -t $(basename $@)-idx.ilg \
	        -o $(basename $@)-idx.ind $(basename $@)-idx.idx; \
	fi
	if test -e $(basename $@)-doc.idx; then \
	  makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg \
	  	-o $(basename $@)-doc.ind $(basename $@)-doc.idx; \
	fi
	$(LATEX) -jobname=$(basename $@) '\newcommand*{\mainlang}{$(L)}\input{$(PACKAGE).dtx}'	
	splitindex -m "" $(basename $@).idx
	if test -e $(basename $@)-idx.idx; then \
	  makeindex -s gind.ist -t $(basename $@)-idx.ilg \
	        -o $(basename $@)-idx.ind $(basename $@)-idx.idx; \
	fi
	if test -e $(basename $@)-doc.idx; then \
	  makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg \
	  	-o $(basename $@)-doc.ind $(basename $@)-doc.idx; \
	fi
	$(LATEX) -jobname=$(basename $@) '\newcommand*{\mainlang}{$(L)}\input{$(PACKAGE).dtx}'

%.ps: %.dvi
	dvips $< 
%.pdf: %.ps
	$(PS2PDF) $< $@

$(PACKAGE)-quickref.tex: $(PACKAGE)-quickref.py
	python $<

$(PACKAGE)-quickref.pdf: $(PACKAGE)-quickref.tex
	pdflatex $<

$(PACKAGE).sty $(PACKAGE).pro $(PACKAGE).tex $(PACKAGE).ist: $(PACKAGE).ins $(PACKAGE).dtx
	tex $<

Changes: Changes.py $(PACKAGE).dtx
	python $<

arch : Changes
	zip $(ARCHNAME).zip $(ARCHFILES)

arch-tds : Changes
	$(RM) $(ARCHNAME_TDS).zip
	mkdir -p tds/tex/latex/pst-optexp
	mkdir -p tds/doc/latex/pst-optexp
	mkdir -p tds/source/latex/pst-optexp
	mkdir -p tds/dvips/pst-optexp
	cp pst-optexp.sty tds/tex/latex/pst-optexp/
	cp pst-optexp.pro tds/dvips/pst-optexp/
	cp Changes pst-optexp.pdf pst-optexp-DE.pdf \
          README pst-optexp.ist pst-optexp-quickref.pdf \
	  tds/doc/latex/pst-optexp/
	cp pst-optexp.dtx pst-optexp.ins Makefile pst-optexp-quickref.py \
	  tds/source/latex/pst-optexp/
	cd tds ; zip -r ../$(ARCHNAME_TDS).zip tex doc source dvips
	cd ..
	rm -rf tds

ctan : dist arch-tds
	tar cf $(PACKAGE).tar $(ARCHNAME_TDS).zip $(ARCHNAME).tar.gz

clean :
	$(RM) $(foreach prefix, $(PACKAGE) $(PACKAGE)-DE $(PACKAGE)-quickref, \
	        $(addprefix $(prefix), .dvi .ps .log .aux .bbl .blg .out .tmp .toc \
	           .idx .ind .ilg .gls .glg .glo .hd \
	           -idx.idx -idx.ilg -idx.ind -doc.idx -doc.ilg -doc.ind .hd)) \
	      $(PACKAGE)-quickref.tex

veryclean : clean
	$(RM) $(addprefix $(PACKAGE), .pdf -DE.pdf -quickref.pdf .sty .pro .ist)
