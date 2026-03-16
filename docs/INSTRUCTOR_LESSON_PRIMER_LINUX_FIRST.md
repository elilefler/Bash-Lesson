# Instructor Lesson Primer - Linux First Bash Cyber Class

## Purpose

Use this primer before teaching. It is a teach-through guide for an audience that starts from zero.

Course emphasis:

1. understand what environment students are inside
2. build comfort with the terminal
3. investigate logs with small, repeatable commands
4. automate those commands only after the manual workflow makes sense

## What Students Must Understand Before Scripting

Students should be able to explain and demonstrate:

- what Linux is in plain language
- what the terminal and shell are
- how paths and directories work
- how to inspect large logs safely
- how a pipeline reduces manual work

If they cannot do these, stop and reinforce fundamentals before scripting.

## 16-Hour Absolute-Beginner Teaching Flow

## Topic 0 - Orientation (45 min)

Teaching objective:

- remove fear of unfamiliar words

Teaching script:

- "Linux is the operating system inside the VM."
- "The terminal is the window where you type commands."
- "The shell is the program reading those commands."
- "Blue team means we are the defenders trying to understand what happened."

Use analogies if needed:

- operating system = the whole room
- terminal = the door you use to enter commands
- shell = the person inside the room receiving those commands

Do not start with logs. Start with vocabulary and confidence.

## Topic 1 - First Contact (1.5 hr)

Teaching objective:

- students can type into the terminal without panic

Demo commands:

```bash
whoami
date
clear
ls --help
```

Coaching notes:

- point at the prompt and show exactly where to type
- tell students that command failures are normal
- show `Ctrl+C` and explain that it stops a running command

Checkpoint questions:

- "Where do you type?"
- "How do you stop a command that is hanging?"

## Topic 2 - Linux Is Organized (1.5 hr)

Teaching objective:

- students can move through directories without getting lost

Demo commands:

```bash
pwd
ls -la
cd logs
cd ..
find . -name "*.log"
```

Common mistakes to watch:

- not understanding current directory
- confusing file names with directory names
- forgetting that `..` means parent directory

## Topic 3 - Reading Files (1.5 hr)

Teaching objective:

- students inspect large files safely

Demo commands:

```bash
cat logs/bash_history.log
head -n 5 logs/auth.log
tail -n 5 logs/syslog
wc -l logs/access.log
less logs/auth.log
```

Coaching notes:

- explain that `cat` is fine for small files but not for large logs
- tell students that `q` exits `less`

## Topic 4 - Finding What Matters (2.0 hr)

Teaching objective:

- students find suspicious events with `grep`

Demo commands:

```bash
grep "Failed password" logs/auth.log
grep -c "Failed password" logs/auth.log
grep -i "cron" logs/syslog
grep -E "Failed password|Accepted password" logs/auth.log
```

Coaching point:

- search first, analyze second

## Topic 5 - Pipelines (1.5 hr)

Teaching objective:

- students understand how one command feeds another

Build live:

```bash
grep "Failed password" logs/auth.log
grep "Failed password" logs/auth.log | wc -l
grep "Failed password" logs/auth.log | awk '{print $11}'
```

Coaching point:

- add only one new pipeline stage at a time

## Topic 6 - Pulling Data Out (2.0 hr)

Teaching objective:

- students extract fields and count indicators

Demo commands:

```bash
grep "Failed password" logs/auth.log | awk '{print $11}'
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
grep "Accepted password" logs/auth.log | awk '{print $9}'
```

Coaching point:

- validate every stage before adding the next stage

## Topic 7 - Guided Threat Hunting Lab (1.5 hr)

Teaching objective:

- students complete full manual triage before automation

Required findings:

- top attacker IP
- compromised user
- suspicious command
- persistence indicator
- timeline events

## Topic 8 - Writing Scripts (1.5 hr)

Teaching objective:

- students automate one repeated workflow with minimal scripting

Demo commands:

```bash
nano tools/my_investigator.sh
chmod +x tools/my_investigator.sh
./tools/my_investigator.sh logs/auth.log
```

Concepts to teach:

- `#!/bin/bash`
- `$1`
- variables
- `if/else`
- `for` loops

## Topic 9 - Final Investigation Build (2.0 hr)

Teaching objective:

- students integrate all prior work into final project output

Required commands:

```bash
./final_project/incident_analyzer.sh logs/auth.log --summary
./final_project/incident_analyzer.sh logs/auth.log --top-ips
./final_project/incident_analyzer.sh logs/auth.log --timeline
./final_project/incident_analyzer.sh logs/access.log --suspicious-downloads
```

## Instructor Rehearsal Plan

1. Run setup and verify all logs exist.
2. Run every command in this primer once.
3. Validate expected findings with `docs/LAB_FINDINGS_ANSWER_KEY.md`.
4. Practice the Topic 0 explanation out loud.
5. Practice the ranked attacker IP pipeline slowly, one stage at a time.

## High-Probability Student Confusion Points

- not knowing where to type at the prompt
- fear of breaking something
- confusion about current directory
- confusion about relative vs absolute paths
- missing quotes around multiword grep patterns
- extracting the wrong `awk` field
- forgetting `sort` before `uniq -c`
- not knowing how to exit `less`

Fast remediation commands:

```bash
pwd
awk '{print NF, $0}' logs/auth.log | head -n 3
ls -l tools/my_investigator.sh
```

## Success Standard

If students can confidently navigate Linux, inspect logs, and build a reliable investigation pipeline before scripting, they are on track.

Scripting should feel like a written version of a workflow they already trust.