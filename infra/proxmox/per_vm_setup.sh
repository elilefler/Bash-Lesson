#!/bin/bash

set -euo pipefail

COURSE_URL="${COURSE_URL:-https://autodeploy.leflr.com/Bash-Lesson.tar.gz}"
COURSE_ROOT="${COURSE_ROOT:-/opt/bash-cyber-course-src}"
STUDENT_USER="${STUDENT_USER:-student}"
STUDENT_HOME="$(getent passwd "${STUDENT_USER}" | cut -d: -f6)"
WORK_DIR="${STUDENT_HOME}/bash-cyber-course"

if [ -z "${STUDENT_HOME}" ]; then
	echo "[ERROR] Could not resolve home directory for ${STUDENT_USER}" >&2
	exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
	echo "[ERROR] curl is required" >&2
	exit 1
fi

TMP_TARBALL="$(mktemp /tmp/bash-cyber-course.XXXXXX.tar.gz)"
cleanup() {
	rm -f "${TMP_TARBALL}"
}
trap cleanup EXIT

echo "[+] Downloading student course bundle"
curl -fsSL "${COURSE_URL}" -o "${TMP_TARBALL}"

echo "[+] Extracting bundle into ${COURSE_ROOT}"
rm -rf "${COURSE_ROOT}"
mkdir -p "${COURSE_ROOT}"
tar -xzf "${TMP_TARBALL}" -C "${COURSE_ROOT}"

chown -R "${STUDENT_USER}:${STUDENT_USER}" "${COURSE_ROOT}"
chmod +x "${COURSE_ROOT}/setup_bash_cyber_lab.sh"

echo "[+] Building student workspace in ${WORK_DIR}"
runuser -u "${STUDENT_USER}" -- bash -lc "cd '${COURSE_ROOT}' && ./setup_bash_cyber_lab.sh"

echo "[+] Student VM setup complete"
echo "[+] Student login: ${STUDENT_USER}"
echo "[+] Workspace: ${WORK_DIR}"
