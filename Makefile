# Makefile -- Christoph Bersch, 2011-07-13, usenet@bersch.net

.SUFFIXES : .tex .ltx .dvi .ps .pdf .eps

PACKAGE = pst-optexp

LATEX = latex

ARCHNAME = $(PACKAGE)-$(shell date +"%y%m%d")
ARCHNAME_TDS = $(PACKAGE).tds

#ADDINPUTS = penguin.eps elephant.ps knuth.png psf-demo.eps \
  insect1.eps insect15.eps

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
	touch $(basename $@)-idx.idx
	makeindex -s gind.ist -t $(basename $@)-idx.ilg -o $(basename $@)-idx.ind \
		$(basename $@)-idx.idx
	makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg -o $(basename $@)-doc.ind \
		$(basename $@)-doc.idx
	$(LATEX) '\newcommand*{\mainlang}{ngerman}\input{$(basename $@).dtx}'
	splitindex -m "" $(basename $@).idx
	touch $(basename $@)-idx.idx
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
	touch $(basename $@)-idx.idx
	makeindex -s gind.ist -t $(basename $@)-idx.ilg -o $(basename $@)-idx.ind \
		$(basename $@)-idx.idx
	makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg -o $(basename $@)-doc.ind \
		$(basename $@)-doc.idx
	$(LATEX) '\newcommand*{\mainlang}{english}\input{$(basename $@).dtx}'
	splitindex -m "" $(basename $@).idx
	touch $(basename $@)-idx.idx
	makeindex -s gind.ist -t $(basename $@)-idx.ilg -o $(basename $@)-idx.ind \
		$(basename $@)-idx.idx
	makeindex -s pst-optexp.ist -t $(basename $@)-doc.ilg -o $(basename $@)-doc.ind \
		$(basename $@)-doc.idx
	$(LATEX) '\newcommand*{\mainlang}{english}\input{$(basename $@).dtx}'

%.ps: %.dvi
	dvips $< 
%.pdf: %.ps
	$(PS2PDF) $< $@

$(PACKAGE).sty $(PACKAGE).pro $(PACKAGE).tex: $(PACKAGE).ins $(PACKAGE).dtx
	tex $<

arch : Changes
	zip $(ARCHNAME).zip $(ARCHFILES)

arch-tds : Changes
	$(RM) $(ARCHNAME_TDS).zip
	mkdir -p tds/tex/latex/pst-pdf
	mkdir -p tds/doc/latex/pst-pdf
	mkdir -p tds/source/latex/pst-pdf
	mkdir -p tds/scripts/pst-pdf
	cp pst-pdf.sty tds/tex/latex/pst-pdf/
	cp CHANGES pst-pdf.pdf pst-pdf-DE.pdf \
          pst-pdf-example1.tex pst-pdf-example2.tex \
          pst-pdf-example1.pdf pst-pdf-example2.pdf \
          README tds/doc/latex/pst-pdf/
	cp CHANGES.tex elephant.ps insect1.eps insect15.eps \
          knuth.png penguin.eps psf-demo.eps pst-pdf.dtx \
          pst-pdf.ins tds/source/latex/pst-pdf
	cp ps4pdf ps4pdf.bat ps4pdf.bat.noMiKTeX \
          ps4pdf.bat.w95 tds/scripts/pst-pdf/
	cd tds ; zip -r ../$(ARCHNAME_TDS).zip tex doc source scripts
	rm -rf tds

ctan : dist arch-tds
	tar cf $(PACKAGE).tar $(ARCHNAME_TDS).zip $(ARCHNAME).tar.gz

clean :
	$(RM) $(addprefix $(PACKAGE), \
	      .dvi .log .aux .bbl .blg .out .tmp .toc .idx .ind .ilg .gls .glg .glo -idx.idx -idx.ilg -idx.ind -doc.idx -doc.ilg -doc.ind) \
		$(addprefix $(PACKAGE)-DE, \
	      .dvi .log .aux .bbl .blg .out .tmp .toc .idx .ind .ilg .gls .glg .glo -idx.idx -idx.ilg -idx.ind -doc.idx -doc.ilg -doc.ind)

veryclean : clean
	$(RM) $(PACKAGE).pdf $(PACKAGE)-DE.pdf $(PACKAGE).ps $(PACKAGE)-DE.ps  

# EOF
