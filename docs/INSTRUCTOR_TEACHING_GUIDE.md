# Instructor Teaching Guide

## Purpose

Use this guide to teach the course at a deliberate pace for students who are starting from zero.

## Session Flow

| Topic | Duration | Primary Outcome |
| --- | --- | --- |
| 0. Orientation | 0.75 hr | Students understand the class vocabulary and purpose |
| 1. First Contact | 1.5 hr | Students can use the terminal without freezing |
| 2. Linux Is Organized | 1.5 hr | Students navigate confidently |
| 3. Reading Files | 1.5 hr | Students inspect logs safely |
| 4. Finding What Matters | 2.0 hr | Students search logs with `grep` |
| 5. Pipelines | 1.5 hr | Students understand chained commands |
| 6. Pulling Data Out | 2.0 hr | Students extract and rank indicators |
| 7. Threat Hunting Labs | 1.5 hr | Students complete manual investigations |
| 8. Writing Scripts | 1.5 hr | Students automate repeated work |
| 9. Building the Tool | 2.0 hr | Students complete `incident_analyzer.sh` |

## Instructor Pre-Class Checklist

1. Verify the Proxmox host, instructor VM, and student VMs are available.
2. Verify SSH access to sample student VMs.
3. Verify the folder structure exists under `$HOME/bash-cyber-course`.
4. Verify logs exist in `logs/` and contain both noise and attack artifacts.
5. Verify `tools/attack_simulator.sh` runs and appends to `logs/live_auth.log`.
6. Verify `final_project/incident_analyzer.sh` runs against generated logs.
7. Share or print `docs/STUDENT_LAB_WORKBOOK.md`.
8. Keep `docs/INSTRUCTOR_DAY_OF_QUICK_SCRIPT.md` open during class.

## Teaching Method Per Topic

For every topic:

1. name the operational question
2. demonstrate one command
3. have students run it immediately
4. confirm the room is caught up
5. add the next command only after the first one works

Keep lecture bursts short. Most beginner failures come from moving too fast, not from lack of intelligence.

## Coaching Notes for Topics 0 and 1

### Topic 0 - Orientation

Do not assume students know what Linux, the shell, or blue team means. Define each term in plain language and connect it directly to what they will do in class.

### Topic 1 - First Contact

Spend time on the prompt itself. Students often do not know where to type, what Enter does, or what happens after a command fails. Normalize errors immediately.

## Operational Questions to Reuse

- Who is failing to log in the most?
- Did the attacker ever succeed?
- Which user account appears compromised?
- What command downloaded malware?
- Is there evidence of persistence?
- What happened first, next, and last?

## Golden Pipelines

```bash
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
grep "Accepted password" logs/auth.log
grep -E "Failed password|Accepted password|session opened" logs/auth.log
grep -E "wget|curl" logs/bash_history.log
grep -i "cron" logs/syslog
grep "/dev/tcp" logs/bash_history.log
grep "backup.zip" logs/access.log
```

## Assessment Rubric

Score students or teams on:

- correctness of findings
- ability to explain what their commands do
- pipeline quality
- script reliability
- confidence using the terminal

Pass benchmark:

- identifies attacker IP
- identifies compromised user
- identifies suspicious command
- reconstructs a basic timeline
- runs the final script successfully

## Common Failure Points for Absolute Beginners

1. Not knowing where to type commands.
2. Fear of breaking the VM by making a mistake.
3. Confusion between terminal, shell, and operating system.
4. Confusion between current directory and file name.
5. Missing quotes in grep patterns with spaces.
6. Wrong field extraction in `awk`.
7. Forgetting `sort` before `uniq -c`.
8. Forgetting executable permission on scripts.
9. Fear of `less` because they do not know how to quit.

## Quick Remediation Steps

- Have students repeat the same small command together.
- Use `pwd` whenever someone feels lost.
- Use `awk '{print NF, $0}'` to inspect field counts before parsing.
- Reinforce `sort | uniq -c | sort -nr` as a reusable pattern.
- Remind students that `q` exits `less` and `Ctrl+C` stops a running command.

## Final Debrief Talking Points

- Manual log reading does not scale.
- Small Bash tools combine into fast investigations.
- Repetition is what makes pipelines usable under pressure.
- The final script is just the manual workflow written down once.
