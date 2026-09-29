---
name: "astra-muse"
description: "This skill should be used when a user asks to create or operate a UCloud Agent Sandbox with a graphical desktop, launch its desktop and noVNC services, verify a US exit IP and public access URL, or open a target website in sandbox Chrome. It defaults to us-ca, an eight-hour timeout, automatic desktop startup, and no screenshots."
compatibility: Requires ucloud-sandbox-cli, a PowerShell-compatible shell, network access to UCloud, and AstraFlow browser tools for opening noVNC in the right-side browser.
metadata:
  author: AstraFlow
  version: "1.0.0"
---

# Astra Muse — UCloud Desktop Sandbox

Create and operate a UCloud Agent Sandbox (not a UHost), start its graphical browser desktop, verify its noVNC URL and US egress, and open the requested site. Continue through startup and verification after creation; do not stop at merely creating the sandbox.

## Defaults

- Use the built-in `desktop` template (fixed 8C8G) and `us-ca` (Los Angeles, the official sole US region; `us-la` does not exist).
- Set automatic expiry to 28,800 seconds (8 hours), unless the user explicitly requests another duration.
- Route every CLI invocation with `UCLOUD_SANDBOX_REGION=us-ca`; never use the interactive `region` TUI or modify global `~/.ucloud-sandbox-cli/config.json`.
- Start the graphical desktop and verify noVNC and egress automatically after a clear create request.
- Open the supplied URL in sandbox Chrome. Never log in, submit forms, or perform actions on the user's behalf.
- Do not take, download, or create screenshots unless explicitly asked.
- Do not destroy the sandbox unless the user explicitly asks.

## Workflow

### Preflight and target URL

Read `references/ucloud-sandbox-cli.md`, then check actual CLI capability before creating a billable resource:

```powershell
ucloud-sandbox-cli version
ucloud-sandbox-cli sandbox create --help
```

Do not invent flags. On CLI v1.2.3, create supports only `--timeout` and `--detach`; newer versions may differ, so follow current help. Do not run `ucloud-sandbox-cli region`; use `$env:UCLOUD_SANDBOX_REGION = 'us-ca'`. Never print, request, or store API keys. If CLI is missing, use the official install directions in the reference; if authentication is absent, ask the user to authenticate securely with their own key.

If a target URL is missing, ask for it before creating the sandbox. Normalize a bare hostname to `https://` only when unambiguous. Respect requested supported region/timeout; ask if region is unsupported.

### Create the sandbox

Set the region in each shell process and run:

```powershell
$env:UCLOUD_SANDBOX_REGION = 'us-ca'
ucloud-sandbox-cli sandbox create desktop --detach --timeout 28800
ucloud-sandbox-cli sandbox list --format json
```

Use the user-requested timeout instead of `28800` if supplied. Record the returned sandbox ID, `cpuCount`, `memoryMB`, state, and `endAt`. Convert `endAt` to a clearly labeled timezone for the report. If creation fails, report the actual error and do not claim a sandbox exists.

### Start desktop and verify exit IP

Upload and run the bundled scripts, substituting the installed skill root and actual sandbox ID:

```powershell
$id = '<sandbox-id>'
$env:UCLOUD_SANDBOX_REGION = 'us-ca'
ucloud-sandbox-cli fs cp '<skill-root>\scripts\start-desktop.sh' "${id}:/home/user/start-desktop.sh"
ucloud-sandbox-cli fs cp '<skill-root>\scripts\verify-exit-ip.sh' "${id}:/home/user/verify-exit-ip.sh"
ucloud-sandbox-cli sandbox exec $id 'bash /home/user/start-desktop.sh'
ucloud-sandbox-cli sandbox exec $id 'bash /home/user/verify-exit-ip.sh'
```

Confirm from output that Xvfb `:0`, XFCE, x11vnc `5900`, and noVNC `6080` are active/listening. Compare `curl ifconfig.me` with the `ip` in `curl ipinfo.io`; verify `country` equals `US` for `us-ca`. Record only current-run evidence; a historical IP is not current proof.

### Verify and open noVNC

Get the host and construct the documented URL:

```powershell
$env:UCLOUD_SANDBOX_REGION = 'us-ca'
ucloud-sandbox-cli sandbox host '<sandbox-id>' 6080
curl.exe -s -o NUL -w 'http=%{http_code}' 'https://6080-<sandbox-id>.us-ca.sandbox.ucloudai.com/vnc.html'
```

Use the returned host to form `https://6080-<sandbox-id>.<region>.sandbox.ucloudai.com/vnc.html`. Only call it working after the local curl returns a successful HTTP status (normally 200). Open the verified noVNC URL in AstraFlow's right-side browser with `browser_control`, inspect with `browser_read`, and click Connect if needed. Distinguish loading the noVNC page from successfully connecting to the remote desktop.

### Open the requested site

Upload and run `scripts/open-browser.sh` with the user-provided URL:

```powershell
$env:UCLOUD_SANDBOX_REGION = 'us-ca'
ucloud-sandbox-cli fs cp '<skill-root>\scripts\open-browser.sh' '<sandbox-id>:/home/user/open-browser.sh'
ucloud-sandbox-cli sandbox exec '<sandbox-id>' 'bash /home/user/open-browser.sh "https://target.example"'
```

Confirm only what the command and browser evidence support. Do not log in or submit anything. Do not create screenshots or download images unless explicitly requested.

## Final response

Keep it concise. Lead with the clickable noVNC link and whether it was opened in the right-side browser, plus the observed HTTP status. Include sandbox ID, region, template/config, verified exit IP and ipinfo country, target page status, and exact expiry time/timezone. Mark any failed or unverified item plainly. Never report expected values as observed facts.

## Permission and failure handling

- Treat a clear create request as authorization to create the requested resource; do not ask for confirmation again unless a platform permission gate requires it.
- If the permission gate denies a command, do not retry it automatically or work around the gate. Explain which step remains and wait for new authorization or instructions.
- If creation succeeds but startup or network checks fail, say the sandbox exists but the desktop/link is not yet verified.
- Do not destroy, replace, or recover a sandbox unless the user asks or a documented missing-sandbox condition justifies recovery.

## Shell pitfalls

- Upload bundled LF scripts as-is; never normalize line endings inside the sandbox.
- In PowerShell, quote remote commands with single quotes to prevent local variable expansion.
- Prefer uploaded scripts to long inline commands with `$` or backslash escaping.
- Keep daemons detached using `setsid nohup ... < /dev/null &`.
