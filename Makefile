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

.PHONY: help pdf watch quick clean distclean spell check stats setup

# ==============================================================================
# Help
# ==============================================================================
help:
	@echo ""
	@echo "$(C_BOLD)$(C_CYAN)Makefile Commands$(C_NC)"
	@echo ""
	@echo "$(C_BOLD)$(C_MAGENTA)Build:$(C_NC)"
	@echo "  $(C_BOLD)$(C_CYAN)make pdf$(C_NC)       $(C_DIM)-$(C_NC) Build the PDF (full compilation)"
	@echo "  $(C_BOLD)$(C_CYAN)make watch$(C_NC)     $(C_DIM)-$(C_NC) Build and watch for changes"
	@echo "  $(C_BOLD)$(C_CYAN)make quick$(C_NC)     $(C_DIM)-$(C_NC) Quick compile (single pass, no bib/glossary)"
	@echo "  $(C_BOLD)$(C_CYAN)make clean$(C_NC)     $(C_DIM)-$(C_NC) Clean auxiliary files"
	@echo "  $(C_BOLD)$(C_CYAN)make distclean$(C_NC) $(C_DIM)-$(C_NC) Clean everything including PDF"
	@echo ""
	@echo "$(C_BOLD)$(C_MAGENTA)Quality:$(C_NC)"
	@echo "  $(C_BOLD)$(C_CYAN)make spell$(C_NC)     $(C_DIM)-$(C_NC) Check spelling with aspell"
	@echo "  $(C_BOLD)$(C_CYAN)make check$(C_NC)     $(C_DIM)-$(C_NC) Run all validation checks"
	@echo "  $(C_BOLD)$(C_CYAN)make stats$(C_NC)     $(C_DIM)-$(C_NC) Show document statistics"
	@echo ""
	@echo "$(C_BOLD)$(C_MAGENTA)Setup:$(C_NC)"
	@echo "  $(C_BOLD)$(C_CYAN)make setup$(C_NC)     $(C_DIM)-$(C_NC) Install pre-commit hooks"
	@echo ""

# ==============================================================================
# Build Targets
# ==============================================================================
pdf:
	@echo "$(C_BLUE)Building PDF...$(C_NC)"
	@cd $(MAIN_DIR) && $(LATEXMK) $(LATEXMK_FLAGS) $(MAIN_TEX_REL)
	@echo "$(C_GREEN)Done$(C_NC)"

watch:
	@cd $(MAIN_DIR) && $(LATEXMK) $(LATEXMK_FLAGS) -pvc $(MAIN_TEX_REL)

quick:
	@echo "$(C_BLUE)Quick compile...$(C_NC)"
	@cd $(MAIN_DIR) && pdflatex -interaction=nonstopmode -halt-on-error $(MAIN_TEX_REL)
	@echo "$(C_GREEN)Done$(C_NC)"

clean:
	@cd $(MAIN_DIR) && $(LATEXMK) -c -r $(LATEXMKRC) $(MAIN_TEX_REL)
	@cd $(MAIN_DIR) && rm -f indent.log main.bbl main-*.glstex
	@echo "$(C_GREEN)Cleaned$(C_NC)"

distclean:
	@cd $(MAIN_DIR) && $(LATEXMK) -C -r $(LATEXMKRC) $(MAIN_TEX_REL)
	@cd $(MAIN_DIR) && rm -f indent.log main.bbl main-*.glstex *.pdf
	@echo "$(C_GREEN)Cleaned (including PDF)$(C_NC)"

# ==============================================================================
# Quality Targets
# ==============================================================================
spell:
	@echo "$(C_BLUE)Checking spelling...$(C_NC)"
	@for f in $(TEX_FILES); do \
		WORDS=$$(cat "$$f" | aspell --mode=tex --lang=en --conf=$(CURDIR)/.aspell.conf list 2>/dev/null | sort -u); \
		if [ -n "$$WORDS" ]; then \
			echo "$(C_YELLOW)$$f:$(C_NC)"; \
			echo "$$WORDS" | head -10 | sed 's/^/  /'; \
		fi; \
	done
	@echo "$(C_GREEN)Done (add valid words to aspell-project.dict)$(C_NC)"

check:
	@echo "$(C_BOLD)Running checks...$(C_NC)"
	@echo ""
	@# Check duplicate bib keys
	@echo "$(C_BLUE)[1/3] Duplicate bibliography keys$(C_NC)"
	@DUPS=$$(grep -h '^\s*@[^{]*{' $(BIB_FILES) 2>/dev/null | sed 's/.*{\([^,]*\).*/\1/' | sort | uniq -d); \
	if [ -n "$$DUPS" ]; then echo "$(C_RED)  Found: $$DUPS$(C_NC)"; else echo "  OK"; fi
	@echo ""
	@# Check for TODOs
	@echo "$(C_BLUE)[2/3] TODO/FIXME comments$(C_NC)"
	@TODOS=$$(grep -rniE '\b(TODO|FIXME)\b' $(MAIN_DIR) --include="*.tex" 2>/dev/null | wc -l | tr -d ' '); \
	if [ "$$TODOS" -gt 0 ]; then echo "$(C_YELLOW)  Found $$TODOS TODO/FIXME comments$(C_NC)"; else echo "  OK"; fi
	@echo ""
	@# Quick compile test
	@echo "$(C_BLUE)[3/3] Compile test$(C_NC)"
	@cd $(MAIN_DIR) && pdflatex -interaction=batchmode -halt-on-error $(MAIN_TEX_REL) >/dev/null 2>&1 \
		&& echo "  OK" || echo "$(C_RED)  Compile failed$(C_NC)"
	@cd $(MAIN_DIR) && rm -f *.aux *.log *.out 2>/dev/null || true
	@echo ""
	@echo "$(C_GREEN)Checks complete$(C_NC)"

stats:
	@echo "$(C_BOLD)$(C_CYAN)Document Statistics$(C_NC)"
	@echo ""
	@if command -v texcount >/dev/null 2>&1; then \
		cd $(MAIN_DIR) && { \
			OUTPUT=$$(texcount -inc -brief main.tex 2>/dev/null); \
			TOTAL=$$(echo "$$OUTPUT" | grep "File(s) total" | grep -oP '\d+(?=\+)' | head -1); \
			echo "$(C_BOLD)$(C_GREEN)Total Words:$(C_NC) $$TOTAL"; \
			echo ""; \
			echo "$$OUTPUT" | grep "Included file:" | while IFS= read -r line; do \
				FILE=$$(echo "$$line" | sed 's/.*Included file: \.\/\(.*\)/\1/'); \
				WORDS=$$(echo "$$line" | sed 's/^\([0-9]*\)+.*/\1/'); \
				printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "$$FILE" "$$WORDS"; \
			done; \
		}; \
	else \
		echo "$(C_YELLOW)texcount not installed$(C_NC)"; \
	fi
	@echo ""
	@TEXCOUNT=$$(echo $(TEX_FILES) | wc -w | tr -d ' '); \
	FIGCOUNT=$$(find $(MAIN_DIR)/figures -type f 2>/dev/null | wc -l | tr -d ' '); \
	TABCOUNT=$$(find $(MAIN_DIR)/tables -type f 2>/dev/null | wc -l | tr -d ' '); \
	echo "$(C_BOLD)$(C_BLUE)Files:$(C_NC)"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "LaTeX files:" "$$TEXCOUNT"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "Figures:" "$$FIGCOUNT"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "Tables:" "$$TABCOUNT"
	@echo ""
	@LITCOUNT=$$(grep -h '^\s*@' $(MAIN_DIR)/bibliography/literature.bib 2>/dev/null | wc -l | tr -d ' '); \
	ABBRCOUNT=$$(grep -h '^\s*@abbreviation' $(MAIN_DIR)/glossary/abbreviations.bib 2>/dev/null | wc -l | tr -d ' '); \
	SYMCOUNT=$$(grep -h '^\s*@symbol' $(MAIN_DIR)/glossary/symbols.bib 2>/dev/null | wc -l | tr -d ' '); \
	echo "$(C_BOLD)$(C_MAGENTA)Bibliography & Glossary:$(C_NC)"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "References:" "$$LITCOUNT"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "Abbreviations:" "$$ABBRCOUNT"; \
	printf "  $(C_DIM)%-40s$(C_NC) %4s\n" "Symbols:" "$$SYMCOUNT"


# ==============================================================================
# Setup
# ==============================================================================
setup:
	@echo "$(C_BLUE)Setting up development environment...$(C_NC)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install && echo "$(C_GREEN)Pre-commit hooks installed$(C_NC)"; \
	else \
		echo "$(C_YELLOW)pre-commit not found. Install with: pip install pre-commit$(C_NC)"; \
	fi
