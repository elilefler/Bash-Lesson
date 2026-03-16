# Delivery Runbook

## 1. Pre-Class (Instructor)

1. From the Proxmox host, provision or reset the student VMs.
2. Start the instructor control VM and the student VMs.
3. Test SSH access to at least three student VMs before students arrive.
4. Confirm the following files exist on a sample VM:
   - `logs/auth.log`
   - `logs/access.log`
   - `logs/bash_history.log`
   - `logs/syslog`
   - `final_project/incident_analyzer.sh`
5. Open these reference files:
   - `docs/INSTRUCTOR_DAY_OF_QUICK_SCRIPT.md`
   - `docs/INSTRUCTOR_TEACHING_GUIDE.md`
   - `docs/INSTRUCTOR_LESSON_PRIMER_LINUX_FIRST.md`
   - `docs/STUDENT_LAB_WORKBOOK.md`
   - `instructor_slide_deck_outline.md`

## 2. Classroom Startup (First 15 Minutes)

1. Explain the course map: orientation, first commands, log analysis, then scripting.
2. Give each student their SSH target and credentials.
3. Have every student log in and run:

```bash
whoami
pwd
ls
```

4. Do not continue until every student can see the prompt and run commands successfully.

## 3. Topic Gates

Use these go/no-go gates during delivery.

### Gate A - After Topic 1

Every student can:

- type `whoami`
- type `date`
- clear the screen
- ask for help with `man ls` or `ls --help`

### Gate B - After Topic 2

Every student can:

- use `pwd`
- move into `logs/` and back out
- list files with `ls -la`
- find `.log` files with `find`

### Gate C - After Topic 3

Every student can:

- use `head`
- use `tail`
- count lines with `wc -l`
- open a file in `less`

### Gate D - After Topics 4-6

Every student can:

- count failed logins
- extract attacker IPs
- build the ranked IP pipeline

If a gate is not met, reteach before advancing.

## 4. Delivery Pattern Per Topic

1. Introduce one operational question.
2. Demonstrate one command or one additional pipeline stage.
3. Have students repeat it immediately.
4. Check the room before adding the next command.
5. Debrief with one working example.

Keep explanations short. Let repetition do the work.

## 5. Log Tier Guidance

- Use `intro` tier for Topics 1-4.
- Use `intermediate` tier for Topics 5-6.
- Use `advanced` tier for Topic 7 manual hunts.
- Use `final` tier only for the capstone if the infrastructure is responsive.

## 6. Final Project Execution

Students run:

```bash
cd $HOME/bash-cyber-course
./final_project/incident_analyzer.sh logs/auth.log --summary
./final_project/incident_analyzer.sh logs/auth.log --top-ips
./final_project/incident_analyzer.sh logs/auth.log --timeline
./final_project/incident_analyzer.sh logs/access.log --suspicious-downloads
```

They then validate with manual checks such as:

```bash
grep "wget" logs/bash_history.log
grep -i "cron" logs/syslog
grep "backup.zip" logs/access.log
```

## 7. Assessment Completion Criteria

Student or team must correctly identify:

1. top attacker IP
2. compromised account
3. suspicious download or malware command
4. one persistence indicator
5. a coherent attack timeline

## 8. Reset Procedure

If the class needs a clean environment mid-course:

1. Have students log out.
2. On the Proxmox host, roll student VMs back to the baseline snapshot.
3. Start the VMs again.
4. Re-test SSH on two or three VMs before resuming.

## 9. Post-Class QC

1. Run `docs/QA_QC_REVIEW_CHECKLIST.md`.
2. Capture pacing problems and repeated confusion points.
3. Archive student solutions and notes for the next cohort.
