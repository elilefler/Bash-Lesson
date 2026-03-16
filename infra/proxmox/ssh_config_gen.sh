#!/bin/bash

set -euo pipefail

usage() {
	cat <<'EOF'
Usage: ./ssh_config_gen.sh [--students N] [--base-ip A.B.C.D] [--student-prefix PREFIX]
EOF
}

ip_to_int() {
	local ip="$1"
	local a b c d
	IFS=. read -r a b c d <<< "$ip"
	echo $(( (a << 24) + (b << 16) + (c << 8) + d ))
}

int_to_ip() {
	local value="$1"
	echo "$(( (value >> 24) & 255 )).$(( (value >> 16) & 255 )).$(( (value >> 8) & 255 )).$(( value & 255 ))"
}

STUDENT_COUNT=20
BASE_IP="10.50.0.10"
STUDENT_PREFIX="student"

while [ "$#" -gt 0 ]; do
	case "$1" in
		--students)
			STUDENT_COUNT="$2"
			shift 2
			;;
		--base-ip)
			BASE_IP="$2"
			shift 2
			;;
		--student-prefix)
			STUDENT_PREFIX="$2"
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "[ERROR] Unknown argument: $1" >&2
			usage
			exit 1
			;;
	esac
	done

base_ip_int="$(ip_to_int "${BASE_IP}")"

for ((index=0; index<STUDENT_COUNT; index++)); do
	student_number="$(printf '%02d' $((index + 1)))"
	host_name="${STUDENT_PREFIX}${student_number}"
	host_ip="$(int_to_ip $((base_ip_int + index)))"

	cat <<EOF
Host ${host_name}
    HostName ${host_ip}
    User ${host_name}
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

EOF
done
