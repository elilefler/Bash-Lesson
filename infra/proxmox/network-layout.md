# Proxmox Classroom Network Layout

This course is designed to run on a local classroom network backed by a single Proxmox host.

## Reference Topology

```text
10.50.0.0/24 Classroom Network

10.50.0.1   Router / Default Gateway
10.50.0.2   Proxmox Host
10.50.0.3   Instructor Control VM
10.50.0.5   Attack Simulator VM
10.50.0.10  student01
10.50.0.11  student02
10.50.0.12  student03
...
10.50.0.29  student20
```

## Student Access Pattern

Students connect over SSH from instructor-provided terminals or their own classroom workstations:

```bash
ssh student01@10.50.0.10
ssh student02@10.50.0.11
```

Each student VM should run Ubuntu 24.04 LTS with Bash, core GNU utilities, and the course environment preinstalled.

## VM Roles

- Instructor Control VM: used to validate labs, monitor student progress, and stage demonstrations.
- Attack Simulator VM: optional VM for generating live traffic or coordinated attack demonstrations.
- Student VMs: isolated Linux environments with identical course content.

## Operational Notes

- Prefer wired networking if available. WiFi is workable but less predictable under concurrent SSH and log-analysis activity.
- Snapshot every student VM after baseline course setup completes.
- Use intro-tier logs for early labs and final-tier logs only for capstone work.
- Keep student IP allocation deterministic so troubleshooting is fast during class.
