# Available tags: latest (full), base, minimal, medium, small
# More: https://hub.docker.com/r/texlive/texlive
$IMAGE = "texlive/texlive:latest"

# docker/latexmk write normal progress output to stderr; under an inherited
# $ErrorActionPreference = "Stop" (e.g. from a caller script) PowerShell 5.1
# would treat that stderr text as a terminating error. Exit status is checked
# explicitly via $LASTEXITCODE below, so stderr text alone must not abort.
$ErrorActionPreference = "Continue"

# --- Usage ---
if ($args.Count -lt 2) {
    Write-Host "Usage: compileLatex.ps1 <project_dir> <archive.tex> [engine]"
    Write-Host ""
    Write-Host "  engine: pdf | xelatex | lualatex (default: pdf)"
    Write-Host ""
    Write-Host "Example: compileLatex ./my-thesis main.tex xelatex"
    exit 1
}

$PROJECT_DIR = (Resolve-Path $args[0]).Path
$TEX_FILE = $args[1]
$ENGINE = if ($args.Count -ge 3) { $args[2] } else { "pdf" }

if (-not (Test-Path (Join-Path $PROJECT_DIR $TEX_FILE))) {
    Write-Host "Error: $PROJECT_DIR/$TEX_FILE not found"
    exit 1
}

New-Item -ItemType Directory -Force (Join-Path $PROJECT_DIR "out") | Out-Null

Write-Host "Compiling $TEX_FILE ..."
docker run --rm `
    -v "${PROJECT_DIR}:/doc" `
    -w /doc `
    $IMAGE `
    latexmk "-$ENGINE" -interaction=nonstopmode -output-directory=out "$TEX_FILE"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: docker run failed"
    exit 1
}

$PDF_OUT = "out/" + [System.IO.Path]::GetFileNameWithoutExtension($TEX_FILE) + ".pdf"
if (Test-Path (Join-Path $PROJECT_DIR $PDF_OUT)) {
    Write-Host "Generated PDF at $PROJECT_DIR/$PDF_OUT"
} else {
    Write-Host "Error: PDF was not generated"
    exit 1
}
