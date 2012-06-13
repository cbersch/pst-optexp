# Makefile for pst-optexp -- Christoph Bersch, 2011-10-11, usenet@bersch.net

.SUFFIXES : .tex .ltx .dvi .ps .pdf .eps

PACKAGE = pst-optexp

LATEX = latex

ARCHNAME = $(PACKAGE)-$(shell date +"%y%m%d")
ARCHNAME_TDS = $(PACKAGE).tds

ARCHFILES = $(PACKAGE).dtx $(PACKAGE).ins Makefile \
            README Changes \
            $(PACKAGE).pdf $(PACKAGE)-DE.pdf

PS2PDF = GS_OPTIONS=-dPDFSETTINGS=/prepress ps2pdf

all : doc doc-DE cheatsheet

doc : $(PACKAGE).pdf

doc-DE : $(PACKAGE)-DE.pdf

cheatsheet: $(PACKAGE)-cheatsheet.pdf

dist : doc doc-DE cheatsheet
	tar chvzf $(ARCHNAME).tar.gz $(ARCHFILES)
	@ echo
	@ echo $(ARCHNAME).tar.gz

$(PACKAGE)-DE.dtx: $(PACKAGE).dtx
	cp $< $(basename $@).dtx

$(PACKAGE).dvi: L = english
$(PACKAGE)-DE.dvi: L = ngerman
%.dvi: %.dtx $(PACKAGE).sty $(PACKAGE).ist $(PACKAGE).pro
	$(LATEX) '\newcommand*{\mainlang}{$(L)}\input{$(basename $@).dtx}'
	$(LATEX) '\newcommand*{\mainlang}{$(L)}\input{$(basename $@).dtx}'
	splitindex -m "" $(basename $@).idx
	if test -e $(basename $@)-idx.idx; then \
	  makeindex -s gind.ist -t $(basename $@)-idx.ilg \
	        -o $(basename $@)-idx.ind $(basename $@)-idx.idx; \
	fi
	if test -e $(basename $@)-doc.idx; then \
	  makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg \
	  	-o $(basename $@)-doc.ind $(basename $@)-doc.idx; \
	fi
	$(LATEX) '\newcommand*{\mainlang}{$(L)}\input{$(basename $@).dtx}'
	splitindex -m "" $(basename $@).idx
	if test -e $(basename $@)-idx.idx; then \
	  makeindex -s gind.ist -t $(basename $@)-idx.ilg \
	        -o $(basename $@)-idx.ind $(basename $@)-idx.idx; \
	fi
	if test -e $(basename $@)-doc.idx; then \
	  makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg \
	  	-o $(basename $@)-doc.ind $(basename $@)-doc.idx; \
	fi
	$(LATEX) '\newcommand*{\mainlang}{$(L)}\input{$(basename $@).dtx}'

%.ps: %.dvi
	dvips $< 
%.pdf: %.ps
	$(PS2PDF) $< $@

$(PACKAGE)-cheatsheet.tex: $(PACKAGE)-cheatsheet.py
	python $<

$(PACKAGE)-cheatsheet.pdf: $(PACKAGE)-cheatsheet.tex
	pdflatex $<

$(PACKAGE).sty $(PACKAGE).pro $(PACKAGE).tex $(PACKAGE).ist: $(PACKAGE).ins $(PACKAGE).dtx
	tex $<

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
          README pst-optexp.ist pst-optexp-cheatsheet.pdf \
	  tds/doc/latex/pst-optexp/
	cp pst-optexp.dtx pst-optexp.ins Makefile pst-optexp-cheatsheet.py \
	  tds/source/latex/pst-optexp/
	cd tds ; zip -r ../$(ARCHNAME_TDS).zip tex doc source dvips
	cd ..
	rm -rf tds

ctan : dist arch-tds
	tar cf $(PACKAGE).tar $(ARCHNAME_TDS).zip $(ARCHNAME).tar.gz

clean :
	$(RM) $(addprefix $(PACKAGE), \
	      .dvi .ps .log .aux .bbl .blg .out .tmp .toc .idx .ind .ilg .gls .glg .glo -idx.idx -idx.ilg -idx.ind -doc.idx -doc.ilg -doc.ind .hd) \
		$(addprefix $(PACKAGE)-DE, \
	      .dvi .ps .log .aux .bbl .blg .out .tmp .toc .idx .ind .ilg .gls .glg .glo -idx.idx -idx.ilg -idx.ind -doc.idx -doc.ilg -doc.ind .hd) \
		$(addprefix $(PACKAGE)-cheatsheet, \
		  .tex .out .log .aux)

veryclean : clean
	$(RM) $(PACKAGE).pdf $(PACKAGE)-DE.pdf $(PACKAGE)-cheatsheet.pdf $(PACKAGE).sty $(PACKAGE).pro $(PACKAGE).ist

# EOF
