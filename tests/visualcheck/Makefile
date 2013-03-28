ifeq ($(OLDDIR),)
OLDDIR=../../../old/tests
endif

ifeq ($(abspath $(OLDDIR)),$(abspath ..))
$(error You are already in the old director, please set $$OLDDIR properly)
endif

DIRS = testcases examples

ifeq ($(shell test -d $(OLDDIR); echo $$?),1)
$(error Could not find old directory '$(OLDDIR)')
else 
ifeq ($(shell test -d $(OLDDIR)/testcases -a -d $(OLDDIR)/examples; echo $$?),1)
$(error Old directory '$(OLDDIR)' does not have the correct structure)
endif
endif

ifeq ($(shell test -d $(OLDDIR); echo $$?),1)
$(error Could not find old directory '$(OLDDIR)')
endif

CONVERT = convert -density 300 -alpha off
BLACKLIST = $(addprefix testcases/, header.tex doc-examples.tex testcases.tex)
FILELIST := $(filter-out $(BLACKLIST), \
	       $(subst ../,, \
	          $(foreach d, $(DIRS), $(wildcard ../$(d)/*.tex))))

FILELIST := $(foreach f, $(FILELIST), $(shell \
	if [ -e $(OLDDIR)/$(f) -a -e ../$(f) ]; then \
	    echo $(f); fi))

FILELIST_NODIFF := $(foreach f, $(FILELIST), $(shell \
	if [ -e $(OLDDIR)/$(f) -a -e ../$(f) ]; then \
	  diff -q $(OLDDIR)/$(f) ../$(f) >/dev/null; \
	  if [ $$? -eq 0 ]; then \
	    echo $(f); \
	fi; fi))
FILELIST_DIFF := $(filter-out $(FILELIST_NODIFF), $(FILELIST))

BASENAMES_NODIFF := $(subst .tex,,$(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_NODIFF)))))
BASENAMES_DIFF := $(subst .tex,,$(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_DIFF)))))

FILELIST_PDF := $(subst .tex,.pdf, $(FILELIST))

CURRENT_TGT := $(addprefix current/, $(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_PDF)))))
OLD_TGT := $(addprefix old/, $(foreach d, $(DIRS), $(subst $(d)/,, $(filter $(d)/%, $(FILELIST_PDF)))))

PNG_TGT := $(subst .pdf,-01.png, $(CURRENT_TGT)) $(subst .pdf,-01.png, $(OLD_TGT))

DIFF := $(subst current/,diff/, $(subst .pdf,-01.png, $(CURRENT_TGT)))

.PHONY: all current-dir old-dir diff-dir clean veryclean check-diff check-nodiff current-src old-src

all: check-diff check-nodiff

old-src:
	make -C $(OLDDIR)/.. pst-optexp.pro
	make -C $(OLDDIR)/testcases
	make -C $(OLDDIR)/examples

current-src: 
	make -C ../.. pst-optexp.pro
	make -C ../testcases
	make -C ../examples

current-dir old-dir diff-dir: %-dir:
	mkdir -p $*

.SECONDEXPANSION:

$(CURRENT_TGT): current/%: $$(addprefix ../, $$(foreach d, $(DIRS), $$(findstring $$(d)/%, $(FILELIST_PDF)))) | current-dir
	cp -a $< $@

$(OLD_TGT): old/%: $$(addprefix $(OLDDIR)/, $$(foreach d, $(DIRS), $$(findstring $$(d)/%, $(FILELIST_PDF)))) | old-dir
	cp -a $< $@

$(PNG_TGT): %-01.png: %.pdf
	pdftk $< burst output $(subst .pdf,-%02d.pdf, $<)
	@for f in $*-*.pdf; do $(CONVERT) $$f $${f%*.pdf}.png 2>/dev/null; done

$(DIFF): diff/%-01.png: current/%-01.png old/%-01.png | diff-dir
	@for f in current/$*-*.png; do f=$${f#*/}; \
	  if [ ! -e old/$$f ]; then continue; fi; \
	  composite old/$$f current/$$f -compose MinusSrc diffsrc.png && \
	  composite old/$$f current/$$f -compose MinusDst diffdst.png && \
	  composite diffsrc.png diffdst.png -compose Add diff/$$f; \
	  echo $$f' done'; \
	done; \
	rm -f diffsrc.png diffdst.png

check-nodiff check-diff: old-src current-src

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
	$(RM) current/*.pdf old/*.pdf

veryclean:
	$(RM) -r current old diff
