#!/bin/bash

set -euo pipefail

usage() {
	cat <<'EOF'
Usage: ./proxmox_provision.sh --students N --template VMID [options]

Options:
  --start-vmid VMID        First VMID to allocate (default: 200)
  --base-ip A.B.C.D        First student IP (default: 10.50.0.10)
  --gateway IP             Default gateway (default: 10.50.0.1)
  --bridge BRIDGE          Network bridge (default: vmbr0)
  --student-prefix PREFIX  Username prefix (default: student)
  --snapshot NAME          Snapshot name used for reset mode (default: course-ready)
  --reset                  Roll existing VMs back to the snapshot instead of cloning
  --dry-run                Print commands without executing them
  -h, --help               Show this help message
EOF
}

require_command() {
	local command_name="$1"
	if ! command -v "$command_name" >/dev/null 2>&1; then
		echo "[ERROR] Missing required command: ${command_name}" >&2
		exit 1
	fi
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

run_cmd() {
	if [ "$DRY_RUN" = "true" ]; then
		echo "[dry-run] $*"
	else
		"$@"
	fi
}

random_password() {
	printf '%s%s%s%s' "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM"
}

STUDENT_COUNT=""
TEMPLATE_VMID=""
START_VMID=200
BASE_IP="10.50.0.10"
GATEWAY="10.50.0.1"
BRIDGE="vmbr0"
STUDENT_PREFIX="student"
SNAPSHOT_NAME="course-ready"
RESET_MODE="false"
DRY_RUN="false"

while [ "$#" -gt 0 ]; do
	case "$1" in
		--students)
			STUDENT_COUNT="$2"
			shift 2
			;;
		--template)
			TEMPLATE_VMID="$2"
			shift 2
			;;
		--start-vmid)
			START_VMID="$2"
			shift 2
			;;
		--base-ip)
			BASE_IP="$2"
			shift 2
			;;
		--gateway)
			GATEWAY="$2"
			shift 2
			;;
		--bridge)
			BRIDGE="$2"
			shift 2
			;;
		--student-prefix)
			STUDENT_PREFIX="$2"
			shift 2
			;;
		--snapshot)
			SNAPSHOT_NAME="$2"
			shift 2
			;;
		--reset)
			RESET_MODE="true"
			shift
			;;
		--dry-run)
			DRY_RUN="true"
			shift
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

if [ -z "${STUDENT_COUNT}" ] || [ -z "${TEMPLATE_VMID}" ]; then
	echo "[ERROR] --students and --template are required" >&2
	usage
	exit 1
fi

require_command qm

base_ip_int="$(ip_to_int "${BASE_IP}")"

for ((index=0; index<STUDENT_COUNT; index++)); do
	vmid=$((START_VMID + index))
	ip_address="$(int_to_ip $((base_ip_int + index)))"
	student_number="$(printf '%02d' $((index + 1)))"
	student_user="${STUDENT_PREFIX}${student_number}"
	student_password="$(random_password)"
	vm_name="${student_user}"

	if [ "${RESET_MODE}" = "true" ]; then
		echo "[+] Resetting ${vm_name} (${vmid}) to snapshot ${SNAPSHOT_NAME}"
		run_cmd qm rollback "${vmid}" "${SNAPSHOT_NAME}"
		run_cmd qm start "${vmid}"
		continue
	fi

	echo "[+] Creating ${vm_name} (${vmid}) at ${ip_address}"
	run_cmd qm clone "${TEMPLATE_VMID}" "${vmid}" --name "${vm_name}" --full true
	run_cmd qm set "${vmid}" --net0 "virtio,bridge=${BRIDGE}"
	run_cmd qm set "${vmid}" --ipconfig0 "ip=${ip_address}/24,gw=${GATEWAY}"
	run_cmd qm set "${vmid}" --ciuser "${student_user}"
	run_cmd qm set "${vmid}" --cipassword "${student_password}"
	run_cmd qm start "${vmid}"

	echo "    user: ${student_user}"
	echo "    pass: ${student_password}"
done

echo "[+] Provisioning complete"
