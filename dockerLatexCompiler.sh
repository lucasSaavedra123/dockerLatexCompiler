# Available tags: latest (full), base, minimal, medium, small
# More: https://hub.docker.com/r/texlive/texlive
IMAGE="texlive/texlive:latest"

# --- Usage ---
if [[ $# -lt 2 ]]; then
  echo "Usage: compileLatex.sh <project_dir> <archive.tex> [engine]"
  echo ""
  echo "  engine: pdf | xelatex | lualatex (default: pdf)"
  echo ""
  echo "Example: compileLatex ./my-thesis main.tex xelatex"
  exit 1
fi

PROJECT_DIR="$(cd "$1" && pwd)"
TEX_FILE="$2"
ENGINE="${3:-pdf}"

if [[ ! -f "$PROJECT_DIR/$TEX_FILE" ]]; then
  echo "Error: $PROJECT_DIR/$TEX_FILE not found"
  exit 1
fi

mkdir -p "$PROJECT_DIR/out"

echo "Compiling $TEX_FILE ..."
docker run --rm \
  -v "$PROJECT_DIR":/doc \
  -w /doc \
  "$IMAGE" \
  latexmk "-$ENGINE" -interaction=nonstopmode -output-directory=out "$TEX_FILE"

PDF_OUT="out/${TEX_FILE%.tex}.pdf"
if [[ -f "$PROJECT_DIR/$PDF_OUT" ]]; then
  echo "Generated PDF at $PROJECT_DIR/$PDF_OUT"
else
  echo "Error: PDF was not generated"
  exit 1
fi