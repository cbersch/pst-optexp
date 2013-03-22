ifeq ($(MASTERDIR),)
MASTERDIR=../../../master/tests
endif

ifeq ($(abspath $(MASTERDIR)),$(abspath ..))
$(error You are already in the master director, please set $$MASTERDIR properly)
endif

DIRS = testcases examples

ifeq ($(shell test -d $(MASTERDIR); echo $$?),1)
$(error Could not find master directory '$(MASTERDIR)')
else 
ifeq ($(shell test -d $(MASTERDIR)/testcases -a -d $(MASTERDIR)/examples; echo $$?),1)
$(error Master directory '$(MASTERDIR)' does not have the correct structure)
endif
endif

ifeq ($(shell test -d $(MASTERDIR); echo $$?),1)
$(error Could not find master directory '$(MASTERDIR)')
endif

CONVERT = convert -density 300 -alpha off
BLACKLIST = $(addprefix testcases/, header.tex doc-examples.tex testcases.tex)
FILELIST := $(filter-out $(BLACKLIST), \
	       $(subst ../,, \
	          $(foreach d, $(DIRS), $(wildcard ../$(d)/*.tex))))

FILELIST := $(foreach f, $(FILELIST), $(shell \
	if [ -e $(MASTERDIR)/$(f) -a -e ../$(f) ]; then \
	    echo $(f); fi))

FILELIST_NODIFF := $(foreach f, $(FILELIST), $(shell \
	if [ -e $(MASTERDIR)/$(f) -a -e ../$(f) ]; then \
	  diff -q $(MASTERDIR)/$(f) ../$(f) >/dev/null; \
	  if [ $$? -eq 0 ]; then \
	    echo $(f); \
	fi; fi))
FILELIST_DIFF := $(filter-out $(FILELIST_NODIFF), $(FILELIST))

BASENAMES_NODIFF := $(subst .tex,,$(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_NODIFF)))))
BASENAMES_DIFF := $(subst .tex,,$(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_DIFF)))))

FILELIST_PDF := $(subst .tex,.pdf, $(FILELIST))

DEV_TGT := $(addprefix dev/, $(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_PDF)))))
MASTER_TGT := $(addprefix master/, $(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_PDF)))))

PNG_TGT := $(subst .pdf,-01.png, $(DEV_TGT)) $(subst .pdf,-01.png, $(MASTER_TGT))

DIFF := $(subst dev/,diff/, $(subst .pdf,-01.png, $(DEV_TGT)))

.PHONY: all dev-dir master-dir diff-dir clean veryclean check-diff check-nodiff dev-src master-src

all: check-diff check-nodiff

master-src:
	make -C $(MASTERDIR)/.. pst-optexp.pro
	make -C $(MASTERDIR)/testcases
	make -C $(MASTERDIR)/examples

dev-src: 
	make -C ../.. pst-optexp.pro
	make -C ../testcases
	make -C ../examples

dev-dir master-dir diff-dir: %-dir:
	mkdir -p $*

.SECONDEXPANSION:

$(DEV_TGT): dev/%: $$(addprefix ../, $$(foreach d, $(DIRS), $$(findstring $$(d)/%, $(FILELIST_PDF)))) | dev-dir
	@cp -a $< $@

$(MASTER_TGT): master/%: $$(addprefix $(MASTERDIR)/, $$(foreach d, $(DIRS), $$(findstring $$(d)/%, $(FILELIST_PDF)))) | master-dir
	@cp -a $< $@

$(PNG_TGT): %-01.png: %.pdf
	@pdftk $< burst output $(subst .pdf,-%02d.pdf, $<)
	@for f in $*-*.pdf; do $(CONVERT) $$f $${f%*.pdf}.png 2>/dev/null; done

$(DIFF): diff/%-01.png: dev/%-01.png master/%-01.png | diff-dir
	@for f in dev/$*-*.png; do f=$${f#*/}; \
	  if [ ! -e master/$$f ]; then continue; fi; \
	  composite master/$$f dev/$$f -compose MinusSrc diffsrc.png && \
	  composite master/$$f dev/$$f -compose MinusDst diffdst.png && \
	  composite diffsrc.png diffdst.png -compose Add diff/$$f; \
	  echo $$f' done'; \
	done; \
	rm -f diffsrc.png diffdst.png

check-nodiff check-diff: master-src dev-src

GREPDIFF=egrep -zq "Histogram:[[:space:]]*[[:digit:]]*: \(  0,  0,  0\) \#000000 gray\(0,0,0\)[[:space:]]*Colormap:"
check-nodiff: $(DIFF)
	@for f in $(addprefix diff/, $(addsuffix *.png, $(BASENAMES_NODIFF))); \
	  do srcstring=' (source  \033[22;32munchanged\033[0m)';\
	  identify -verbose $$f | $(GREPDIFF); \
	  if [ $$? -eq 1 ]; \
	    then echo $$f' \033[22;31mchanged\033[0m'$$srcstring; \
	    else echo $$f' \033[22;32mok\033[0m'; fi; \
	done

check-diff: $(DIFF)
	@for f in $(addprefix diff/, $(addsuffix *.png, $(BASENAMES_DIFF))); \
	  do srcstring=' (source \033[22;31mchanged\033[0m)'; \
	  identify -verbose $$f | $(GREPDIFF); \
	  if [ $$? -eq 1 ]; \
	    then echo $$f' \033[22;31mchanged\033[0m'$$srcstring; \
	    else echo $$f' \033[22;32mok\033[0m'; fi; \
	done
clean:
	$(RM) dev/*.pdf master/*.pdf

veryclean:
	$(RM) -r dev master diff