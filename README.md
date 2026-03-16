# Bash for Blue-Team Investigation Course Kit

This repository contains a beginner-first Bash course for cybersecurity students who start with no Linux or terminal experience. The course builds from basic system orientation to practical blue-team log analysis and finishes with a student investigation script.

## Primary Delivery Model

The primary deployment target is a centralized Proxmox classroom environment:

```text
Classroom Network: 10.50.0.0/24

10.50.0.1   Router
10.50.0.2   Proxmox Host
10.50.0.3   Instructor Control VM
10.50.0.5   Attack Simulator VM
10.50.0.10+ Student VMs
```

Students connect over the classroom network with SSH:

```bash
ssh student01@10.50.0.10
```

Use the Proxmox tooling in `infra/proxmox/` for bulk VM creation, per-VM setup, and instructor SSH convenience.

## What This Includes

- `setup_bash_cyber_lab.sh`: one-command student environment setup
- `advanced_breach_generator.sh`: breach dataset generator with `--tier` sizing
- `bash_cybersecurity_teaching_notes.md`: instructor quick-reference notes
- `instructor_slide_deck_outline.md`: beginner-first lesson and slide outline
- `docs/COURSE_IMPLEMENTATION_GUIDE.md`: course architecture and teaching sequence
- `docs/INSTRUCTOR_TEACHING_GUIDE.md`: delivery and facilitation guide
- `docs/INSTRUCTOR_LESSON_PRIMER_LINUX_FIRST.md`: instructor self-study guide
- `docs/STUDENT_LAB_WORKBOOK.md`: student labs from first commands to final tool
- `docs/LAB_FINDINGS_ANSWER_KEY.md`: instructor answer key and expected findings
- `docs/QA_QC_REVIEW_CHECKLIST.md`: classroom readiness checklist
- `docs/DELIVERY_RUNBOOK.md`: day-of classroom execution runbook
- `docs/AUTOINSTALL_REPEATABILITY_NOTES.md`: Proxmox-first repeatability notes
- `infra/proxmox/`: Proxmox provisioning and classroom helper scripts
- `infra/autoinstall.yaml`: optional single-VM Ubuntu baseline file
- `infra/cloudflare-pages/`: optional fallback hosting for NoCloud autoinstall files

## Student Outcome

By the end of the course, students should be able to:

- explain what Linux, the shell, and the terminal are
- navigate directories and inspect files without getting lost
- search large logs with `grep`
- extract fields with `cut` and `awk`
- rank and summarize attacker activity with pipelines
- automate a repeatable investigation workflow in Bash

## Quick Start

Run setup inside a Linux VM or WSL instance:

```bash
chmod +x setup_bash_cyber_lab.sh
./setup_bash_cyber_lab.sh
```

Generated environment location:

```text
$HOME/bash-cyber-course
```

Generated paths:

```text
logs/
labs/
tools/
final_project/
```

Run the reference analyzer:

```bash
cd $HOME/bash-cyber-course
./final_project/incident_analyzer.sh logs/auth.log --summary
```

Run the live simulator:

```bash
cd $HOME/bash-cyber-course/tools
./attack_simulator.sh
```

## Tiered Dataset Sizes

Use the breach generator to match class scale and infrastructure limits:

```bash
./advanced_breach_generator.sh --tier intro
./advanced_breach_generator.sh --tier intermediate
./advanced_breach_generator.sh --tier advanced
./advanced_breach_generator.sh --tier final
```

Recommended use:

- `intro`: 10-20 MB for first grep and file-reading labs
- `intermediate`: 30-50 MB for pipeline practice
- `advanced`: 55-65 MB for threat hunting labs
- `final`: 70-80 MB for the final challenge

You can also write logs to a custom directory:

```bash
./advanced_breach_generator.sh /tmp/custom-cyber-logs --tier final
```

## Optional Cloudflare Fallback

Cloudflare Pages remains available as an optional fallback for Ubuntu autoinstall hosting when Proxmox is not the delivery path.

If you use it:

1. Connect this repo to Cloudflare Pages.
2. Set build command to empty.
3. Set build output directory to `infra/cloudflare-pages`.
4. Verify the deployed `user-data` and `meta-data` endpoints.

Installer kernel parameter:

```text
ds=nocloud-net;s=https://autodeploy.leflr.com/
```
