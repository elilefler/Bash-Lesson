# Instructor Teaching Guide

## Purpose

Use this guide to run the course with minimal friction and maximum student hands-on time.

## Session Flow (16 Hours)

| Module | Topic | Duration | Lab Outcome |
| --- | --- | --- | --- |
| 1 | Why Bash for Blue Team | 0.5 hr | Students understand investigation workflow |
| 2 | Terminal Fundamentals | 1.0 hr | Students can navigate and locate files |
| 3 | Working With Logs | 1.5 hr | Students can inspect large logs efficiently |
| 4 | Pipes and Redirection | 2.0 hr | Students chain commands to answer questions |
| 5 | Threat Hunting with `grep` | 2.0 hr | Students detect suspicious patterns quickly |
| 6 | Parsing with `awk` and `sed` | 3.0 hr | Students extract and transform evidence |
| 7 | Bash Scripting | 2.0 hr | Students build reusable mini-tools |
| 8 | Automation and Final Tool | 1.5 hr | Students produce `incident_analyzer.sh` |
| 9 | Final Investigation Build | 2.5 hr | Students complete full-case analysis |

## Instructor Pre-Class Checklist

1. Run `setup_bash_cyber_lab.sh` on a clean Linux/WSL environment.
2. Verify folder structure was created under `$HOME/bash-cyber-course`.
3. Verify logs exist in `logs/` and contain both noise and attack artifacts.
4. Verify `tools/attack_simulator.sh` runs and appends to `logs/live_auth.log`.
5. Verify `final_project/incident_analyzer.sh` runs against generated logs.
6. Print or share `docs/STUDENT_LAB_WORKBOOK.md`.

## Teaching Method Per Module

For each module:

1. Demonstrate one operational question.
2. Show one working command or pipeline.
3. Give students a short lab task.
4. Debrief with one efficient reference solution.

Keep lecture segments to 10-15 minutes max before switching to hands-on work.

## Operational Questions to Reuse

- Who is the top source of failed logins?
- Was a password eventually accepted?
- What user appears compromised?
- What command indicates malware download?
- Is there evidence of persistence?
- What is the event sequence over time?

## Golden Pipelines

```bash
grep "Failed password" auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
grep "Accepted password" auth.log
grep -E "Failed password|Accepted password" auth.log
grep "wget" bash_history.log
grep "cron|CRON" syslog
grep "/dev/tcp" bash_history.log
grep "backup.zip" access.log
```

## Assessment Rubric (Simple)

Score each student or team on:

- correctness of findings
- command efficiency
- pipeline quality
- script reliability
- explanation clarity

Pass benchmark:

- identifies attacker IP
- identifies compromised user
- identifies suspicious command
- reconstructs basic timeline
- runs final script successfully

## Common Student Failure Points

1. Wrong field extraction in `awk` due to log format differences.
2. Missing quotes in grep patterns with spaces.
3. Sorting not applied before `uniq -c`.
4. Confusion between shell history and system logs.
5. Forgetting executable permission on scripts.

## Quick Remediation Steps

- Have students print 3-5 sample lines before parsing.
- Use `awk '{print NF, $0}'` to inspect field counts.
- Reinforce `sort | uniq -c | sort -nr` pattern.
- Encourage iterative validation after every pipeline stage.

## Final Debrief Talking Points

- Manual log reading does not scale in incident response.
- Pipelines create repeatable, auditable workflows.
- Scripted investigations improve speed and consistency.
- The same method applies to SOC operations and triage tasks.
