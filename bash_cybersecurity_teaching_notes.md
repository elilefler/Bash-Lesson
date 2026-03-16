# Bash Cybersecurity Instructor Cheat Sheet

Quick reference for teaching Bash as a blue-team investigation tool.

## Topic 0 - Orientation Language

Use this wording with beginners:

- Linux: the operating system in the VM.
- Terminal: the window where commands are typed.
- Shell: the command interpreter inside the terminal.
- Blue team: defenders investigating suspicious activity.

## Topic 1 - First Commands

```bash
whoami
date
clear
man ls
ls --help
```

## Topic 2 - Navigation and Filesystem

```bash
pwd
ls
ls -la
cd logs
cd ..
find . -name "*.log"
history
```

## Topic 3 - Reading Logs Safely

```bash
cat logs/bash_history.log
head logs/auth.log
tail logs/auth.log
tail -f logs/live_auth.log
less logs/auth.log
wc -l logs/access.log
```

Useful `less` controls:

- `SPACE` scrolls down
- `/pattern` searches
- `n` jumps to next match
- `q` quits

## Topic 4 - Searching with grep

```bash
grep "Failed password" logs/auth.log
grep -c "Failed password" logs/auth.log
grep -n "Accepted password" logs/auth.log
grep -E "Failed|Accepted" logs/auth.log
grep -i "cron" logs/syslog
grep -r "wget" logs/
```

## Topic 5 - Pipelines

```bash
grep "Failed password" logs/auth.log | wc -l
grep "Failed password" logs/auth.log | awk '{print $11}'
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

Core reminder:

- one stage at a time
- validate output before adding the next stage

## Topic 6 - Data Extraction (`cut`, `awk`, `sort`, `uniq`)

Extract attacker IP from auth log:

```bash
grep "Failed password" logs/auth.log | awk '{print $11}'
```

Extract first field (client IP) from access log using `cut`:

```bash
cut -d' ' -f1 logs/access.log | head
```

Rank top attacking IPs:

```bash
grep "Failed password" logs/auth.log \
| awk '{print $11}' \
| sort \
| uniq -c \
| sort -nr
```

## Topic 7 - Threat Hunting Prompts

Use these questions:

- Who is failing to log in the most?
- Did any attempt succeed?
- What command downloaded malware?
- Is there persistence evidence?
- What order did events happen?

## Topic 8 - Scripting Essentials

Create files with `nano`:

```bash
nano tools/my_investigator.sh
```

Basic pattern with validation and `if/else`:

```bash
#!/bin/bash
LOGFILE=$1

if [ -z "$LOGFILE" ]; then
	echo "Usage: $0 logfile"
	exit 1
else
	grep "Failed password" "$LOGFILE" | awk '{print $11}' | sort | uniq -c | sort -nr
fi
```

Basic loop pattern:

```bash
for file in logs/*.log; do
	echo "Checking $file"
done
```

Execute script:

```bash
chmod +x tools/my_investigator.sh
./tools/my_investigator.sh logs/auth.log
```

## Topic 9 - Final Tool Checks

```bash
./final_project/incident_analyzer.sh logs/auth.log --summary
./final_project/incident_analyzer.sh logs/auth.log --top-ips
./final_project/incident_analyzer.sh logs/auth.log --timeline
./final_project/incident_analyzer.sh logs/access.log --suspicious-downloads
```

## Fast Debugging Aids

```bash
awk '{print NF, $0}' logs/auth.log | head -n 3
pwd
ls -l tools/my_investigator.sh
```

```bash
set -x
```

Stop script on error:

```bash
set -e
```

## Instructor "Golden Commands"

These pipelines should solve most investigation tasks.

Find attacker IP:

```bash
grep "Failed password" auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

Identify compromised account:

```bash
grep "Accepted password" auth.log
```

Find malware download:

```bash
grep wget bash_history.log
```

Detect persistence:

```bash
grep cron syslog
```

Detect reverse shell:

```bash
grep "/dev/tcp" bash_history.log
```

Identify stolen data:

```bash
grep backup access.log
```

## Recommended Teaching Flow

1. Start with basic navigation.
2. Introduce `grep` investigations.
3. Add `awk` extraction.
4. Combine tools into pipelines.
5. Transition into automation with scripts.

Goal: students move from manual log viewing to automated investigation pipelines.

## Core Teaching Message

Professional defenders rarely read logs manually.

They build repeatable pipelines that transform thousands of log lines into actionable intelligence.
