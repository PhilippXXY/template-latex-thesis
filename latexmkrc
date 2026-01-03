# latexmkrc (repo root)
# Works with latexmk's rc-variable mechanism (no "use strict")

use File::Basename;

# -----------------------------
# Basic build settings
# -----------------------------
$pdf_mode = 1;

# NOTE: You are calling latexmk with -cd and -outdir=../build,
# so these are not required. If you want rc to control it, set:
# $out_dir = '../build';
# $aux_dir = '../build';

$interaction = 'nonstopmode';
$recorder    = 1;
$max_repeat  = 5;

$pdflatex = 'pdflatex -synctex=1 -file-line-error -interaction=nonstopmode %O %S';

# -----------------------------
# Glossaries-extra via bib2gls
# -----------------------------
# Register generated file extensions so latexmk knows to clean them
# 'glg' = bib2gls log file, '%R*.glstex' = generated glossary files (e.g., main-1.glstex)
# 'bbl' = bibliography file, 'indent.log' = latexindent formatter log
push @generated_exts, 'glg', '%R*.glstex', 'bbl', 'indent.log';

# Define custom dependency: when .aux changes, regenerate .glstex by running bib2gls
# add_cus_dep(from_ext, to_ext, must_exist, function_name)
add_cus_dep( 'aux', 'glstex', 0, 'run_bib2gls' );

# Custom function to run bib2gls with proper options
sub run_bib2gls {
  my $ret = 0;
  # Extract base name and directory path from the .aux file
  my ($base, $path) = fileparse( $_[0] );

  # Build bib2gls command with UTF-8 encoding and grouping enabled
  my @bib2gls_cmd = (
    "--tex-encoding", "UTF-8",  # TeX file encoding
    "--log-encoding", "UTF-8",  # Log file encoding
    "--group",                  # Enable letter grouping in glossaries
    "--dir", $path,             # Working directory
    $base                       # Base name of the .aux file (without extension)
  );

  # Add silent flag if latexmk is running in silent mode
  if ($silent) { unshift @bib2gls_cmd, "--silent"; }
  unshift @bib2gls_cmd, "bib2gls";

  # Execute bib2gls
  print "Running '@bib2gls_cmd'...\n";
  $ret = system @bib2gls_cmd;

  # If bib2gls failed, warn and return error code
  if ($ret) {
    warn "run_bib2gls: Error, so I won't analyze .glg file\n";
    return $ret;
  }

  # Parse the .glg log file to register input/output files with latexmk
  # This ensures latexmk tracks dependencies correctly
  my $glg = "$_[0].glg";
  if ( open( my $glg_fh, '<', $glg) ) {
    rdb_add_generated( $glg );
    while (<$glg_fh>) {
      s/\s*$//;
      # Track files that bib2gls reads (input dependencies)
      if (/^Reading\s+(.+)$/) { rdb_ensure_file( $rule, $1 ); }
      # Track files that bib2gls writes (generated outputs)
      if (/^Writing\s+(.+)$/) { rdb_add_generated( $1 ); }
    }
    close $glg_fh;
  } else {
    warn "run_bib2gls: Cannot read log file '$glg': $!\n";
  }

  return $ret;
}

# -----------------------------
# Extra clean extensions
# -----------------------------
$clean_ext .= ' acn acr alg glg glo gls glsdefs glstex bbl ist lol lof lot nav out run.xml snm toc vrb xdy fdb_latexmk fls synctex.gz bcf indent.log';
