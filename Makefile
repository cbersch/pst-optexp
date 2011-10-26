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

all : doc doc-DE

doc : $(PACKAGE).pdf

doc-DE : $(PACKAGE)-DE.pdf

dist : doc doc-DE
	tar chvzf $(ARCHNAME).tar.gz $(ARCHFILES)
	@ echo
	@ echo $(ARCHNAME).tar.gz

$(PACKAGE)-DE.dvi: $(PACKAGE).dtx $(PACKAGE).sty $(PACKAGE).ist $(PACKAGE).pro
	cp $< $(basename $@).dtx
	$(LATEX) '\newcommand*{\mainlang}{ngerman}\input{$(basename $@).dtx}'
	$(LATEX) '\newcommand*{\mainlang}{ngerman}\input{$(basename $@).dtx}'
	splitindex -m "" $(basename $@).idx
	touch $(basename $@)-idx.idx $(basename $@)-doc.idx
	makeindex -s gind.ist -t $(basename $@)-idx.ilg -o $(basename $@)-idx.ind \
		$(basename $@)-idx.idx
	makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg -o $(basename $@)-doc.ind \
		$(basename $@)-doc.idx
	$(LATEX) '\newcommand*{\mainlang}{ngerman}\input{$(basename $@).dtx}'
	splitindex -m "" $(basename $@).idx
	makeindex -s gind.ist -t $(basename $@)-idx.ilg -o $(basename $@)-idx.ind \
		$(basename $@)-idx.idx
	makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg -o $(basename $@)-doc.ind \
		$(basename $@)-doc.idx
	$(LATEX) '\newcommand*{\mainlang}{ngerman}\input{$(basename $@).dtx}'
	$(RM) $(basename $@).dtx

$(PACKAGE).dvi: $(PACKAGE).dtx $(PACKAGE).sty $(PACKAGE).ist $(PACKAGE).pro
	$(LATEX) '\newcommand*{\mainlang}{english}\input{$(basename $@).dtx}'
	$(LATEX) '\newcommand*{\mainlang}{english}\input{$(basename $@).dtx}'
	splitindex -m "" $(basename $@).idx
	touch $(basename $@)-idx.idx $(basename $@)-doc.idx
	makeindex -s gind.ist -t $(basename $@)-idx.ilg -o $(basename $@)-idx.ind \
		$(basename $@)-idx.idx
	makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg -o $(basename $@)-doc.ind \
		$(basename $@)-doc.idx
	$(LATEX) '\newcommand*{\mainlang}{english}\input{$(basename $@).dtx}'
	splitindex -m "" $(basename $@).idx
	makeindex -s gind.ist -t $(basename $@)-idx.ilg -o $(basename $@)-idx.ind \
		$(basename $@)-idx.idx
	makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg -o $(basename $@)-doc.ind \
		$(basename $@)-doc.idx
	$(LATEX) '\newcommand*{\mainlang}{english}\input{$(basename $@).dtx}'

%.ps: %.dvi
	dvips $< 
%.pdf: %.ps
	$(PS2PDF) $< $@

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
          README tds/doc/latex/pst-optexp/
	cp pst-optexp.dtx pst-optexp.ins \
	  tds/source/latex/pst-optexp/
	cd tds ; zip -r ../$(ARCHNAME_TDS).zip tex doc source
	rm -rf tds

ctan : dist arch-tds
	tar cf $(PACKAGE).tar $(ARCHNAME_TDS).zip $(ARCHNAME).tar.gz

clean :
	$(RM) $(addprefix $(PACKAGE), \
	      .dvi .ps .log .aux .bbl .blg .out .tmp .toc .idx .ind .ilg .gls .glg .glo -idx.idx -idx.ilg -idx.ind -doc.idx -doc.ilg -doc.ind .hd) \
		$(addprefix $(PACKAGE)-DE, \
	      .dvi .ps .log .aux .bbl .blg .out .tmp .toc .idx .ind .ilg .gls .glg .glo -idx.idx -idx.ilg -idx.ind -doc.idx -doc.ilg -doc.ind .hd)

veryclean : clean
	$(RM) $(PACKAGE).pdf $(PACKAGE)-DE.pdf $(PACKAGE).sty $(PACKAGE).pro $(PACKAGE).ist

# EOF
