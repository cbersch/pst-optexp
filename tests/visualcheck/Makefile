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

FILELIST := $(filter-out testcases/header.tex, \
	       $(subst ../,, \
	          $(foreach d, $(DIRS), $(wildcard ../$(d)/*.tex))))

FILELIST := $(foreach f, $(FILELIST), $(shell \
	if [ -e $(MASTERDIR)/$(f) ]; then \
	  diff -q $(MASTERDIR)/$(f) ../$(f) >/dev/null; \
	  if [ $$? -eq 0 ]; then \
	    echo $(f); \
	  fi; fi))

FILELIST_PDF := $(subst .tex,.pdf, $(FILELIST))

DEV_SRC := $(addprefix ../, $(FILELIST_PDF))
MASTER_SRC := $(addprefix $(MASTERDIR)/, $(FILELIST_PDF))

DEV_TGT := $(addprefix dev/, $(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_PDF)))))
MASTER_TGT := $(addprefix master/, $(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_PDF)))))

PNG_TGT := $(subst .pdf,-01.png, $(DEV_TGT)) $(subst .pdf,-01.png, $(MASTER_TGT))

DIFF := $(subst dev/,diff/, $(subst .pdf,-01.png, $(DEV_TGT)))

.PHONY: all dev-dir master-dir diff-dir

all: $(DIFF)

$(MASTER_SRC):
	make -C $(MASTERDIR)/.. pst-optexp.pro
	make -C $(MASTERDIR)/testcases
	make -C $(MASTERDIR)/examples

$(DEV_SRC): 
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

$(DIFF): diff/%: dev/% master/% | diff-dir
	@composite master/$* dev/$* -compose MinusSrc diffsrc.png && \
	composite master/$* dev/$* -compose MinusDst diffdst.png && \
	composite diffsrc.png diffdst.png -compose Add diff/$* && \
	identify -verbose $@ | \
	egrep -zq "Histogram:[[:space:]]*[[:digit:]]*: \(  0,  0,  0\) #000000 gray\(0,0,0\)[[:space:]]*Colormap:"; \
	  if [ $$? -eq 1 ]; then echo $*' \033[22;31mchanged\033[0m'; else echo $*' \033[22;32mok\033[0m'; fi && rm -f diffsrc.png diffdst.png
