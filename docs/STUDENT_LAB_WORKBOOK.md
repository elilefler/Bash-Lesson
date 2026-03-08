# Student Lab Workbook - Bash for Blue-Team Investigation

## Lab Rules

- Work in the generated course directory: `$HOME/bash-cyber-course`.
- Use command pipelines instead of manually reading full files.
- Save useful commands in your shell history for reuse.
- Validate your answer with at least one supporting command.

## Lab 1 - Terminal Navigation

Goal: become comfortable in Linux shell.

Tasks:

1. Print current directory.
2. List all files including hidden files.
3. Enter `logs/` and return to parent directory.
4. Find all `.log` files recursively.

Starter commands:

```bash
pwd
ls -la
cd logs
cd ..
find . -name "*.log"
```

## Lab 2 - Log Exploration

Goal: inspect large files efficiently.

Tasks:

1. Show first 5 lines of `auth.log`.
2. Show last 5 lines of `syslog`.
3. Count lines in `access.log`.
4. Search interactively inside `auth.log` using `less`.

Starter commands:

```bash
head -n 5 logs/auth.log
tail -n 5 logs/syslog
wc -l logs/access.log
less logs/auth.log
```

## Lab 3 - Detect Failed Logins

Goal: detect brute force evidence.

Tasks:

1. Find failed password attempts in `auth.log`.
2. Count total failed attempts.

Commands:

```bash
grep "Failed password" logs/auth.log
grep -c "Failed password" logs/auth.log
```

## Lab 4 - Identify Attacker IP

Goal: determine top attacker source IP.

Tasks:

1. Extract source IPs from failed password lines.
2. Count and rank attackers by frequency.

Pipeline:

```bash
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

Record answer:

- Top attacker IP: `________________`
- Number of failed attempts: `________________`

## Lab 5 - Malware Investigation

Goal: find suspicious commands and persistence indicators.

Tasks:

1. Search `bash_history.log` for malware download commands.
2. Search for reverse shell indicators.
3. Search `syslog` for scheduled persistence execution.

Commands:

```bash
grep "wget" logs/bash_history.log
grep "/dev/tcp" logs/bash_history.log
grep -i "cron" logs/syslog
```

## Lab 6 - Timeline Reconstruction

Goal: build sequence of compromise events.

Tasks:

1. Extract failed and accepted login events.
2. Correlate with suspicious commands from history and syslog.
3. Write a 5-step attack timeline.

Commands:

```bash
grep -E "Failed password|Accepted password" logs/auth.log
grep -E "wget|payload|history -c" logs/bash_history.log
grep -E "CRON|outbound connection|history cleared" logs/syslog
```

## Lab 7 - First Automation Script

Goal: automate one repeatable investigation.

Create `tools/my_investigator.sh`:

```bash
#!/bin/bash
LOGFILE=$1
grep "Failed password" "$LOGFILE" | awk '{print $11}' | sort | uniq -c | sort -nr
```

Run:

```bash
chmod +x tools/my_investigator.sh
./tools/my_investigator.sh logs/auth.log
```

## Lab 8 - Final Incident Investigation

Goal: complete full-case triage using `incident_analyzer.sh`.

Required outputs:

1. top attacker IP
2. compromised user
3. suspicious command tied to malware activity
4. likely persistence indicator
5. summarized timeline

Suggested commands:

```bash
./final_project/incident_analyzer.sh logs/auth.log --summary
./final_project/incident_analyzer.sh logs/auth.log --top-ips
./final_project/incident_analyzer.sh logs/auth.log --timeline
grep "wget" logs/bash_history.log
grep -i "cron" logs/syslog
```

## Submission Template

- Top attacker IP:
- Compromised user:
- Malware command:
- Persistence indicator:
- Timeline summary (5 lines):

## Stretch Challenges

1. Modify your pipeline to show top 5 attacker IPs.
2. Build a command that outputs only failed attempts for user `admin`.
3. Find all references to one attacker IP across all logs.

Example:

```bash
grep -r "185.220.101.4" logs/
```
