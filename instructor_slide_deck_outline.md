# Instructor Slide Deck Outline (Beginner-First, ~16 Hours)

Design intent: assume students know nothing. Teach slowly, check often, and connect every command to an investigation question.

## Topic 0 - Orientation (45 min)

### Objective

Define cybersecurity terms and remove fear before terminal work.

### Slides

- what blue team work is
- what Linux is
- what terminal and shell mean
- class map from zero to final tool

### Checkpoint

- students can explain Linux and terminal in plain language

## Topic 1 - First Contact With Terminal (1.5 hr)

### Objective

Students can run basic commands and recover from mistakes.

### Commands

```bash
whoami
date
clear
man ls
ls --help
```

### Teaching notes

- show where to type
- normalize errors
- show `Ctrl+C`

### Checkpoint

- all students run `whoami` and `date` successfully

## Topic 2 - Linux Is Organized (1.5 hr)

### Objective

Students can navigate directories and understand paths.

### Commands

```bash
pwd
ls
ls -la
cd
find
```

### Concepts

- current directory
- home directory
- relative vs absolute paths
- where logs live (`/var/log`, course `logs/`)

### Checkpoint

- each student enters `logs/` and returns to parent

## Topic 3 - Reading Files (1.5 hr)

### Objective

Students can inspect large logs safely.

### Commands

```bash
cat
head
tail
wc -l
less
```

### Checkpoint

- each student opens `logs/auth.log` in `less` and exits with `q`

## Topic 4 - Finding What Matters (2 hr)

### Objective

Students can locate suspicious patterns with `grep`.

### Commands

```bash
grep "Failed password" logs/auth.log
grep -i "cron" logs/syslog
grep -c "Failed password" logs/auth.log
grep -E "Failed password|Accepted password" logs/auth.log
grep -n "Accepted password" logs/auth.log
```

### Checkpoint

- each student finds at least one failed and one accepted login event

## Topic 5 - Pipelines and Redirection (1.5 hr)

### Objective

Students understand command chaining.

### Operators

```bash
|
>
>>
```

### Demo pipeline

```bash
grep "Failed password" logs/auth.log | wc -l
```

### Checkpoint

- each student explains what each side of `|` is doing

## Topic 6 - Pulling Data Out (2 hr)

### Objective

Students extract fields and rank attacker IPs.

### Commands

```bash
cut -d' ' -f1 logs/access.log | head
grep "Failed password" logs/auth.log | awk '{print $11}'
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

### Checkpoint

- each student identifies the top attacker IP

## Topic 7 - Threat Hunting Labs (1.5 hr)

### Objective

Students complete full manual investigations without scripting.

### Required findings

- top attacker IP
- compromised account
- suspicious download
- persistence indicator
- timeline events

## Topic 8 - Writing Scripts (1.5 hr)

### Objective

Students automate repeated workflows.

### Commands and concepts

```bash
nano tools/my_investigator.sh
chmod +x tools/my_investigator.sh
./tools/my_investigator.sh logs/auth.log
```

- shebang
- variables
- `$1` arguments
- `if/else`
- simple loops

## Topic 9 - Building the Final Tool (2 hr)

### Objective

Students assemble and use `incident_analyzer.sh`.

### Required modes

```bash
./incident_analyzer.sh logs/auth.log --summary
./incident_analyzer.sh logs/auth.log --top-ips
./incident_analyzer.sh logs/auth.log --timeline
./incident_analyzer.sh logs/access.log --suspicious-downloads
```

### Checkpoint

- students can explain findings, not just run commands

## Timing Summary

| Topic | Duration |
| --- | --- |
| 0 | 0.75 hr |
| 1 | 1.5 hr |
| 2 | 1.5 hr |
| 3 | 1.5 hr |
| 4 | 2.0 hr |
| 5 | 1.5 hr |
| 6 | 2.0 hr |
| 7 | 1.5 hr |
| 8 | 1.5 hr |
| 9 | 2.0 hr |

Total: 16.25 hours.
