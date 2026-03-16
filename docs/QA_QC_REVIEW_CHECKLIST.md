# QA/QC Review Checklist - Bash Cyber Lab

Use this checklist to verify course quality before classroom delivery.

## 1. Documentation Quality

- [ ] Course intent is explicit and aligned to blue-team outcomes.
- [ ] 10-topic beginner-first progression is consistent across all instructor docs.
- [ ] Labs map directly to commands taught in sequence.
- [ ] Final deliverable requirements are clear and testable.
- [ ] Student workbook language is beginner-safe and step-based.

## 2. Proxmox Classroom Validation

- [ ] Proxmox host is reachable from instructor workstation.
- [ ] Student VMs boot cleanly.
- [ ] Student IP assignments match expected `10.50.0.10+` pattern.
- [ ] Instructor can SSH into sample student VMs.
- [ ] Snapshot reset process works for at least one student VM.

## 3. Student VM Setup Validation

- [ ] `infra/proxmox/per_vm_setup.sh` runs successfully on Ubuntu 24.04.
- [ ] Required folders are created under `$HOME/bash-cyber-course`.
- [ ] Logs and lab files are present after setup.
- [ ] `incident_analyzer.sh` is executable and runs.
- [ ] Setup exits with clear errors when prerequisites are missing.

## 4. Dataset Realism and Tier Validation

- [ ] `auth.log` includes failed and accepted logins.
- [ ] `access.log` includes suspicious resource access such as `backup.zip`.
- [ ] `bash_history.log` includes suspicious commands (`wget`, reverse shell, cleanup).
- [ ] `syslog` includes persistence and outbound connection indicators.
- [ ] Timestamps are coherent enough for timeline labs.
- [ ] `advanced_breach_generator.sh --tier intro` creates an intro-sized dataset.
- [ ] `advanced_breach_generator.sh --tier final` creates a final-sized dataset.

## 5. Tooling Validation

- [ ] `tools/attack_simulator.sh` appends realistic events.
- [ ] `advanced_breach_generator.sh` accepts `--tier` and validates bad options.
- [ ] `final_project/incident_analyzer.sh` supports required options.
- [ ] Proxmox helper scripts show usage output and basic validation.
- [ ] Scripts use `#!/bin/bash` shebang and execute cleanly.

## 6. Pedagogical Validation

- [ ] Topic 0 orientation is present before any Linux command work.
- [ ] Topic gates/checkpoints are documented and usable.
- [ ] Commands are copy-paste safe.
- [ ] Student tasks produce deterministic key findings.
- [ ] Workload is reasonable for absolute beginners.
- [ ] Final lab requires combining multiple logs and tools.

## 7. Reproducibility and Delivery

- [ ] Fresh setup produces same core findings each run.
- [ ] Instructor can complete all mandatory demos in available time.
- [ ] README and docs point to correct paths and scripts.
- [ ] Student release bundle excludes instructor-only files.
- [ ] No hidden prerequisites beyond standard Bash utilities and VM access.

## 8. Sign-Off Record

Reviewer name:

Date:

Environment tested (Proxmox version / Ubuntu image):

Overall status: Pass / Needs fixes

Notes:
