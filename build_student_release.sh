#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${ROOT_DIR}/infra/cloudflare-pages"
OUT_TARBALL="${OUT_DIR}/Bash-Lesson.tar.gz"

# Only include files students need to run the lab and complete exercises.
INCLUDE_PATHS=(
  "README.md"
  "setup_bash_cyber_lab.sh"
  "advanced_breach_generator.sh"
  "docs/STUDENT_LAB_WORKBOOK.md"
)

# Safety filter in case future include paths accidentally pull instructor-only content.
EXCLUDE_NAME_REGEX='(slide|answer[_ -]?key|instructor|qa|qc|runbook|implementation|teaching_notes)'

require_file() {
  local rel_path="$1"
  local abs_path="${ROOT_DIR}/${rel_path}"
  if [ ! -f "$abs_path" ]; then
    echo "[ERROR] Required file missing: ${rel_path}" >&2
    exit 1
  fi
}

copy_allowed_file() {
  local rel_path="$1"
  local src="${ROOT_DIR}/${rel_path}"
  local dst="${STAGE_DIR}/${rel_path}"

  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

for rel in "${INCLUDE_PATHS[@]}"; do
  require_file "$rel"
done

STAGE_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$STAGE_DIR"
}
trap cleanup EXIT

echo "[+] Building student-only release payload..."

for rel in "${INCLUDE_PATHS[@]}"; do
  copy_allowed_file "$rel"
done

# Remove any accidentally included instructor-facing files by filename guard.
while IFS= read -r path; do
  rel_path="${path#${STAGE_DIR}/}"
  if echo "$rel_path" | grep -Eiq "$EXCLUDE_NAME_REGEX"; then
    echo "[!] Excluding by guard rule: ${rel_path}"
    rm -f "$path"
  fi
done < <(find "$STAGE_DIR" -type f)

mkdir -p "$OUT_DIR"
rm -f "$OUT_TARBALL"

(
  cd "$STAGE_DIR"
  tar -czf "$OUT_TARBALL" .
)

echo "[+] Wrote: ${OUT_TARBALL}"
echo "[+] Contents:"
tar -tzf "$OUT_TARBALL"
