# QA/QC Review Checklist - Bash Cyber Lab

Use this checklist to verify course quality before classroom delivery.

## 1. Documentation Quality

- [ ] Course intent is explicit and aligned to SOC/blue-team outcomes.
- [ ] Learning stages are clearly defined (terminal, investigation, automation).
- [ ] Lesson sequence is coherent and progressive.
- [ ] Labs map directly to taught commands.
- [ ] Final deliverable requirements are unambiguous.

## 2. Environment Setup Validation

- [ ] `setup_bash_cyber_lab.sh` runs on Linux and WSL.
- [ ] Required folders are created under `$HOME/bash-cyber-course`.
- [ ] Logs are generated with enough volume to require pipelines.
- [ ] Attack artifacts are embedded and discoverable.
- [ ] Setup script exits with helpful errors when dependencies are missing.

## 3. Dataset Realism and Consistency

- [ ] `auth.log` includes failed and accepted logins.
- [ ] `access.log` includes suspicious resource access (for example `backup.zip`).
- [ ] `bash_history.log` contains suspicious commands (`wget`, payload execution, reverse shell).
- [ ] `syslog` contains persistence and outbound connection indicators.
- [ ] Timestamps across logs are internally consistent enough for timeline exercises.

## 4. Tooling Validation

- [ ] `tools/attack_simulator.sh` runs and appends realistic events.
- [ ] `advanced_breach_generator.sh` creates full scenario logs.
- [ ] `final_project/incident_analyzer.sh` supports required options.
- [ ] Scripts include usage messages and basic argument validation.
- [ ] Scripts are executable and use `#!/bin/bash` shebang.

## 5. Pedagogical Validation

- [ ] Every module ends with a short applied investigation task.
- [ ] Command examples are copy-paste safe.
- [ ] Student tasks produce deterministic key findings.
- [ ] Workload is reasonable for novice Linux learners.
- [ ] Final lab requires combining multiple tools and logs.

## 6. Reproducibility and Delivery

- [ ] Fresh setup produces same core attack findings each run.
- [ ] Instructor can complete key labs within allocated time.
- [ ] All required files are self-contained in repository.
- [ ] README and docs point to correct paths and scripts.
- [ ] No hidden prerequisites beyond standard Bash utilities.

## 7. Sign-Off Record

Reviewer name:

Date:

Environment tested (WSL distro / Linux distro):

Overall status: Pass / Needs fixes

Notes:
