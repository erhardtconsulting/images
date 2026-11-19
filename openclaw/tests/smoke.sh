#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C.UTF-8

test "$(id -u)" = 1000
test "$HOME" = /home/node
awk '$2 == "/" { found = 1; if ($4 !~ /(^|,)ro(,|$)/) exit 1 } END { if (!found) exit 1 }' /proc/mounts
for tool in deno openscad xvfb-run pandoc git gh libreoffice soffice mvn node npm pdfgrep pdfinfo \
    pdftotext pdftoppm qpdf java javac sqlite3 tree uv vim wget yt-dlp \
    make ssh ssh-keygen sftp scp rsync jq less ps top free ip ping dig nc \
    unzip zip 7z bzip2 zstd file patch xz curl tar gzip ffmpeg ffprobe; do
    command -v "$tool"
done
test "$(command -v node)" = /usr/local/bin/node
node -e 'if (!process.release.lts) throw new Error("OpenClaw must retain its LTS Node runtime")'
java -XshowSettings:properties -version 2>&1 | grep -F 'java.vendor = Eclipse Adoptium'
java -XshowSettings:properties -version 2>&1 | grep -E 'java.specification.version = 25$'
mvn --version | grep -E 'Java version: 25.*vendor: Eclipse Adoptium'
gh --version
git --version
yt-dlp --version
yt-dlp --ignore-config --list-extractors | grep -Fx youtube
vim --version | sed -n '1,3p'
wget --version | sed -n '1p'
tree --version
qmd --version

work=$(mktemp -d)
cd "$work"
printf 'sample\n' > video.mp4
yt-dlp --ignore-config --verbose --enable-file-urls --simulate \
    "file://$work/video.mp4" > /dev/null 2> yt-dlp.log
grep -E 'Optional libraries: .*yt_dlp_ejs-' yt-dlp.log
grep -E 'JS runtimes: .*deno-' yt-dlp.log
printf 'all:\n\t@echo make-ok\n' > Makefile
test "$(make --no-print-directory)" = make-ok
test "$(printf '{\"ready\":true}' | jq -r '.ready')" = true
printf 'archive test\n' > archive.txt
zip -q archive.zip archive.txt
unzip -p archive.zip archive.txt | grep -Fx 'archive test'
file archive.zip | grep -F 'Zip archive data'
for codec in gzip bzip2 xz zstd; do
    tar --create --use-compress-program="$codec" --file="archive.$codec.tar" archive.txt
    test "$(tar --extract --to-stdout --use-compress-program="$codec" \
        --file="archive.$codec.tar" archive.txt)" = 'archive test'
done
7z a -bd -y archive.7z archive.txt >/dev/null
test "$(7z x -so archive.7z archive.txt)" = 'archive test'
ffmpeg -v error -f lavfi -i anullsrc=r=16000:cl=mono -t 0.1 -c:a pcm_s16le audio.wav
test "$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name \
    -of default=noprint_wrappers=1:nokey=1 audio.wav)" = pcm_s16le
printf 'public class Hello { public static void main(String[] args) { System.out.print("temurin25"); } }\n' > Hello.java
javac Hello.java
test "$(java -cp . Hello)" = temurin25
cat > pom.xml <<'XML'
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>
  <groupId>image.smoke</groupId>
  <artifactId>documents</artifactId>
  <version>1.0</version>
</project>
XML
mvn --offline --batch-mode --no-transfer-progress validate
test "$(deno eval 'console.log(6 * 7)')" = 42
test "$(command -v python3)" = /usr/bin/python3
python3 - <<'PY'
import sys
from pathlib import Path

import docx
import openpyxl
import pdfminer
import pypdf
import reportlab

assert sys.prefix == sys.base_prefix
for module in (docx, openpyxl, pdfminer, pypdf, reportlab):
    assert Path(module.__file__).is_relative_to("/usr/lib/python3/dist-packages"), module.__file__
PY

python3 -m venv --system-site-packages "$work/venv"
"$work/venv/bin/python" -m pip --version
"$work/venv/bin/python" -m pip check
python3 /opt/openclaw-tests/documents.py "$work"
mkdir docx-pdf xlsx-pdf
libreoffice --headless "-env:UserInstallation=file://$work/office-profile" \
    --convert-to pdf --outdir docx-pdf edited.docx
libreoffice --headless "-env:UserInstallation=file://$work/office-profile" \
    --convert-to pdf --outdir xlsx-pdf edited.xlsx
pdftotext docx-pdf/edited.pdf docx.txt
grep -F 'Edited quarterly report' docx.txt
pdftotext xlsx-pdf/edited.pdf xlsx.txt
grep -F 'Edited spreadsheet' xlsx.txt
grep -E '^12$' xlsx.txt
qpdf --check edited.pdf
pdfinfo edited.pdf | grep -E '^Pages:[[:space:]]+3$'
pdfgrep -q 'Second original page' edited.pdf
pdftoppm -f 1 -singlefile -scale-to 64 -png edited.pdf preview
test -s preview.png
printf '# Converted document\n\nPandoc document content.\n' > source.md
pandoc source.md -o pandoc.docx
python3 - <<'PY'
from docx import Document

assert any("Pandoc document content." in p.text for p in Document("pandoc.docx").paragraphs)
PY

sqlite3 test.sqlite 'CREATE TABLE documents (name TEXT); INSERT INTO documents VALUES ("draft"); UPDATE documents SET name = "edited";'
test "$(sqlite3 test.sqlite 'SELECT name FROM documents;')" = edited
if command -v magick >/dev/null 2>&1; then
    convert_image=(magick)
    identify_image=(magick identify)
else
    convert_image=(convert)
    identify_image=(identify)
fi
"${convert_image[@]}" -size 80x40 xc:navy original.png
"${convert_image[@]}" original.png -resize '40x20!' smaller.png
"${convert_image[@]}" original.png -resize '160x80!' larger.jpg
test "$("${identify_image[@]}" -format '%m %w %h' smaller.png)" = 'PNG 40 20'
test "$("${identify_image[@]}" -format '%m %w %h' larger.jpg)" = 'JPEG 160 80'

cat > openscad-cube.scad <<'SCAD'
cube([10, 20, 30], center=true);
SCAD
QT_QPA_PLATFORM=offscreen openscad -o openscad-cube.stl openscad-cube.scad
test -s openscad-cube.stl
python3 - <<'PY'
import trimesh

trimesh.creation.box(extents=[10, 20, 30]).export("python-cube.stl")
PY

cat > stl-preview.scad <<'SCAD'
import("python-cube.stl");
SCAD
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24' \
    env LIBGL_ALWAYS_SOFTWARE=1 openscad --viewall --autocenter --imgsize=128,128 \
    -o python-cube.png stl-preview.scad
test -s python-cube.png
"${convert_image[@]}" python-cube.png -quality 85 python-cube.jpg
test "$("${identify_image[@]}" -format '%m' python-cube.jpg)" = JPEG

python3 - <<'PY'
from pathlib import Path

import numpy as np
import trimesh

assert Path(trimesh.__file__).is_relative_to("/usr/lib/python3/dist-packages")

expected_extents = [10, 20, 30]
openscad_mesh = trimesh.load("openscad-cube.stl", force="mesh")
assert openscad_mesh.is_watertight
assert np.allclose(openscad_mesh.extents, expected_extents, atol=1e-3)

python_mesh = trimesh.creation.box(extents=expected_extents)
for suffix in ("stl", "obj", "ply"):
    path = Path(f"python-cube.{suffix}")
    if suffix != "stl":
        python_mesh.export(path)
    assert path.is_file() and path.stat().st_size > 0
    converted_mesh = trimesh.load(path, force="mesh")
    assert converted_mesh.is_watertight
    assert np.allclose(converted_mesh.extents, expected_extents, atol=1e-3)
PY

mkdir notes
printf '# Moonstone\n\nMoonstone document processing test.\n' > notes/moonstone.md
qmd collection add "$work/notes" --name smoke
qmd search moonstone --json > results.json
node /opt/openclaw-tests/qmd-backend.mjs
python3 - <<'PY'
import json
from pathlib import Path

results = json.loads(Path("results.json").read_text())
assert any("moonstone.md" in result["file"] for result in results), results
PY
printf 'Document, PDF, image, SQLite and qmd operations passed with read-only root and no network\n'
