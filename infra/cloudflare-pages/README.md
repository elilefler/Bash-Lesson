# Cloudflare Pages Autoinstall Payload (Optional Fallback)

This folder is deploy-ready for Cloudflare Pages, but it is now a fallback path.

Primary classroom model is Proxmox-based provisioning and snapshots.

## When to Use This

Use Cloudflare-hosted autoinstall files when:

- you are building or rebuilding a template Ubuntu VM
- Proxmox automation is not available yet
- you need quick NoCloud bootstrap delivery

## Files

- `user-data`: Ubuntu autoinstall cloud-init payload
- `meta-data`: NoCloud meta-data file
- `_headers`: plain-text content-type headers for installer compatibility

## Cloudflare Pages Settings

- Connect this repository in Pages.
- Build command: leave empty.
- Build output directory: `infra/cloudflare-pages`.
- Optional custom domain: `autodeploy.leflr.com`.

## Verify

After deploy, verify:

- `https://autodeploy.leflr.com/user-data`
- `https://autodeploy.leflr.com/meta-data`

## Installer Parameter

Use this kernel parameter in Ubuntu automated install:

```text
ds=nocloud-net;s=https://autodeploy.leflr.com/
```

## Proxmox Reminder

For day-of classroom operation, prefer:

- `infra/proxmox/proxmox_provision.sh`
- `infra/proxmox/per_vm_setup.sh`
- Proxmox snapshots for fast reset
