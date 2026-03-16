# Instructor Day-Of Quick Script

Keep this open during delivery. Follow it in order.

---

## Before Students Arrive

On Proxmox or the instructor control VM, verify:

```bash
./infra/proxmox/proxmox_provision.sh --students 20 --template 100 --dry-run
./infra/proxmox/ssh_config_gen.sh --students 20 | head
ssh student01@10.50.0.10 "whoami && pwd"
```

On a sample student VM, verify:

```bash
ls $HOME/bash-cyber-course/logs
$HOME/bash-cyber-course/final_project/incident_analyzer.sh $HOME/bash-cyber-course/logs/auth.log --summary
```

---

## Topic 0 Opener (15 min)

Say:

> "You do not need Linux experience for this class. We are going to start from zero. By the end, you will use simple commands to answer investigation questions that would be painful to do by hand."

Then define, in plain language:

- Linux = the operating system inside the VM
- terminal = the window where you type commands
- shell = the program inside the terminal that runs those commands
- blue team = the defenders investigating suspicious activity

Do not touch logs yet.

---

## Topic 1 | First Contact

Run live:

```bash
whoami
date
clear
ls --help
```

Checkpoint: every student successfully runs those commands.

If someone freezes on the prompt, stop and help them before advancing.

---

## Topic 2 | Navigation

Run live:

```bash
pwd
ls -la
cd logs
cd ..
find . -name "*.log"
```

Checkpoint: every student can move into `logs/` and back out.

---

## Topic 3 | Reading Files

Run live:

```bash
head -n 5 logs/auth.log
tail -n 5 logs/syslog
wc -l logs/access.log
less logs/auth.log
```

Say: "We inspect structure first. We do not manually read huge logs line by line."

---

## Topics 4-6 | Search, Pipe, Extract

Build this one stage at a time:

```bash
grep "Failed password" logs/auth.log
grep -c "Failed password" logs/auth.log
grep "Failed password" logs/auth.log | awk '{print $11}'
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

If output looks wrong, run:

```bash
awk '{print NF, $0}' logs/auth.log | head -n 3
```

Checkpoint: students can explain what each pipeline stage is doing.

---

## Topic 7 | Manual Hunt Lab

Students must find, without scripts:

- top attacker IP
- compromised account
- suspicious download command
- persistence indicator
- 5-step timeline

Use `docs/LAB_FINDINGS_ANSWER_KEY.md` to check results.

---

## Topic 8 | Scripting

Have students create a script in `nano`:

```bash
nano tools/my_investigator.sh
```

Starter content:

```bash
#!/bin/bash
LOGFILE=$1
if [ -z "$LOGFILE" ]; then
	echo "Usage: $0 logfile"
	exit 1
fi
grep "Failed password" "$LOGFILE" | awk '{print $11}' | sort | uniq -c | sort -nr
```

Then run:

```bash
chmod +x tools/my_investigator.sh
./tools/my_investigator.sh logs/auth.log
```

---

## Topic 9 | Final Build

Students run:

```bash
./final_project/incident_analyzer.sh logs/auth.log --summary
./final_project/incident_analyzer.sh logs/auth.log --top-ips
./final_project/incident_analyzer.sh logs/auth.log --timeline
./final_project/incident_analyzer.sh logs/access.log --suspicious-downloads
```

Expected answers live in `docs/LAB_FINDINGS_ANSWER_KEY.md`.

---

## If Something Breaks

| Problem | Fix |
| --- | --- |
| Student cannot log in | verify VM is running and re-test SSH from instructor VM |
| Student lost in filesystem | `pwd` then `cd $HOME/bash-cyber-course` |
| Script will not run | `chmod +x scriptname.sh` |
| Wrong `awk` field | `awk '{print NF, $0}'` to inspect |
| `uniq -c` counts look wrong | add `sort` before `uniq -c` |
| Student is scared to use `less` | remind them `q` quits |
| Logs missing | re-run `setup_bash_cyber_lab.sh` |
