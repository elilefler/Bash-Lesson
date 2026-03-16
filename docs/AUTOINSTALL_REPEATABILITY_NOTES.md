# Autoinstall Repeatability Notes

## Short Answer

Proxmox snapshots are the primary repeatability mechanism for this course.

`autoinstall.yaml` is now an optional fallback for single-VM provisioning and image rebuild workflows.

## Primary Repeatability Path

Use Proxmox for classroom delivery:

1. Build a clean Ubuntu 24.04 template VM.
2. Run `infra/proxmox/per_vm_setup.sh` inside a clone.
3. Validate logs and course files.
4. Create a baseline snapshot (for example `course-ready`).
5. Clone or reset all student VMs from that snapshot.

This gives faster and more predictable classroom resets than reinstalling each VM.

## Where `autoinstall.yaml` Still Helps

- building the initial Ubuntu template VM
- rebuilding a broken template image
- small environments that do not yet use full Proxmox automation

## What `autoinstall.yaml` Does Not Replace

Even with autoinstall, you still need to run course setup to generate logs and lab assets:

```bash
./setup_bash_cyber_lab.sh
```

## Recommended Repeatability Stack

1. Template layer: Ubuntu 24.04 build (`infra/autoinstall.yaml` optional)
2. Course layer: `setup_bash_cyber_lab.sh` or `infra/proxmox/per_vm_setup.sh`
3. Snapshot layer: Proxmox baseline snapshot for reset
4. Validation layer: `docs/QA_QC_REVIEW_CHECKLIST.md`
