# Autoinstall Repeatability Notes

## Short Answer

Yes, an `autoinstall.yaml` helps repeatability when your class uses Ubuntu VMs.

It gives you deterministic base OS provisioning so every student starts from the same baseline image and package set.

## When It Helps Most

- You run classes in Ubuntu Server VMs.
- You repeatedly rebuild training machines.
- You need consistent usernames, packages, and base settings.
- You want lower setup drift between cohorts.

## When It Helps Less

- Your class primarily runs in WSL.
- Students use mixed distributions without a common VM image.
- You cannot control installation media/boot process.

## What It Does Not Replace

`autoinstall.yaml` prepares the OS, but you still need to run the lab setup script:

```bash
./setup_bash_cyber_lab.sh
```

That script creates logs, tools, labs, and final project artifacts used in class.

## Recommended Repeatability Stack

1. Base image layer: `infra/autoinstall.yaml` (Ubuntu VM provisioning)
2. Course layer: `setup_bash_cyber_lab.sh` (content and datasets)
3. Validation layer: `docs/QA_QC_REVIEW_CHECKLIST.md`

## Optional Improvement

If you want fully unattended course prep, add a cloud-init or post-install hook that:

1. pulls this repository
2. runs `setup_bash_cyber_lab.sh`
3. verifies key files exist
