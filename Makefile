# `Makefile' for `pstricks-add-doc.pdf', hv, 2008/11/06

.SUFFIXES : .tex .dvi .ps .pdf .eps

PACKAGE = pst-optexp

MAIN = $(PACKAGE)-doc

LATEX = latex

ARCHNAME = $(MAIN)-$(shell date +%y%m%d)

ARCHFILES = $(PACKAGE).sty $(PACKAGE).tex $(PACKAGE).pro $(MAIN).tex README Changes Makefile

TDS = ~/PSTricks/PSTricks-TDS

all : doc clean tds
doc: $(MAIN).pdf

$(MAIN).pdf : $(MAIN).ps
	GS_OPTIONS=-dAutoRotatePages=/None ps2pdf $<

$(MAIN).ps : $(MAIN).dvi
	dvips $<

$(MAIN).dvi : $(MAIN).tex
	$(LATEX) $<
	$(LATEX) $<
	if ! test -f $(basename $<).glo ; then touch $(basename $<).glo; fi
	if ! test -f $(basename $<).idx ; then touch $(basename $<).idx; fi
	makeindex -s gglo.ist -t $(basename $<).glg -o $(basename $<).gls \
	  $(basename $<).glo
#	makeindex -t $(basename $<).ilg -s pst-doc.ist -o $(basename $<).ind \
#	  $(basename $<).idx
	makeindex -t $(basename $<).ilg -o $(basename $<).ind $(basename $<).idx
	$(LATEX) $<
	$(LATEX) $<

clean : 
	$(RM) *.data
	$(RM) $(addprefix $(MAIN), .log .aux .bbl .blg .glg .glo .gls .ilg .idx .ind .tmp .toc .out .xcp)
	$(RM) $(addprefix $(MAIN), .dvi .ps .data)

veryclean : clean
	$(RM) $(addprefix $(MAIN), .pdf )

arch :
	zip $(ARCHNAME).zip $(ARCHFILES)

tds:
	cp -u Changes     $(TDS)/doc/generic/$(PACKAGE)/
	cp -u README      $(TDS)/doc/generic/$(PACKAGE)/
	cp -u $(MAIN).pdf $(TDS)/doc/generic/$(PACKAGE)/
#
	cp -u Changes        $(TDS)/tex/latex/$(PACKAGE)/
	cp -u $(PACKAGE).sty $(TDS)/tex/latex/$(PACKAGE)/
#
	cp -u Changes        $(TDS)/tex/generic/$(PACKAGE)/
	cp -u $(PACKAGE).tex $(TDS)/tex/generic/$(PACKAGE)/
	cp -u pst-fp.tex $(TDS)/tex/generic/$(PACKAGE)/
#
	cp -u Changes        $(TDS)/dvips/$(PACKAGE)/
	cp -u $(PACKAGE).pro $(TDS)/dvips/$(PACKAGE)/
#
	cp -u Changes     $(TDS)/source/$(PACKAGE)/
	cp -u $(MAIN).tex $(TDS)/source/$(PACKAGE)/
	cp -u $(MAIN).bib $(TDS)/source/$(PACKAGE)/
	cp -u Makefile    $(TDS)/source/$(PACKAGE)/

# EOF
