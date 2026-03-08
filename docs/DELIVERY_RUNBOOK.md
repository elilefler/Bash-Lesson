# Delivery Runbook

## 1. Pre-Class (Instructor)

1. Prepare Linux VM or WSL environment.
2. Clone or copy this repository.
3. Run `./setup_bash_cyber_lab.sh`.
4. Validate generated logs and scripts.
5. Open the following documents:
   - `docs/INSTRUCTOR_TEACHING_GUIDE.md`
   - `docs/STUDENT_LAB_WORKBOOK.md`
   - `instructor_slide_deck_outline.md`

## 2. Classroom Startup (First 15 Minutes)

1. Explain course objective: investigation, not generic shell programming.
2. Have students run setup script.
3. Confirm each student has:
   - `logs/auth.log`
   - `logs/access.log`
   - `logs/bash_history.log`
   - `logs/syslog`
   - `final_project/incident_analyzer.sh`

## 3. Delivery Pattern Per Module

1. Present one operational question.
2. Demo one command/pipeline.
3. Give a short student lab task.
4. Debrief with one clear solution pipeline.

Keep lecture blocks short and practical.

## 4. Mid-Course Checkpoint

Ask students to demonstrate:

- extracting top attacker IP
- identifying successful compromise event
- finding suspicious `wget` or reverse-shell command

If needed, reteach command chaining:

```bash
grep ... | awk ... | sort | uniq -c | sort -nr
```

## 5. Final Project Execution

Students run:

```bash
cd $HOME/bash-cyber-course
./final_project/incident_analyzer.sh logs/auth.log --summary
./final_project/incident_analyzer.sh logs/auth.log --top-ips
./final_project/incident_analyzer.sh logs/auth.log --timeline
```

They then cross-check with:

```bash
grep "wget" logs/bash_history.log
grep -i "cron" logs/syslog
grep "backup.zip" logs/access.log
```

## 6. Assessment Completion Criteria

Student/team must correctly identify:

1. Top attacker IP
2. Compromised account
3. Malware-related command
4. At least one persistence indicator
5. A coherent attack timeline

## 7. Post-Class QC

1. Run `docs/QA_QC_REVIEW_CHECKLIST.md`.
2. Capture improvements for next cohort.
3. Archive student solutions and common failure patterns.
