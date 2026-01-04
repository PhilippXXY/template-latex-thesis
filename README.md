# LaTeX Thesis Template

A structured LaTeX template for academic theses with modern bibliography management, glossary handling, and automated workflows.

## Features

- **Structured directory layout** for chapters, figures, tables, and bibliography
- **Modern bibliography** management using biblatex with biber backend
- **Glossaries and symbols** management via bib2gls workflow
- **Automated builds** with latexmk and Makefile
- **Quality checks** through pre-commit hooks and CI/CD workflows
- **Development container** for reproducible environment setup
- **Spell checking** with aspell and custom dictionaries
- **Automated releases** via GitHub Actions

## Directory Structure

```
thesis/
├── main.tex              # Main document
├── frontmatter/          # Abstract, title page, etc.
├── sections/             # Thesis chapters (numbered)
├── backmatter/           # Appendices
├── glossary/             # Abbreviations and symbols (.bib format)
├── bibliography/         # References (.bib format)
├── figures/              # Images and diagrams
├── tables/               # Table files
└── styles/               # Custom style files
```

## Getting Started

### Option 1: Development Container (Recommended)

The development container provides a pre-configured environment with all required tools.

**Requirements:**
- Docker Desktop
- Visual Studio Code
- Dev Containers extension

**Steps:**
1. Open the repository in VS Code
2. Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
3. Select "Dev Containers: Reopen in Container"
4. Wait for the container to build
5. Run `make pdf` to compile the thesis

### Option 2: Local Installation

**Requirements:**
- TeX Live distribution (with latexmk, biber, bib2gls)
- aspell (English dictionary)
- texcount
- Python 3 with pre-commit (`pip install pre-commit`)

**Setup:**
```bash
make setup     # Install pre-commit hooks
make pdf       # Build the thesis PDF
```

## Build Commands

The Makefile provides several targets for building and maintaining the thesis:

### Building

```bash
make pdf          # Full compilation (bibliography, glossaries, cross-references)
make watch        # Continuous compilation on file changes
make quick        # Single-pass compilation (fast, skips bibliography)
make clean        # Remove auxiliary files (.aux, .log, etc.)
make distclean    # Remove all generated files including PDF
```

### Quality Assurance

```bash
make spell        # Run spell checker on .tex files
make check        # Run all validation checks (bibliography, TODOs, compilation)
make stats        # Display document statistics (word count, files, references)
```

### Setup

```bash
make setup        # Install pre-commit hooks
```

## Spell Checking

The template uses aspell for spell checking with a custom dictionary.

**Custom dictionary:** `aspell-project.dict`
**Configuration:** `.aspell.conf`

Add domain-specific terms to `aspell-project.dict` to prevent false positives. The dictionary is used by both the Makefile and CI workflows.

## Pre-commit Hooks

Pre-commit hooks run automatically before each commit to maintain code quality.

**Installed checks:**
- Remove trailing whitespace
- Ensure files end with newline
- Validate YAML syntax
- Check for merge conflicts
- Normalise line endings to LF
- Spell check LaTeX files
- Detect duplicate bibliography keys
- List TODO/FIXME comments
- Quick compilation test (pre-push only)

**Manual execution:**
```bash
pre-commit run --all-files
```

## CI/CD Workflows

GitHub Actions workflows run on pull requests and pushes:

| Workflow | Description |
|----------|-------------|
| `latex_compile_check.yaml` | Full LaTeX compilation with biber and bib2gls |
| `spell_check.yaml` | Spell checking with aspell |
| `hygiene_checks.yaml` | Bibliography and glossary validation |
| `file_quality_check.yaml` | File formatting checks (whitespace, newlines) |
| `todo_check.yaml` | Scans for TODO/FIXME comments |
| `required_files_check.yaml` | Verifies required files exist |
| `release_from_pr.yaml` | Creates releases on PR merge to main |

All workflows can be triggered manually via the Actions tab.

## Development Container Details

The `.devcontainer` configuration provides:

**Base image:** TeX Live (latest)

**Installed tools:**
- latexmk, pdflatex, biber, bib2gls
- aspell with English dictionary
- texcount for word counting
- pre-commit for hook management
- Git and GitHub CLI
- PlantUML with PDF export support

**VS Code extensions:**
- LaTeX Workshop
- LTeX (grammar checking)
- Code Spell Checker
- PlantUML
- Better Comments

## Customisation

**Important:** This is a template. Adjust it to meet your institution's formatting requirements.

**Common customisations:**
- Edit `thesis/styles/` for custom style files
- Modify `thesis/main.tex` for document structure
- Update `.aspell.conf` and `aspell-project.dict` for spell checking
- Adjust `latexmkrc` for build configuration

## Bibliography Management

The template uses biblatex with biber:

**Bibliography file:** `thesis/bibliography/literature.bib`
**Default style:** IEEE
**Backend:** biber

Change the citation style in `thesis/main.tex`:
```latex
\usepackage[style=ieee,backend=biber]{biblatex}
```

## Glossary Management

Glossaries use bib2gls for sorting and indexing:

**Abbreviations:** `thesis/glossary/abbreviations.bib`
**Symbols:** `thesis/glossary/symbols.bib`

Example abbreviation entry:
```bibtex
@abbreviation{a:ecu,
  short          = {ECU},
  long_lowercase = {electronic control unit},
  long_titlecase = {Electronic Control Unit}
}
```

Example symbol entry:
```bibtex
@symbol{s:velocity,
  symbol      = {\ensuremath{v}},
  description = {Velocity},
  unit        = {\si{\meter\per\second}}
}
```

## Troubleshooting

**Compilation fails:**
- Run `make clean && make pdf`
- Check log files in `thesis/` directory
- Verify all referenced files exist

**Spell check false positives:**
- Add words to `aspell-project.dict`
- Rebuild to see changes

**Pre-commit hooks fail:**
- Run `pre-commit run --all-files` to see detailed errors
- Fix reported issues manually
- Use `git commit --no-verify` to skip hooks (not recommended)

**Development container issues:**
- Rebuild container: `Cmd+Shift+P` → "Dev Containers: Rebuild Container"
- Check Docker is running
- Verify Docker has sufficient resources allocated
