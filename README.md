<<<<<<< HEAD
# Bash for Blue-Team Investigation Course Kit

This repository contains a complete training package for teaching Bash-driven cybersecurity investigation.

## What This Includes

- `setup_bash_cyber_lab.sh`: one-command environment setup for students
- `advanced_breach_generator.sh`: creates large, realistic breach datasets
- `bash_cybersecurity_teaching_notes.md`: instructor quick-reference cheat sheet
- `instructor_slide_deck_outline.md`: 16-hour slide and module outline
- `docs/COURSE_IMPLEMENTATION_GUIDE.md`: strategy and course architecture
- `docs/INSTRUCTOR_TEACHING_GUIDE.md`: delivery and facilitation guide
- `docs/STUDENT_LAB_WORKBOOK.md`: student lab tasks and submission template
- `docs/LAB_FINDINGS_ANSWER_KEY.md`: instructor answer key and expected findings
- `docs/QA_QC_REVIEW_CHECKLIST.md`: quality review checklist
- `docs/DELIVERY_RUNBOOK.md`: step-by-step classroom runbook
- `docs/AUTOINSTALL_REPEATABILITY_NOTES.md`: when and how to use Ubuntu autoinstall
- `infra/autoinstall.yaml`: optional Ubuntu VM baseline provisioning file
- `infra/cloudflare-pages/`: deploy-ready static files for NoCloud autoinstall (`user-data`, `meta-data`)

## Quick Start

Run setup in Linux or WSL:

```bash
chmod +x setup_bash_cyber_lab.sh
./setup_bash_cyber_lab.sh
```

Generated environment location:

```text
$HOME/bash-cyber-course
```

Key generated paths:

```text
logs/
labs/
tools/
final_project/
```

Run reference analyzer:

```bash
cd $HOME/bash-cyber-course
./final_project/incident_analyzer.sh logs/auth.log --summary
```

Run live simulator:

```bash
cd $HOME/bash-cyber-course/tools
./attack_simulator.sh
```

## Optional: Regenerate Advanced Dataset

```bash
chmod +x advanced_breach_generator.sh
./advanced_breach_generator.sh
```

Or write logs to a custom directory:

```bash
./advanced_breach_generator.sh /tmp/custom-cyber-logs
```

## Intended Student Outcome

Students should leave able to:

- investigate logs quickly with pipelines
- identify attacker artifacts
- reconstruct attack timelines
- automate repeatable investigations with Bash

## Cloudflare Pages Autoinstall Hosting

If you want Ubuntu autoinstall config hosted from GitHub through Cloudflare Pages:

1. Connect this repo to Cloudflare Pages.
2. Set build command to empty.
3. Set build output directory to `infra/cloudflare-pages`.
4. Attach custom domain `autodeploy.leflr.com`.
5. Verify:
	- `https://autodeploy.leflr.com/user-data`
	- `https://autodeploy.leflr.com/meta-data`

Installer kernel parameter:

```text
ds=nocloud-net;s=https://autodeploy.leflr.com/
```
=======
# Bash-Lesson
Bash-based blue-team investigation lab kit with automated environment setup, realistic breach log generation, student labs, instructor guides, QA/QC checklists, and deployable Ubuntu autoinstall assets for repeatable SOC-style training.
>>>>>>> 9bc12b19b1e5bd839aebffba70707cfd7c8b1d42
