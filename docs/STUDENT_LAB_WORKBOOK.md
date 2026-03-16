# Student Lab Workbook - Bash for Blue-Team Investigation

## Lab Rules

- Work in the generated course directory: `$HOME/bash-cyber-course`.
- Run commands exactly as shown before modifying them.
- Ask for help early if a command fails.
- Save useful commands in your history.
- Validate your answer with at least one command output.

## Lab 1 - First Terminal Commands

Goal: get comfortable typing into the terminal.

Tasks:

1. Run `whoami`.
2. Run `date`.
3. Clear your screen with `clear`.
4. Open help for `ls` with `man ls` or `ls --help`.

Starter commands:

```bash
whoami
date
clear
ls --help
```

Record findings:

- Username: `________________`
- One thing `ls` can do: `________________`

## Lab 2 - Navigation and Filesystem

Goal: move around Linux without getting lost.

Tasks:

1. Print your current path.
2. Enter `logs/` and return to parent.
3. List hidden files.
4. Find all `.log` files.

Starter commands:

```bash
pwd
cd logs
cd ..
ls -la
find . -name "*.log"
```

Record findings:

- Current directory: `________________`
- Number of `.log` files: `________________`

## Lab 3 - Reading Log Files

Goal: inspect large files safely.

Tasks:

1. Show first 5 lines of `auth.log`.
2. Show last 5 lines of `syslog`.
3. Count lines in `access.log`.
4. Open `auth.log` in `less`.

Starter commands:

```bash
head -n 5 logs/auth.log
tail -n 5 logs/syslog
wc -l logs/access.log
less logs/auth.log
```

Record findings:

- `access.log` line count: `________________`

## Lab 4 - Detect Brute Force

Goal: identify repeated failed login attempts.

Tasks:

1. Find failed password attempts in `auth.log`.
2. Count total failed attempts.
3. Find one successful login event.

Starter commands:

```bash
grep "Failed password" logs/auth.log | head
grep -c "Failed password" logs/auth.log
grep "Accepted password" logs/auth.log
```

Record findings:

- Total failed attempts: `________________`
- Successful login present: `yes / no`

## Lab 5 - Identify Attacker IP

Goal: find the most frequent attacker IP.

Tasks:

1. Extract source IPs from failed logins.
2. Count each unique IP.
3. Sort from highest to lowest.

Starter pipeline:

```bash
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr | head
```

Record findings:

- Top attacker IP: `________________`
- Attempt count: `________________`

## Lab 6 - Malware and Persistence Discovery

Goal: find suspicious commands and persistence evidence.

Tasks:

1. Search command history for download activity.
2. Search command history for reverse shell activity.
3. Search syslog for cron persistence clues.

Starter commands:

```bash
grep -E "wget|curl" logs/bash_history.log
grep "/dev/tcp" logs/bash_history.log
grep -i "cron" logs/syslog
```

Record findings:

- Suspicious download command: `________________`
- Persistence clue: `________________`

## Lab 7 - Attack Timeline Reconstruction

Goal: reconstruct attacker behavior in order.

Tasks:

1. Extract failed and accepted logins.
2. Extract suspicious command history entries.
3. Extract persistence/outbound connection events.
4. Write a 5-step timeline.

Starter commands:

```bash
grep -E "Failed password|Accepted password|session opened" logs/auth.log
grep -E "wget|payload|/dev/tcp|history -c" logs/bash_history.log
grep -E "CRON|outbound connection|history cleared" logs/syslog
```

Timeline (5 lines):

1. `________________`
2. `________________`
3. `________________`
4. `________________`
5. `________________`

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
./final_project/incident_analyzer.sh logs/access.log --suspicious-downloads
```

## Submission Template

- Top attacker IP:
- Compromised user:
- Malware command:
- Persistence indicator:
- Timeline summary (5 lines):

## Stretch Challenges

1. Modify your pipeline to show top 5 attacker IPs only.
2. Build a command that outputs only failed attempts for user `admin`.
3. Find all references to one attacker IP across all logs.

Example:

```bash
grep -r "185.220.101.4" logs/
```
