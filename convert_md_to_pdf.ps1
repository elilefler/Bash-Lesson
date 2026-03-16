<#
.SYNOPSIS
    Converts all Markdown files in this repository to PDF using Python.

.DESCRIPTION
    Uses Python (already installed) with the pure-Python libraries
  'markdown' and 'reportlab'. No external binaries required.
    Both libraries are installed automatically via pip if missing.

.EXAMPLE
    .\convert_md_to_pdf.ps1
    .\convert_md_to_pdf.ps1 -SourceDir "docs"
    .\convert_md_to_pdf.ps1 -OutDir "C:\output\pdfs"
#>

[CmdletBinding()]
param (
    # Root directory to search for .md files (default: repo root)
    [string]$SourceDir = $PSScriptRoot,

    # Optional output directory. If omitted, each PDF is placed next to its .md file.
    [string]$OutDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
if ($PSVersionTable.PSVersion.Major -ge 7) {
  $PSNativeCommandUseErrorActionPreference = $false
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-Step([string]$msg) { Write-Host "`n[*] $msg" -ForegroundColor Cyan }
function Write-Ok([string]$msg)   { Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Fail([string]$msg) { Write-Host "    [!!] $msg" -ForegroundColor Red }

# ---------------------------------------------------------------------------
# Require Python
# ---------------------------------------------------------------------------

Write-Step "Checking Python..."
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    Write-Fail "Python is not installed or not in PATH."
    Write-Host "    Download: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}
Write-Ok "Found: $($pythonCmd.Source)"

# ---------------------------------------------------------------------------
# Install pip dependencies (silent if already present)
# ---------------------------------------------------------------------------

Write-Step "Installing Python packages (markdown, reportlab, Pygments)..."
& python -m pip install --quiet --upgrade markdown reportlab Pygments
if ($LASTEXITCODE -ne 0) {
    Write-Fail "pip install failed. Check your internet connection and try again."
    exit 1
}
Write-Ok "Packages ready."

# ---------------------------------------------------------------------------
# Find all markdown files
# ---------------------------------------------------------------------------

Write-Step "Scanning for .md files under: $SourceDir"

$mdFiles = Get-ChildItem -Path $SourceDir -Recurse -Filter "*.md" |
           Where-Object { $_.FullName -notmatch '\\node_modules\\' }

if ($mdFiles.Count -eq 0) {
    Write-Host "`nNo .md files found." -ForegroundColor Yellow
    exit 0
}

Write-Ok "Found $($mdFiles.Count) file(s)."

# ---------------------------------------------------------------------------
# Resolve output directory
# ---------------------------------------------------------------------------

$useFixedOutDir = $OutDir -ne ""
if ($useFixedOutDir) {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    Write-Ok "Output directory: $OutDir"
}

# ---------------------------------------------------------------------------
# Embedded Python converter (written to a temp file, deleted after use)
# ---------------------------------------------------------------------------

$pyScript = @'
import pathlib
import re
import sys
from html.parser import HTMLParser

import markdown
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import (
  HRFlowable,
  Paragraph,
  Preformatted,
  SimpleDocTemplate,
  Spacer,
  Table,
  TableStyle,
)


def extract_title(md_text, fallback):
  match = re.search(r"^#\s+(.+?)\s*$", md_text, flags=re.MULTILINE)
  if match:
    return match.group(1).strip()
  return fallback


def make_styles():
  s = getSampleStyleSheet()

  s["Normal"].fontName = "Helvetica"
  s["Normal"].fontSize = 10.2
  s["Normal"].leading = 14.8
  s["Normal"].spaceAfter = 6
  s["Normal"].textColor = colors.HexColor("#1f2937")

  s["Code"].fontName = "Courier"
  s["Code"].fontSize = 8.6
  s["Code"].leading = 12.2
  s["Code"].leftIndent = 8
  s["Code"].spaceBefore = 6
  s["Code"].spaceAfter = 8
  s["Code"].backColor = colors.HexColor("#0f172a")
  s["Code"].textColor = colors.HexColor("#727274")

  heading_specs = [
    ("h1", 21, "Helvetica-Bold", 16, 8, "#0f2f56"),
    ("h2", 15, "Helvetica-Bold", 11, 6, "#143f70"),
    ("h3", 12, "Helvetica-Bold", 8, 4, "#1f4f84"),
    ("h4", 10.5, "Helvetica-BoldOblique", 6, 3, "#1f4f84"),
    ("h5", 10, "Helvetica-Bold", 5, 2, "#1f4f84"),
    ("h6", 10, "Helvetica-Oblique", 4, 2, "#1f4f84"),
  ]
  for alias, size, font, sb, sa, color in heading_specs:
    in_name = alias in s.byName
    in_alias = alias in getattr(s, "byAlias", {})
    if in_name or in_alias:
      style = s[alias]
      style.fontName = font
      style.fontSize = size
      style.spaceBefore = sb
      style.spaceAfter = sa
      style.leading = int(size * 1.25)
      style.textColor = colors.HexColor(color)
    else:
      s.add(
        ParagraphStyle(
          name=alias,
          parent=s["Normal"],
          fontName=font,
          fontSize=size,
          spaceBefore=sb,
          spaceAfter=sa,
          leading=int(size * 1.25),
          textColor=colors.HexColor(color),
        )
      )

  def safe_add(sheet, style):
    name = style.name
    if name not in sheet.byName and name not in getattr(sheet, "byAlias", {}):
      sheet.add(style)

  safe_add(
    s,
    ParagraphStyle(
      name="BulletItem",
      parent=s["Normal"],
      leftIndent=18,
      spaceAfter=2,
    ),
  )
  safe_add(
    s,
    ParagraphStyle(
      name="BlockQuote",
      parent=s["Normal"],
      leftIndent=20,
      borderPadding=6,
      backColor=colors.HexColor("#f2f6fb"),
      textColor=colors.HexColor("#334155"),
    ),
  )

  return s


def xesc(text):
  return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def safe_para(text, style):
  text = (text or "").strip()
  if not text:
    return None
  try:
    return Paragraph(text, style)
  except Exception:
    return Paragraph(xesc(re.sub(r"<[^>]+>", "", text)), style)


class MDParser(HTMLParser):
  def __init__(self, styles, page_width):
    super().__init__(convert_charrefs=True)
    self.st = styles
    self.pw = page_width
    self.out = []

    self.tags = []
    self.buf = ""

    self.in_pre = False
    self.pre_buf = ""

    self.lists = []
    self.li_buf = ""

    self.in_table = False
    self.t_rows = []
    self.t_cells = []
    self.cell_buf = ""

    self.bq = 0

  def _write(self, markup):
    if self.in_pre:
      return
    if self.in_table:
      self.cell_buf += markup
    elif self.lists and "li" in self.tags:
      self.li_buf += markup
    else:
      self.buf += markup

  def _pop_buf(self):
    text = self.buf.strip()
    self.buf = ""
    return text

  def _emit(self, flowable):
    if flowable is not None:
      self.out.append(flowable)

  def _emit_para(self, text, style_name):
    paragraph = safe_para(text, self.st[style_name])
    self._emit(paragraph)
    self._emit(Spacer(1, 2))

  def handle_starttag(self, tag, attrs):
    self.tags.append(tag)
    ad = dict(attrs)

    if tag == "pre":
      self.in_pre = True
      self.pre_buf = ""
    elif tag == "table":
      self.in_table = True
      self.t_rows = []
    elif tag == "tr":
      self.t_cells = []
    elif tag in ("td", "th"):
      self.cell_buf = ""
    elif tag in ("ul", "ol"):
      self.lists.append({"type": tag, "items": [], "n": 1})
    elif tag == "li":
      self.li_buf = ""
    elif tag == "blockquote":
      self.bq += 1
    elif tag == "hr":
      self.tags.pop()
      self._emit(
        HRFlowable(
          width="100%",
          thickness=1.0,
          color=colors.HexColor("#c9d5e4"),
        )
      )
      self._emit(Spacer(1, 6))
    elif tag in ("strong", "b"):
      self._write("<b>")
    elif tag in ("em", "i"):
      self._write("<i>")
    elif tag == "code" and not self.in_pre:
      self._write('<font name="Courier" size="8.8">')
    elif tag == "a":
      href = xesc(ad.get("href", ""))
      self._write(f'<link href="{href}" color="#1d4e89">')
    elif tag == "br":
      self._write("<br/>")

  def handle_endtag(self, tag):
    if self.tags and self.tags[-1] == tag:
      self.tags.pop()

    if tag == "pre":
      self.in_pre = False
      self._emit(Preformatted(self.pre_buf.rstrip("\n"), self.st["Code"]))
      self._emit(Spacer(1, 6))
      self.pre_buf = ""
    elif tag in ("h1", "h2", "h3", "h4", "h5", "h6"):
      style_name = tag if tag in self.st.byName else "h3"
      self._emit_para(self._pop_buf(), style_name)
      if tag in ("h1", "h2"):
        self._emit(Spacer(1, 2))
    elif tag == "p":
      style_name = "BlockQuote" if self.bq else "Normal"
      self._emit_para(self._pop_buf(), style_name)
    elif tag == "li":
      text = self.li_buf.strip()
      self.li_buf = ""
      if self.lists:
        lst = self.lists[-1]
        lst["items"].append((lst["n"], text))
        lst["n"] += 1
    elif tag in ("ul", "ol"):
      if self.lists:
        lst = self.lists.pop()
        for num, item in lst["items"]:
          prefix = "&#8226;" if lst["type"] == "ul" else f"{num}."
          full = f"{prefix}&nbsp;&nbsp;{item}" if item else prefix
          paragraph = safe_para(full, self.st["BulletItem"])
          self._emit(paragraph)
        self._emit(Spacer(1, 4))
    elif tag == "blockquote":
      self.bq = max(0, self.bq - 1)
    elif tag in ("td", "th"):
      if self.in_table:
        self.t_cells.append((self.cell_buf.strip(), tag == "th"))
        self.cell_buf = ""
    elif tag == "tr":
      if self.in_table and self.t_cells:
        self.t_rows.append(list(self.t_cells))
        self.t_cells = []
    elif tag == "table":
      self.in_table = False
      self._emit_table(self.t_rows)
      self.t_rows = []
    elif tag in ("strong", "b"):
      self._write("</b>")
    elif tag in ("em", "i"):
      self._write("</i>")
    elif tag == "code" and not self.in_pre:
      self._write("</font>")
    elif tag == "a":
      self._write("</link>")

  def handle_data(self, data):
    if self.in_pre:
      self.pre_buf += data
      return
    if self.in_table:
      self.cell_buf += xesc(data)
      return
    if self.lists and "li" in self.tags:
      self.li_buf += xesc(data)
      return
    self.buf += xesc(data)

  def _emit_table(self, rows):
    if not rows:
      return

    col_count = max(len(r) for r in rows)
    col_w = (self.pw - 2 * inch) / col_count
    has_header = rows and all(is_th for _, is_th in rows[0])

    tdata = []
    for row in rows:
      cells = []
      for cell_text, _ in row:
        paragraph = safe_para(cell_text or "", self.st["Normal"])
        cells.append(paragraph or Paragraph("", self.st["Normal"]))
      while len(cells) < col_count:
        cells.append(Paragraph("", self.st["Normal"]))
      tdata.append(cells)

    table_style = TableStyle(
      [
        ("FONTSIZE", (0, 0), (-1, -1), 9.2),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#d0dae7")),
        (
          "ROWBACKGROUNDS",
          (0, 1),
          (-1, -1),
          [colors.white, colors.HexColor("#f7fbff")],
        ),
      ]
    )
    if has_header:
      table_style.add("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1f3b62"))
      table_style.add("TEXTCOLOR", (0, 0), (-1, 0), colors.white)
      table_style.add("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold")

    table = Table(tdata, colWidths=[col_w] * col_count)
    table.setStyle(table_style)
    self._emit(table)
    self._emit(Spacer(1, 10))


def draw_page_chrome(canvas, doc, title):
  canvas.saveState()

  page_width, page_height = doc.pagesize
  left = doc.leftMargin
  right = page_width - doc.rightMargin

  canvas.setStrokeColor(colors.HexColor("#1f3b62"))
  canvas.setLineWidth(0.8)
  canvas.line(left, page_height - 0.58 * inch, right, page_height - 0.58 * inch)

  canvas.setFillColor(colors.HexColor("#475569"))
  canvas.setFont("Helvetica", 8)
  canvas.drawString(left, page_height - 0.5 * inch, title[:90])
  canvas.drawRightString(right, 0.42 * inch, f"Page {canvas.getPageNumber()}")

  canvas.restoreState()


def convert(md_path_str, pdf_path_str):
  styles = make_styles()
  md_path = pathlib.Path(md_path_str)
  text = md_path.read_text(encoding="utf-8")
  title = extract_title(text, md_path.stem)

  html = markdown.markdown(
    text,
    extensions=["fenced_code", "tables", "attr_list", "sane_lists", "nl2br"],
  )

  parser = MDParser(styles, letter[0])
  parser.feed(html)
  parser.close()

  flowables = parser.out or [Paragraph("(empty document)", styles["Normal"])]

  doc = SimpleDocTemplate(
    pdf_path_str,
    pagesize=letter,
    rightMargin=0.85 * inch,
    leftMargin=0.85 * inch,
    topMargin=0.9 * inch,
    bottomMargin=0.7 * inch,
    title=title,
    author="Bash Lesson PDF Export",
  )

  def page_fn(c, d):
    draw_page_chrome(c, d, title)

  doc.build(flowables, onFirstPage=page_fn, onLaterPages=page_fn)


if __name__ == "__main__":
  try:
    convert(sys.argv[1], sys.argv[2])
  except Exception:
    import traceback

    traceback.print_exc()
    sys.exit(1)
'@

$tempPy = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.py'
Set-Content -Path $tempPy -Value $pyScript -Encoding UTF8

# ---------------------------------------------------------------------------
# Convert each file
# ---------------------------------------------------------------------------

Write-Step "Converting..."

$success = 0
$failure = 0

foreach ($file in $mdFiles) {
    if ($useFixedOutDir) {
        $pdfPath = Join-Path $OutDir ($file.BaseName + ".pdf")
    } else {
        $pdfPath = Join-Path $file.DirectoryName ($file.BaseName + ".pdf")
    }

    # Use Start-Process so stderr and exit code are captured reliably.
    $errFile = [System.IO.Path]::GetTempFileName()
    $outFile = [System.IO.Path]::GetTempFileName()
    try {
      $proc = Start-Process `
        -FilePath $pythonCmd.Source `
        -ArgumentList @("`"$tempPy`"", "`"$($file.FullName)`"", "`"$pdfPath`"") `
        -NoNewWindow -Wait -PassThru `
        -RedirectStandardError $errFile `
        -RedirectStandardOutput $outFile

      if ($proc.ExitCode -eq 0) {
            Write-Ok "$($file.Name)  ->  $(Split-Path $pdfPath -Leaf)"
            $success++
        } else {
            $errMsg = (Get-Content $errFile -Raw -ErrorAction SilentlyContinue) -replace "`r`n","`n"
            Write-Fail "$($file.Name) failed:`n$errMsg"
            $failure++
        }
    } catch {
        Write-Fail "$($file.Name) threw: $_"
        $failure++
    } finally {
        Remove-Item $errFile -Force -ErrorAction SilentlyContinue
      Remove-Item $outFile -Force -ErrorAction SilentlyContinue
    }
}

Remove-Item $tempPy -Force -ErrorAction SilentlyContinue

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "============================" -ForegroundColor Cyan
Write-Host "  Converted : $success"       -ForegroundColor Green
if ($failure -gt 0) {
    Write-Host "  Failed    : $failure"   -ForegroundColor Red
}
Write-Host "============================" -ForegroundColor Cyan
