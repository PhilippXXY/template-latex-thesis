# ==============================================================================
# Makefile
# ==============================================================================

# Configuration
MAIN_DIR     := thesis
MAIN_TEX_REL := main.tex
LATEXMKRC    := $(CURDIR)/latexmkrc
LATEXMK      := latexmk
LATEXMK_FLAGS := -pdf -halt-on-error -file-line-error -r $(LATEXMKRC)

# File patterns
TEX_FILES := $(shell find $(MAIN_DIR) -name '*.tex' -type f 2>/dev/null)
BIB_FILES := $(shell find $(MAIN_DIR) -name '*.bib' -type f 2>/dev/null)

# Colors (disable with NO_COLOR=1)
ifndef NO_COLOR
  C_GREEN  := \033[0;32m
  C_YELLOW := \033[0;33m
  C_RED    := \033[0;31m
  C_BLUE   := \033[0;34m
  C_CYAN   := \033[0;36m
  C_MAGENTA := \033[0;35m
  C_BOLD   := \033[1m
  C_DIM    := \033[2m
  C_NC     := \033[0m
endif

# Common formatting
SEPARATOR := $(C_DIM)--------------------------------------------------------------------------------$(C_NC)
MSG_START = @echo ""; echo "$(SEPARATOR)"; echo "$(C_BOLD)$(C_CYAN)$(1)$(C_NC)"; echo "$(SEPARATOR)"
MSG_DONE  = @echo ""; echo "$(C_GREEN)[done]$(C_NC) $(1)"; echo ""
MSG_WARN  = @echo "$(C_YELLOW)[warn]$(C_NC) $(1)"
MSG_ERR   = @echo "$(C_RED)[error]$(C_NC) $(1)"
MSG_INFO  = @echo "$(C_BLUE)[info]$(C_NC) $(1)"
MSG_OK    = @echo "$(C_GREEN)[ok]$(C_NC) $(1)"

.PHONY: help pdf watch quick clean distclean spell check stats setup

# ==============================================================================
# Help
# ==============================================================================
help:
	@echo ""
	@echo "$(SEPARATOR)"
	@echo "$(C_BOLD)$(C_CYAN)Makefile Commands$(C_NC)"
	@echo "$(SEPARATOR)"
	@echo ""
	@echo "$(C_BOLD)$(C_MAGENTA)Build:$(C_NC)"
	@echo "  $(C_CYAN)make pdf$(C_NC)         $(C_DIM)-$(C_NC) Build the PDF (full compilation)"
	@echo "  $(C_CYAN)make watch$(C_NC)       $(C_DIM)-$(C_NC) Build and watch for changes"
	@echo "  $(C_CYAN)make quick$(C_NC)       $(C_DIM)-$(C_NC) Quick compile (single pass, no bib/glossary)"
	@echo "  $(C_CYAN)make clean$(C_NC)       $(C_DIM)-$(C_NC) Clean auxiliary files"
	@echo "  $(C_CYAN)make distclean$(C_NC)   $(C_DIM)-$(C_NC) Clean everything including PDF"
	@echo ""
	@echo "$(C_BOLD)$(C_MAGENTA)Quality:$(C_NC)"
	@echo "  $(C_CYAN)make spell$(C_NC)       $(C_DIM)-$(C_NC) Check spelling with aspell"
	@echo "  $(C_CYAN)make check$(C_NC)       $(C_DIM)-$(C_NC) Run all validation checks"
	@echo "  $(C_CYAN)make stats$(C_NC)       $(C_DIM)-$(C_NC) Show document statistics"
	@echo ""
	@echo "$(C_BOLD)$(C_MAGENTA)Setup:$(C_NC)"
	@echo "  $(C_CYAN)make setup$(C_NC)       $(C_DIM)-$(C_NC) Install pre-commit hooks"
	@echo ""

# ==============================================================================
# Build Targets
# ==============================================================================
pdf:
	$(call MSG_START,Building PDF)
	@$(MSG_INFO) Compiling $(MAIN_DIR)/$(MAIN_TEX_REL)
	@cd $(MAIN_DIR) && $(LATEXMK) $(LATEXMK_FLAGS) $(MAIN_TEX_REL)
	$(call MSG_DONE,PDF build complete)

watch:
	$(call MSG_START,Watch Mode)
	@$(MSG_INFO) Watching for changes in $(MAIN_DIR)
	@cd $(MAIN_DIR) && $(LATEXMK) $(LATEXMK_FLAGS) -pvc $(MAIN_TEX_REL)

quick:
	$(call MSG_START,Quick Compile)
	@echo "$(C_BLUE)[info]$(C_NC) Single-pass compilation (no bibliography/glossary)"
	@cd $(MAIN_DIR) && pdflatex -interaction=nonstopmode -halt-on-error $(MAIN_TEX_REL)
	$(call MSG_DONE,Quick compile complete)

clean:
	$(call MSG_START,Cleaning Auxiliary Files)
	@cd $(MAIN_DIR) && $(LATEXMK) -c -r $(LATEXMKRC) $(MAIN_TEX_REL)
	@cd $(MAIN_DIR) && rm -f indent.log main.bbl main-*.glstex
	$(call MSG_DONE,Auxiliary files cleaned)

distclean:
	$(call MSG_START,Cleaning All Files)
	@cd $(MAIN_DIR) && $(LATEXMK) -C -r $(LATEXMKRC) $(MAIN_TEX_REL)
	@cd $(MAIN_DIR) && rm -f indent.log main.bbl main-*.glstex *.pdf
	$(call MSG_DONE,All files cleaned including PDF)

# ==============================================================================
# Quality Targets
# ==============================================================================
spell:
	$(call MSG_START,Spell Check)
	@$(MSG_INFO) Checking spelling in .tex files
	@for f in $(TEX_FILES); do \
		WORDS=$$(cat "$$f" | aspell --mode=tex --lang=en --conf=$(CURDIR)/.aspell.conf list 2>/dev/null | sort -u); \
		if [ -n "$$WORDS" ]; then \
			echo "$(C_YELLOW)[warn]$(C_NC) $(C_BOLD)$$f$(C_NC)"; \
			echo "$$WORDS" | head -10 | sed 's/^/       → /'; \
		fi; \
	done
	$(call MSG_DONE,Spell check complete - add valid words to aspell-project.dict)

check:
	$(call MSG_START,Validation Checks)
	@echo ""
	@$(MSG_INFO) [1/3] Checking for duplicate bibliography keys
	@DUPS=$$(grep -h '^\s*@[^{]*{' $(BIB_FILES) 2>/dev/null | sed 's/.*{\([^,]*\).*/\1/' | sort | uniq -d); \
	if [ -n "$$DUPS" ]; then echo "$(C_RED)[error]$(C_NC) Duplicates found: $$DUPS"; else echo "$(C_GREEN)[ok]$(C_NC) No duplicates"; fi
	@echo ""
	@$(MSG_INFO) [2/3] Checking for TODO/FIXME comments
	@TODOS=$$(grep -rniE '\b(TODO|FIXME)\b' $(MAIN_DIR) --include="*.tex" 2>/dev/null | wc -l | tr -d ' '); \
	if [ "$$TODOS" -gt 0 ]; then echo "$(C_YELLOW)[warn]$(C_NC) Found $$TODOS TODO/FIXME comments"; else echo "$(C_GREEN)[ok]$(C_NC) No TODO/FIXME found"; fi
	@echo ""
	@$(MSG_INFO) [3/3] Running compile test
	@cd $(MAIN_DIR) && pdflatex -interaction=batchmode -halt-on-error $(MAIN_TEX_REL) >/dev/null 2>&1 \
		&& echo "$(C_GREEN)[ok]$(C_NC) Compile successful" || echo "$(C_RED)[error]$(C_NC) Compile failed"
	@cd $(MAIN_DIR) && rm -f *.aux *.log *.out 2>/dev/null || true
	$(call MSG_DONE,Validation checks complete)

stats:
	$(call MSG_START,Document Statistics)
	@echo ""
	@echo "$(C_BOLD)$(C_MAGENTA)Word Count:$(C_NC)"
	@if command -v texcount >/dev/null 2>&1; then \
		cd $(MAIN_DIR) && { \
			OUTPUT=$$(texcount -inc -brief main.tex 2>/dev/null); \
			TOTAL=$$(echo "$$OUTPUT" | grep "File(s) total" | grep -oP '\d+(?=\+)' | head -1); \
			echo "  $(C_CYAN)Total:$(C_NC) $$TOTAL words"; \
			echo ""; \
			echo "$(C_BOLD)$(C_MAGENTA)Per File:$(C_NC)"; \
			echo "$$OUTPUT" | grep "Included file:" | while IFS= read -r line; do \
				FILE=$$(echo "$$line" | sed 's/.*Included file: \.\/\(.*\)/\1/'); \
				WORDS=$$(echo "$$line" | sed 's/^\([0-9]*\)+.*/\1/'); \
				printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "$$FILE" "$$WORDS"; \
			done; \
		}; \
	else \
		echo "  $(C_YELLOW)[warn]$(C_NC) texcount not installed"; \
	fi
	@echo ""
	@TEXCOUNT=$$(echo $(TEX_FILES) | wc -w | tr -d ' '); \
	FIGCOUNT=$$(find $(MAIN_DIR)/figures -type f 2>/dev/null | wc -l | tr -d ' '); \
	TABCOUNT=$$(find $(MAIN_DIR)/tables -type f 2>/dev/null | wc -l | tr -d ' '); \
	echo "$(C_BOLD)$(C_MAGENTA)File Count:$(C_NC)"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "LaTeX files" "$$TEXCOUNT"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "Figures" "$$FIGCOUNT"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "Tables" "$$TABCOUNT"
	@echo ""
	@LITCOUNT=$$(grep -h '^\s*@' $(MAIN_DIR)/bibliography/literature.bib 2>/dev/null | wc -l | tr -d ' '); \
	ABBRCOUNT=$$(grep -h '^\s*@abbreviation' $(MAIN_DIR)/glossary/abbreviations.bib 2>/dev/null | wc -l | tr -d ' '); \
	SYMCOUNT=$$(grep -h '^\s*@symbol' $(MAIN_DIR)/glossary/symbols.bib 2>/dev/null | wc -l | tr -d ' '); \
	echo "$(C_BOLD)$(C_MAGENTA)Bibliography and Glossary Entries:$(C_NC)"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "References" "$$LITCOUNT"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "Abbreviations" "$$ABBRCOUNT"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "Symbols" "$$SYMCOUNT"
	@echo ""


# ==============================================================================
# Setup
# ==============================================================================
setup:
	$(call MSG_START,Development Environment Setup)
	@$(MSG_INFO) Installing pre-commit hooks
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install && echo "$(C_GREEN)[ok]$(C_NC) Pre-commit hooks installed"; \
	else \
		echo "$(C_YELLOW)[warn]$(C_NC) pre-commit not found - install with: pip install pre-commit"; \
	fi
	$(call MSG_DONE,Setup complete)
