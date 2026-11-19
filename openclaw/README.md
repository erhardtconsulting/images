# OpenClaw

Extends `ghcr.io/openclaw/openclaw` with tools for creating, editing and
converting documents and images. The upstream `node` user (UID/GID 1000),
`/home/node` home, `/app` working directory, entrypoint and gateway command
are preserved.

## Tools

| Purpose | Tools |
| --- | --- |
| Documents and spreadsheets | LibreOffice No-GUI, Pandoc, openpyxl, python-docx |
| PDFs | pdfminer.six, pypdf, ReportLab, pdfgrep, Poppler (`pdfinfo`, `pdftotext`, `pdftoppm`), qpdf |
| Images | ImageMagick 7 (`magick`) |
| Search and data | SQLite CLI (`sqlite3`), globally installed `@tobilu/qmd` (`qmd`) |
| Development | Deno, Git, GitHub CLI, Maven, Temurin JDK 25, Node LTS, uv |
| Media | yt-dlp, FFmpeg |
| Utilities | tree, vim, wget |

The pinned upstream image was inspected before selecting the packages.
It already provides Git, Python 3.13 and Node 24 LTS; these are reused, not
reinstalled. Missing tools are installed statically in the Dockerfile, with
no detection scripts or conditional installation. Recheck the inventory when
changing the parent image.

The image also includes common server utilities: make, rsync, jq, less, ip,
ping, dig, netcat, file, patch, 7-Zip, zip/unzip, bzip2, xz and zstd. The
upstream SSH client, curl, procps, tar and gzip are reused.

The document libraries use Debian's `python3-reportlab`, `python3-docx`,
`python3-pypdf`, `python3-pdfminer` and `python3-openpyxl` packages with the
existing `/usr/bin/python3`, without a virtual environment or a Python `PATH`
override. `python3-venv` is also installed so applications can create their
own virtual environments in writable storage when needed.

PDF text extraction uses Debian's pdfminer.six; pdfplumber is not included.

yt-dlp is the official architecture-specific GitHub release binary, pinned to
the release tag in `YTDLP_VERSION` and checked against the release's SHA-256
checksum. It includes the EJS challenge scripts for the bundled Deno runtime.
Renovate tracks its GitHub release tag; Debian maintains the packaged document
libraries.

Debian 13 has no `pandoc-full` package, so the Dockerfile installs `pandoc`.
LibreOffice uses the `libreoffice-nogui` packages, not a desktop installation. Some
X client libraries are dependencies, but no X server or display is needed.
Temurin and Maven are copied from official, digest-pinned images without
installing an additional Debian JRE.

qmd is installed globally with npm using the upstream Node runtime. No Bun,
second Node runtime or qmd language models are installed. BM25 search works
without downloading models. Optional vector search and reranking download
models into qmd's writable user cache on first use and require sufficient
storage and network access.
Its native modules are compiled in a separate build stage; the compiler and
build dependencies are not copied into the runtime image.

## Document and image operations

Use Python's `docx`, `openpyxl`, `pypdf`, `pdfminer` and `reportlab` modules
to edit existing files or create new ones. For example:

```python
from docx import Document
from openpyxl import load_workbook
from pypdf import PdfReader, PdfWriter

document = Document("/tmp/input.docx")
document.paragraphs[0].text = "Updated report"
document.save("/tmp/updated.docx")

workbook = load_workbook("/tmp/input.xlsx")
workbook.active["A1"] = "Updated value"
workbook.save("/tmp/updated.xlsx")

reader = PdfReader("/tmp/input.pdf")
writer = PdfWriter()
writer.add_page(reader.pages[0].rotate(90))
writer.write("/tmp/first-page.pdf")
```

Convert documents headlessly, extract PDF text, or resize images:

```sh
libreoffice --headless --convert-to pdf --outdir /tmp /tmp/updated.docx
libreoffice --headless --convert-to pdf --outdir /tmp /tmp/updated.xlsx
pandoc /tmp/report.md -o /tmp/report.docx
pdftotext /tmp/report.pdf /tmp/report.txt
qpdf --check /tmp/report.pdf
magick /tmp/input.png -resize 50% /tmp/smaller.png
magick /tmp/input.png -resize 200% /tmp/larger.jpg
```

Use different output directories when inputs share the same basename.
LibreOffice handles Office-to-PDF rendering and spreadsheet formula
calculation; openpyxl edits formulas but does not calculate them. A complete
TeX distribution, OCR engine and unrestricted ImageMagick PDF policy are
not included.

## YouTube subtitles and audio

yt-dlp can download existing or automatically generated subtitles without
downloading video:

```sh
yt-dlp --skip-download --write-subs --write-auto-subs \
  --sub-langs 'de.*,en.*' -o '/tmp/%(id)s.%(ext)s' 'VIDEO_URL'
```

For videos without subtitles, yt-dlp and FFmpeg can extract audio for a
separate speech-to-text service or tool:

```sh
yt-dlp -f ba -x --audio-format wav -o '/tmp/%(id)s.%(ext)s' 'VIDEO_URL'
```

No local speech-recognition engine or model is bundled. Subtitles and audio
downloads require network access and depend on the video's availability.

## Node

OpenClaw and qmd continue to use the original `/usr/local/bin/node`. No nvm
or second Node runtime is installed; qmd's native modules use the upstream
Node ABI.

## Read-only root

All tools are installed at build time outside the home directory, so a home
mount does not hide them. Runtime data, user configuration, caches, Maven's
local repository, qmd indexes/models and document outputs still need writable
storage. Keep `/tmp` and the upstream `/home/node` writable and owned or
writable by UID/GID 1000. Additional configured workspaces need their own
writable mounts.

For an already configured OpenClaw home volume:

```sh
podman run --rm --read-only \
  --tmpfs /tmp:rw,nosuid,nodev,mode=1777 \
  --volume openclaw-home:/home/node \
  ghcr.io/erhardtconsulting/openclaw:latest
```

A mount at `/home/openclaw` alone does not cover the upstream home. This
image does not relocate it or alter upstream state/configuration behavior.
Mounting the whole upstream home also covers the `.openclaw.update-captures`
sibling directory used for pre-repair state captures.

## Build and verification

```sh
make openclaw
bash openclaw/test-image.sh erhardtconsulting/openclaw
```

The test runs without root privileges, with a read-only root filesystem.
Offline functional checks actually edit DOCX/XLSX/PDF files, render Office
files as PDFs, verify PDF contents and structure, resize images to exact
dimensions, query SQLite and index/search a qmd collection. They also check
Temurin/Maven and that the upstream Node remains the default.
A separate bounded check starts the gateway and checks `/healthz`.

The main and PR workflows build and test `linux/amd64` and `linux/arm64`
through the repository's reusable Buildah workflow. Only main/manual builds
publish to GHCR, with the upstream version and `latest` tags. Renovate tracks
the parent, tool images, qmd and yt-dlp releases. Temurin remains
on JDK 25 and Maven's source image retains the Temurin 25 variant.
