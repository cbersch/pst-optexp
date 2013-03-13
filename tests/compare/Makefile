ifeq ($(MASTERDIR),)
MASTERDIR=../../../master
endif

CONVERT = convert -density 300 -alpha off

.PHONY: all master-files dev-files compare copy convert

all: compare

master-files:
	make -C $(MASTERDIR) pst-optexp.pro
	make -C $(MASTERDIR)/tests/testcases
	make -C $(MASTERDIR)/tests/examples

dev-files: 
	make -C ../.. pst-optexp.pro
	make -C ../testcases
	make -C ../examples

# Copy only the pdfs which source files do not differ between current and master branch
copy: master-files dev-files
	mkdir -p master
	mkdir -p dev
	@for t in $(filter-out tests/testcases/header.tex, \
	             $(subst $(MASTERDIR)/,, \
	                $(wildcard $(MASTERDIR)/tests/testcases/*.tex))); do \
	  diff -q $(MASTERDIR)/$$t ../../$$t >/dev/null; \
	  if [ $$? -eq 0 ]; then \
	    cp $(MASTERDIR)/$${t%*.tex}.pdf master/; \
	    cp ../../$${t%.tex}.pdf dev/; \
	  else echo "Skipping differing file $$t"; fi; done

convert: copy
	@for d in dev master; do \
	   cd $$d; \
	   for t in *[a-zA-Z].pdf; do \
	     pdftk $$t burst output $${t%.pdf}-%02d.pdf; done; \
	   for t in *[0-9][0-9].pdf; do \
	     echo -n "."; \
	     $(CONVERT) $$t $${t%*.pdf}.png 2> /dev/null; done; echo ; cd ..; done

compare: convert
	mkdir -p diff
	@for t in dev/*[0-9][0-9].png; do \
	  composite master/$${t#*/} $$t -compose MinusSrc diffsrc.png; \
	  composite master/$${t#*/} $$t -compose MinusDst diffdst.png; \
	  composite diffsrc.png diffdst.png -compose Add diff/$${t#*/}; \
	  identify -verbose diff/$${t#*/} | \
	  egrep -zq "Histogram:[[:space:]]*[[:digit:]]*: \(  0,  0,  0\) #000000 gray\(0,0,0\)[[:space:]]*Colormap:"; \
	  if [ $$? -eq 1 ]; then n=1; echo "\nFile $${t#*/} has changed"; else echo -n "."; fi; done; \
	  if [ -z "$$n" ]; then echo "All files unchanged"; fi; rm diffsrc.png diffdst.png
