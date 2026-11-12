# OpenCode disaster-recovery copy

This directory is a Git-trackable backup of the OpenCode installation used on ADMIN01. It is not a live OpenCode configuration directory, and OpenCode must not load skills from this repository at runtime.

## Live locations on ADMIN01

| Content | Live path | Repository copy |
| --- | --- | --- |
| OpenCode configuration | `%USERPROFILE%\.config\opencode\opencode.jsonc` | `opencode/opencode.jsonc` |
| OpenCode skills | `%USERPROFILE%\.config\opencode\skills\` | `opencode/skills/` |

On the current VM, `%USERPROFILE%` resolves to `C:\Users\devops.HELIOS1`.

## Refreshing the backup

After a live configuration or skill change, run this from the repository root:

```powershell
.\scripts\backup-opencode.ps1
```

Refresh this copy automatically after every live OpenCode configuration or skill update; no separate confirmation is required.

## Restoring after loss of the VM

1. Install OpenCode and the external dependencies documented in [`../INSTALL_OPENCODE.md`](../INSTALL_OPENCODE.md).
2. Create `%USERPROFILE%\.config\opencode\skills` on the replacement system.
3. Copy `opencode/opencode.jsonc` to `%USERPROFILE%\.config\opencode\opencode.jsonc`.
4. Copy the contents of `opencode/skills` to `%USERPROFILE%\.config\opencode\skills`.
5. Review machine-specific absolute executable paths in `opencode.jsonc`, especially Node, `open-computer-use`, and browser integration paths, and update them for the replacement installation.
6. Start OpenCode and verify the configured provider, MCP servers, browser integration, and skill discovery.

The backup must not contain credentials, tokens, private keys, or other secrets. If future OpenCode configuration needs credentials, reference an environment variable or a protected external credential file rather than committing the value here.
