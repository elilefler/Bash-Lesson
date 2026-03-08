# Bash Cybersecurity Instructor Cheat Sheet

Quick-reference guide for instructors teaching Bash for **blue-team log investigation**.
Organized by **real investigative tasks** rather than tool categories.

---

## Core Concept to Reinforce

Linux investigation relies on **chaining simple tools**.

Example investigation pipeline:

```bash
grep "Failed password" auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

Breakdown:

| Tool | Purpose |
| --- | --- |
| `grep` | Find attack events |
| `awk` | Extract attacker IP |
| `sort` | Group identical values |
| `uniq` | Count occurrences |
| `sort -nr` | Show most frequent attacker |

## Navigation & Environment

Determine current working directory:

```bash
pwd
```

List directory contents:

```bash
ls
ls -la
```

Change directories:

```bash
cd directory
cd ..
cd ~
```

Locate files:

```bash
find . -name "*.log"
```

Show command history:

```bash
history
```

## Viewing Large Log Files

View beginning of file:

```bash
head auth.log
```

View end of file:

```bash
tail auth.log
```

Follow logs in real time:

```bash
tail -f auth.log
```

Scrollable log viewer:

```bash
less auth.log
```

Useful `less` controls:

| Key | Function |
| --- | --- |
| `SPACE` | Scroll down |
| `/pattern` | Search |
| `n` | Next match |
| `q` | Quit |

Count total lines:

```bash
wc -l auth.log
```

## Searching Logs with `grep`

Basic search:

```bash
grep "Failed password" auth.log
```

Case-insensitive search:

```bash
grep -i "error" syslog
```

Show line numbers:

```bash
grep -n "Accepted password" auth.log
```

Search multiple patterns:

```bash
grep -E "Failed|Accepted" auth.log
```

Recursive search:

```bash
grep -r "wget" .
```

Exclude patterns:

```bash
grep -v "session opened" auth.log
```

## Extracting Data with `awk`

Example log entry:

```text
Jul 10 09:15:02 server sshd[1423]: Failed password for root from 185.220.101.4 port 45512 ssh2
```

Extract attacker IP:

```bash
awk '{print $11}'
```

Extract timestamp:

```bash
awk '{print $1,$2,$3}'
```

Example pipeline:

```bash
grep "Failed password" auth.log | awk '{print $11}'
```

## Counting Attackers

Find top attacking IP addresses:

```bash
grep "Failed password" auth.log \
| awk '{print $11}' \
| sort \
| uniq -c \
| sort -nr
```

Example output:

```text
400 185.220.101.4
18 192.168.1.24
12 10.0.0.3
```

## Identifying Compromised Accounts

Find successful logins:

```bash
grep "Accepted password" auth.log
```

Extract username:

```bash
grep "Accepted password" auth.log | awk '{print $9}'
```

## Reconstructing Attack Timeline

Show failed and successful login attempts:

```bash
grep -E "Failed password|Accepted password" auth.log
```

Sort by time if necessary:

```bash
sort auth.log
```

## Malware Investigation

Search shell history:

```bash
grep "wget" bash_history.log
```

Search for executed scripts:

```bash
grep ".sh" bash_history.log
```

Look for reverse shell commands:

```bash
grep "/dev/tcp" bash_history.log
```

## Detecting Persistence

Search for cron jobs:

```bash
grep cron syslog
```

Example malicious persistence:

```text
* * * * * /tmp/payload.sh
```

## Web Log Investigation

Extract client IP addresses:

```bash
awk '{print $1}' access.log
```

Find top web clients:

```bash
awk '{print $1}' access.log | sort | uniq -c | sort -nr
```

Look for sensitive files:

```bash
grep backup.zip access.log
```

## Network Indicators

Search for suspicious outbound connections:

```bash
grep "connection" syslog
```

Search for known command-and-control IP:

```bash
grep "45.77.88.2" syslog
```

## Investigating an Attacker Across All Logs

Pivot across all logs:

```bash
grep -r "185.220.101.4" logs/
```

This reveals every artifact related to the attacker.

## Bash Script Basics

Simple analysis script:

```bash
#!/bin/bash

LOGFILE=$1

grep "Failed password" "$LOGFILE"
```

Make executable:

```bash
chmod +x script.sh
```

Run script:

```bash
./script.sh auth.log
```

## Debugging Scripts

Print commands during execution:

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
