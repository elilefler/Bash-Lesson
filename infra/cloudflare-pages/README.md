# Cloudflare Pages Autoinstall Payload

This folder is deploy-ready for Cloudflare Pages.

## Files

- `user-data`: Ubuntu autoinstall cloud-init payload
- `meta-data`: NoCloud meta-data file
- `_headers`: forces plain-text content type for installer compatibility

## Cloudflare Pages Settings

- Connect this repository in Pages.
- Build command: leave empty.
- Build output directory: `infra/cloudflare-pages`.
- Add custom domain: `autodeploy.leflr.com`.

## Verify

After deploy, confirm these URLs load:

- `https://autodeploy.leflr.com/user-data`
- `https://autodeploy.leflr.com/meta-data`

## Installer Parameter

Use this kernel parameter in Ubuntu automated install:

```text
ds=nocloud-net;s=https://autodeploy.leflr.com/
```
