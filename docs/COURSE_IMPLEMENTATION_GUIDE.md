# Bash for Blue-Team Investigation - Course Implementation Guide

## Strategic Intent

This course is designed for students who start with no Linux, no terminal, and little to no technical confidence. The course must therefore begin before Bash itself. Students first learn what Linux is, what a terminal is, and why defenders use command-line workflows. Only after that foundation is stable do they move into log analysis, pipelines, and scripting.

The course goal is not general Linux administration and not deep Bash programming. The goal is beginner-accessible blue-team investigation:

1. understand the working environment
2. inspect large files safely
3. find suspicious patterns in logs
4. extract fields and counts from evidence
5. reconstruct an attacker timeline
6. automate repeatable investigative tasks

## Final Deliverable

Students produce and use `incident_analyzer.sh`.

Expected capabilities:

- identify attacker IPs
- count brute-force attempts
- detect compromised accounts
- build attack timelines
- locate suspicious commands
- identify suspicious downloads

Example usage:

```bash
./incident_analyzer.sh auth.log --top-ips
./incident_analyzer.sh auth.log --timeline
./incident_analyzer.sh access.log --suspicious-downloads
```

## Teaching Philosophy

The course emphasizes practical confidence before speed.

Core principles:

- assume no prior knowledge
- explain one concept at a time
- keep commands short at first
- require students to repeat every new command immediately
- add checkpoints before moving to harder material
- frame every command around a real investigative question

Students should leave with the sense that Bash is a practical investigation tool, not an abstract programming language.

## Learning Progression

### Topic 0 - Orientation

Students learn what cybersecurity means in this class, what blue team work looks like, what Linux is, and what the terminal is.

Goal: remove the fear of unfamiliar words before any command is typed.

### Topic 1 - First Contact With the Terminal

Students learn how to open a terminal, read a prompt, run very small commands, recover from mistakes, and ask for help.

Core commands:

```bash
whoami
date
clear
man ls
ls --help
```

Goal: remove terminal anxiety.

### Topic 2 - Linux Is Organized

Students learn what files, directories, and paths are, how the home directory works, and where log data commonly lives.

Core commands:

```bash
pwd
ls
ls -la
cd
find
```

Goal: build navigation confidence.

### Topic 3 - Reading Files

Students learn to inspect large logs without dumping everything to the screen.

Core commands:

```bash
cat
head
tail
wc -l
less
```

Goal: teach safe file inspection.

### Topic 4 - Finding What Matters

Students begin threat hunting with `grep`.

Core patterns:

```bash
grep "Failed password" logs/auth.log
grep -c "Failed password" logs/auth.log
grep -i "cron" logs/syslog
grep -E "Failed password|Accepted password" logs/auth.log
```

Goal: teach students to find signal first.

### Topic 5 - Pipelines

Students learn to chain commands one step at a time.

Core concepts:

- `|` passes output from one command to the next
- `>` writes output to a file
- `>>` appends output to a file

Goal: build pipeline thinking without overwhelming them.

### Topic 6 - Pulling Data Out

Students extract fields and rank attacker activity.

Core tools:

```bash
cut
awk
sort
uniq -c
```

Example:

```bash
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

Goal: move from searching to analysis.

### Topic 7 - Threat Hunting Labs

Students complete manual investigations before automation.

Required findings:

- top attacker IP
- compromised account
- suspicious command
- persistence indicator
- timeline events

Goal: prove students can investigate manually before scripting.

### Topic 8 - Writing Scripts

Students learn only the scripting depth needed for the final tool.

Core skills:

- `nano` to create files
- shebangs
- `chmod +x`
- variables
- arguments such as `$1`
- `if/else`
- simple loops

Goal: turn repeated manual workflows into reusable commands.

### Topic 9 - Building the Tool

Students assemble `incident_analyzer.sh` using the same commands they already trust.

Goal: make the final deliverable feel like a natural extension of their workflow.

## 16-Hour Architecture

| Topic | Duration | Outcome |
| --- | --- | --- |
| 0. Orientation | 0.75 hr | Students understand class purpose and vocabulary |
| 1. First Contact | 1.5 hr | Students can type commands and recover from small mistakes |
| 2. Linux Is Organized | 1.5 hr | Students navigate confidently |
| 3. Reading Files | 1.5 hr | Students inspect large logs safely |
| 4. Finding What Matters | 2.0 hr | Students use `grep` to find suspicious events |
| 5. Pipelines | 1.5 hr | Students chain commands step by step |
| 6. Pulling Data Out | 2.0 hr | Students extract and rank indicators |
| 7. Threat Hunting Labs | 1.5 hr | Students complete manual investigations |
| 8. Writing Scripts | 1.5 hr | Students build small automation scripts |
| 9. Building the Tool | 2.0 hr | Students complete `incident_analyzer.sh` |

Total: about 16.25 hours.

## Hands-On Labs

1. First Terminal Commands
2. Navigation and Filesystem
3. Reading Log Files
4. Detect Brute Force
5. Identify Attacker IP
6. Malware and Persistence Discovery
7. Attack Timeline Reconstruction
8. Final Incident Investigation

## Infrastructure Model

Primary delivery model: centralized Proxmox host.

```text
10.50.0.1   Router
10.50.0.2   Proxmox Host
10.50.0.3   Instructor Control VM
10.50.0.5   Attack Simulator VM
10.50.0.10+ Student VMs
```

Students connect with SSH such as:

```bash
ssh student01@10.50.0.10
```

Supporting components:

- `setup_bash_cyber_lab.sh` for student workspace creation
- `advanced_breach_generator.sh --tier ...` for sized datasets
- `infra/proxmox/proxmox_provision.sh` for bulk VM provisioning
- `infra/proxmox/per_vm_setup.sh` for student VM initialization
- `infra/proxmox/ssh_config_gen.sh` for instructor SSH aliases

## Recommended Log Tiers

| Tier | Size | Best Use |
| --- | --- | --- |
| `intro` | 10-20 MB | first file-reading and grep labs |
| `intermediate` | 30-50 MB | pipeline practice |
| `advanced` | 55-65 MB | manual threat hunting |
| `final` | 70-80 MB | capstone challenge |

## Instructor Operating Model

Instructor responsibilities:

1. start or reset student VMs before class
2. confirm SSH access works for every student
3. keep students synchronized with checkpoints
4. reteach fundamentals before advancing when needed
5. evaluate both findings and method, not just final answers

## Student Outcomes

By course end, students can:

- explain what Linux, the shell, and the terminal are
- navigate a Linux system without getting lost
- inspect and search large logs effectively
- extract meaningful evidence with pipelines
- correlate attack artifacts across multiple sources
- automate a basic blue-team investigation workflow

These outcomes align directly with entry-level SOC investigation tasks.
