# ucloud-sandbox-cli — verified facts

Source: official UCloud Agent Sandbox documentation and local measurements, verified 2026-09-29. Always re-check installed CLI help before using flags.

## Regions

| Region | Description | Domain |
|---|---|---|
| `cn-wlcb` | North China (Ulanqab) | `cn-wlcb.sandbox.ucloudai.com` |
| `cn-sh` | East China (Shanghai) | `cn-sh.sandbox.ucloudai.com` |
| `us-ca` | United States (Los Angeles) | `us-ca.sandbox.ucloudai.com` |

`us-la` does not exist; `us-ca` is the sole US region. Region data is isolated. Route each CLI process with `UCLOUD_SANDBOX_REGION=<region>`. Do not rewrite persisted config. The `region` subcommand is an interactive arrow-key picker and unsuitable for automation.

## Templates and desktop

Built-in templates include `code-interpreter-v1`, `desktop`, and `base`. Use `desktop` for GUI/browser tasks. It includes Chrome and `/opt/noVNC`, but the desktop stack does not auto-start. Launch Xvfb `:0`, XFCE, x11vnc on 5900, and `novnc_proxy` on 6080 using the bundled startup script. Observed desktop configuration: 8 vCPU / 8 GiB RAM.

## CLI version and flags

On 2026-09-29, CLI v1.2.3 exposed only `--timeout` and `--detach` for `sandbox create`; it did not expose CPU/memory/network/token flags. Newer versions may differ. Confirm `ucloud-sandbox-cli version` and `sandbox create --help`; do not invent flags.

## URLs and authentication

Service URL pattern: `https://{port}-{sandbox-id}.{region}.sandbox.ucloudai.com`. For noVNC use port 6080 and `/vnc.html`. `sandbox host <sandbox-id> 6080` returns the host; prepend `https://` and verify externally with curl before presenting it as working. CLI-created public URLs are not token-protected by default. Token-gated access requires a Python SDK configuration, not unsupported CLI flags.

## Expiry, listing, and pricing

Set expiry with `sandbox create ... --timeout <seconds>`. `sandbox list --format json` exposes fields such as `sandboxID`, `startedAt`, `endAt`, `state`, `cpuCount`, and `memoryMB`. Convert actual `endAt` to a clearly labeled timezone in the report. Billing is per second and stops when the sandbox stops; reference formula: CNY 0.00003/s/core plus CNY 0.000015/GiB/s. Observed 8C8G rate: about CNY 1.30/hour. Do not destroy unless asked.

## Exit IP verification

Inside the sandbox, run `curl -s --max-time 20 ifconfig.me` and `curl -s --max-time 20 ipinfo.io`; compare IPs and inspect JSON `country`. A previous us-ca measurement was `216.133.148.243`, Los Angeles, country `US`; treat it only as historical reference, not evidence for a new run.

## Shell pitfalls

- Upload LF scripts as-is; do not normalize line endings in the sandbox.
- In PowerShell, single-quote remote commands to prevent local variable expansion.
- Prefer uploaded scripts to long inline commands containing `$` or backslash escapes.
- Detach daemons with `setsid nohup ... < /dev/null &` so they survive exec sessions.
