# LaTeX Thesis Template

A structured LaTeX template for academic theses using modern bibliography management (biblatex/biber), glossary handling (bib2gls), and automated releases.

## Structure

```
thesis/
├── main.tex              # Main document
├── frontmatter/          # Abstract, etc.
├── sections/             # Thesis chapters
├── backmatter/           # Appendix
├── glossary/             # Abbreviations and symbols (.bib files)
├── bibliography/         # References (.bib files)
├── figures/              # Images
└── styles/               # Style files (.cls files)

```

## Customisation

**Important:** Adjust this template to match your institution's formatting requirements. Modify the document class, margins, fonts, and other styling according to your institution's guidelines.

## Building the PDF

The template uses a Makefile with automated build management:

```bash
# Build the PDF
make pdf

# Build and watch for changes (auto-rebuild)
make watch

# Clean auxiliary files
make clean

# Clean everything including the PDF
make distclean
```

The Makefile automatically runs:

- `pdflatex` for LaTeX compilation
- `biber` for bibliography processing
- `bib2gls` for glossaries and symbols

## GitHub Workflows & Automation

This template includes automated GitHub workflows to maintain code quality and streamline the development process:

### Pull Request Checks

When you create a pull request, the following automated checks run:

- **LaTeX Compilation**: Verifies that the thesis compiles without errors and checks for missing references (`??` in the output)
- **TODO Check**: Scans for `TODO`, `FIXME`, `HACK`, and `XXX` comments to ensure they're addressed before merging
- **File Quality**: Checks for trailing whitespace and proper file endings (final newline)
- **Required Files**: Ensures all essential files and directories are present

### Issue Management

- **Status Labels**: Automatically updates issue status labels when you create a branch (sets "status - In Progress") or close an issue (sets "status - Done")

### Release Automation

- **Automatic Releases**: When a PR titled with a version number (e.g., `v1.0.0` or `1.0.0`) is merged to main, the workflow:
  - Compiles the thesis PDF
  - Creates a GitHub release with the version tag
  - Attaches the compiled PDF to the release

These workflows help maintain quality and automate repetitive tasks throughout your thesis development.

## Requirements

- TeX Live or similar LaTeX distribution
- Perl (required by latexmk)
- `latexmk` (usually included with TeX Live)
- `biber` (for bibliography)
- `bib2gls` (for glossaries)
