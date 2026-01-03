MAIN_DIR := thesis
MAIN_TEX := thesis/main.tex
# Relative path to use when inside MAIN_DIR
MAIN_TEX_REL := main.tex
LATEXMKRC := $(CURDIR)/latexmkrc

LATEXMK := latexmk
LATEXMK_FLAGS := -pdf -halt-on-error -file-line-error -r $(LATEXMKRC)

.PHONY: pdf watch clean distclean

pdf:
	@cd $(MAIN_DIR) && $(LATEXMK) $(LATEXMK_FLAGS) $(MAIN_TEX_REL)

watch:
	@cd $(MAIN_DIR) && $(LATEXMK) $(LATEXMK_FLAGS) -pvc $(MAIN_TEX_REL)

clean:
	@cd $(MAIN_DIR) && $(LATEXMK) -c -r $(LATEXMKRC) $(MAIN_TEX_REL)
	@cd $(MAIN_DIR) && rm -f indent.log main.bbl main-*.glstex

distclean:
	@cd $(MAIN_DIR) && $(LATEXMK) -C -r $(LATEXMKRC) $(MAIN_TEX_REL)
	@cd $(MAIN_DIR) && rm -f indent.log main.bbl main-*.glstex
