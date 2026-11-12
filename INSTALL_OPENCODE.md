# OpenCode Deployment on ADMIN01

This document defines the planned OpenCode installation on the Windows x64 workstation **ADMIN01**. It is both an implementation runbook and a record of why each component exists.

The goal is not merely to install the OpenCode application. The completed system will let OpenCode use the Gufo model hosted by GRAVITYDRIVE, operate approved Windows applications through accessibility interfaces, and work in the user's existing Chromium browser through MCP integrations.

No installation state is implied by this document. Record versions and test results during the actual deployment.

## Target Outcome

After installation, ADMIN01 will provide:

- OpenCode Desktop as the primary graphical agent interface.
- The OpenCode CLI for configuration, diagnostics, terminal use, and repeatable testing.
- A normal shared Node.js LTS runtime for OpenCode and its locally installed integrations.
- `open-computer-use` for native Windows application observation and control.
- OpenCode Browse for controlled access to real Chrome, Edge, Brave, or other Chromium tabs.
- GRAVITYDRIVE as the inference host, using its OpenAI-compatible Chat Completions API.
- A tested MCP path from OpenCode to one harmless Windows application and one harmless webpage.

This design does **not** require Python, Docker, WSL, a second model runtime, CUDA, or a separate Playwright installation. Browse supplies and manages its own browser-control implementation.

## Architecture

```text
User
  |
  +-- OpenCode Desktop / OpenCode CLI on ADMIN01
        |
        +-- Model requests --> GRAVITYDRIVE llama.cpp
        |                     http://gravitydrive.local:8080/v1
        |                     Gufo_Qwen3.8_Flash-Next
        |
        +-- MCP: open-computer-use --> Windows accessibility APIs
        |                            --> native Windows applications
        |
        +-- MCP: OpenCode Browse --> local Browse component
                                    --> Chromium extension
                                    --> existing browser tabs and sessions
```

The model proposes actions, but the OpenCode agent and MCP tools perform them. Model connectivity alone does not provide desktop or browser control.

## Components and Why They Are Needed

### OpenCode Desktop for Windows x64

OpenCode Desktop provides the graphical interface for conversations, projects, sessions, diffs, permissions, and tool use. Install the Windows x64 build because ADMIN01 is the target workstation.

Use it to:

- Run Gufo-backed agent sessions.
- Review and approve tool activity.
- Work with local files and repositories.
- Invoke the desktop and browser MCP tools after they are connected.

### OpenCode CLI

The CLI exposes the same OpenCode environment from PowerShell and makes version checks, provider tests, MCP diagnosis, and scripted smoke tests reproducible. Desktop and CLI are complementary; installing Desktop is not a substitute for having the CLI available on `PATH`.

The current OpenCode 2 npm package is `@opencode/cli`. Do not use older OpenCode 1 instructions or the legacy `opencode-ai` npm package.

### Node.js LTS

Node.js and npm are required to install and run the OpenCode CLI, `open-computer-use`, and OpenCode Browse. ADMIN01 should have a normal shared LTS installation rather than depending on an application-private or Hermes-managed runtime.

Use an actively supported Node.js LTS release available at installation time. Record the exact installed versions instead of hard-coding a version in this runbook.

### Open Computer Use

`open-computer-use` is a local MCP service that exposes Windows applications through accessibility-based computer-use tools. It enables OpenCode to inspect windows, locate accessible controls, click, type, press keys, and perform other approved UI actions.

It runs locally on ADMIN01. The initial test must use a harmless application and reversible actions.

### OpenCode Browse

Browse consists of a local MCP component and a Chromium extension. It lets OpenCode use real browser tabs, existing logins, extensions, screenshots, downloads, and page interactions. It can lend an existing tab to an agent or open agent tabs in a background group.

Authentication, MFA, payments, consent screens, and other sensitive handoffs remain user-controlled. Use site allowlists where practical and start with a public, non-sensitive webpage.

Browse uses its packaged browser-control implementation; do not install Playwright separately for this deployment.

### GRAVITYDRIVE and Gufo

GRAVITYDRIVE performs the resource-heavy inference. ADMIN01 sends OpenAI-compatible Chat Completions requests over the local network to:

```text
http://gravitydrive.local:8080/v1
```

The expected model identifier is:

```text
Gufo_Qwen3.8_Flash-Next
```

Both values are live operational state. Verify `/health` and `/v1/models` immediately before configuration. If the server reports a different model identifier, use the exact reported identifier and update this document or the deployment record.

## Security and Data Boundaries

- Keep credentials, tokens, private keys, cookies, and secret configuration out of this repository.
- Do not put secrets in PowerShell command lines, transcripts, screenshots, logs, or committed environment files.
- The current local GRAVITYDRIVE endpoint is expected not to require a credential. If authentication is added later, store it in the appropriate user credential/configuration mechanism and reference it indirectly.
- Browser control can act with the user's logged-in session. Begin with public test pages and explicitly review access before using authenticated sites.
- Desktop control can operate with the interactive user's authority. Keep OpenCode permission prompts enabled while validating the integration.
- Do not expose GRAVITYDRIVE, Browse, or the computer-use MCP service to the public network as part of this deployment.
- Use test data during commissioning. Approval for actual regulated information is a separate decision.

## Installation Sequence

Perform the steps in this order so that each dependency is available before its consumers are installed.

### 1. Capture the Pre-Installation State

Open a normal PowerShell session on ADMIN01 and record the results. Administrative elevation should be used only when an installer requires it.

```powershell
$PSVersionTable.PSVersion
[System.Environment]::OSVersion.VersionString
[System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
Get-Command node,npm,opencode,open-computer-use,ocu,browse -ErrorAction SilentlyContinue
node --version
npm --version
```

Expected architecture: `X64`.

Also identify the Chromium browser that will be used for testing and confirm that the intended Windows account can install an extension.

### 2. Verify GRAVITYDRIVE Before Installing Clients

```powershell
Resolve-DnsName gravitydrive.local
Test-NetConnection gravitydrive.local -Port 8080
Invoke-RestMethod http://gravitydrive.local:8080/health
$models = Invoke-RestMethod http://gravitydrive.local:8080/v1/models
$models | ConvertTo-Json -Depth 10
```

Installation may continue if the backend is temporarily unavailable, but provider and end-to-end tests cannot pass until DNS, port `8080`, `/health`, and `/v1/models` work from ADMIN01.

Record the exact model ID returned by `/v1/models`. Do not silently substitute the expected name if live discovery differs.

### 3. Install Shared Node.js LTS

Download the Windows x64 LTS installer from the official Node.js website and use its standard per-machine installation unless ADMIN01 policy requires a managed software source:

- <https://nodejs.org/en/download>

Open a new PowerShell session after installation and verify:

```powershell
node --version
npm --version
npm config get prefix
```

The npm global binary directory must be on the interactive user's `PATH`. Do not reuse or modify another application's private Node installation.

### 4. Install OpenCode Desktop

Download the current **Windows x64** Desktop build from the official OpenCode installation page:

- <https://opencode.ai/docs>

Install it for the intended ADMIN01 user, start it once, and confirm that the application opens. Do not connect a cloud provider merely to bypass the Gufo configuration; GRAVITYDRIVE is the intended backend.

Record the installed Desktop version in the deployment record.

### 5. Install the OpenCode CLI

Use the current OpenCode 2 npm package:

```powershell
npm install --global @opencode/cli
opencode --version
Get-Command opencode
```

OpenCode's documentation also offers standalone binaries, but the npm method fits this stack because Node.js is already required. OpenCode currently states that Windows package-manager installation of OpenCode itself is not supported; do not substitute an unofficial `winget`, Chocolatey, or Scoop package without separately validating its provenance and version.

### 6. Configure the Gufo Provider

Use a user-global configuration so Desktop and CLI sessions for the installing user can share it. OpenCode documents the user configuration as:

```text
~/.config/opencode/opencode.jsonc
```

On Windows, `~` means the current user's profile directory. Create the directory if necessary. Before changing an existing configuration, copy it to a dated backup and preserve all unrelated providers, permissions, and MCP entries.

Use the following provider definition, replacing the model key and `modelID` only if `/v1/models` reports a different live identifier:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "gravitydrive/Gufo_Qwen3.8_Flash-Next",
  "providers": {
    "gravitydrive": {
      "name": "GRAVITYDRIVE Gufo",
      "package": "@opencode/ai/providers/openai-compatible",
      "settings": {
        "baseURL": "http://gravitydrive.local:8080/v1"
      },
      "models": {
        "Gufo_Qwen3.8_Flash-Next": {
          "modelID": "Gufo_Qwen3.8_Flash-Next",
          "name": "Gufo Qwen3.8 Flash-Next"
        }
      }
    }
  }
}
```

This selects the OpenAI-compatible runtime that uses Chat Completions. Do not guess context or output limits. Add `limit` values only after they are confirmed from the live server configuration and validated with the model.

Start the CLI in a harmless test directory:

```powershell
opencode
```

In OpenCode, use `/models` and confirm that `gravitydrive/Gufo_Qwen3.8_Flash-Next` is selected. Submit a simple prompt and verify that it completes while GRAVITYDRIVE is the active provider.

### 7. Install Open Computer Use

```powershell
npm install --global open-computer-use
open-computer-use doctor
open-computer-use install-opencode-mcp
```

The installer writes an OpenCode MCP entry to the active user configuration. Inspect the resulting OpenCode configuration and confirm that it preserved the GRAVITYDRIVE provider and all unrelated settings.

Useful direct diagnostics are:

```powershell
open-computer-use --help
open-computer-use doctor
open-computer-use call list_apps
```

The package also exposes `ocu` as a shorter alias. Windows does not require the macOS Accessibility and Screen Recording permission flow, but `doctor` must still pass and application visibility must be verified in the current interactive session.

### 8. Install OpenCode Browse

Use the official Browse page and install the Chromium extension **first**. The extension guides the remaining local setup:

- <https://opencode.ai/product/browse>

Pin the extension so connection and handoff state are visible. Follow its prompts to install/connect the local Browse component and OpenCode MCP entry.

If the guided installation cannot be used, the documented npm fallback is:

```powershell
npm install --global @opencode/browse
browse install
```

Do not install a separate Playwright package. Restart the browser and OpenCode if the extension or newly installed MCP service is not detected.

### 9. Review MCP and Permission State

After both integrations are installed:

1. Back up and inspect `~/.config/opencode/opencode.jsonc` or the active `.json` equivalent.
2. Confirm that GRAVITYDRIVE remains the selected provider.
3. Confirm that both computer-use and Browse MCP servers are present and enabled.
4. Confirm that command paths resolve for the same Windows user that runs OpenCode Desktop.
5. Keep consequential actions set to ask for approval during initial testing.
6. Restart OpenCode so its background service reloads the configuration.

Do not replace the entire configuration with a sample after an integration installer has modified it. Merge and preserve settings.

## End-to-End Acceptance Tests

Run these tests from a fresh OpenCode session. Use harmless, reversible tasks and observe which tools OpenCode actually invokes.

### Test A: Model Connectivity

Ask Gufo to return a unique, exact phrase and identify the active provider/model in the session UI.

Pass criteria:

- The response completes without using a cloud fallback.
- The active model is the exact live GRAVITYDRIVE model.
- GRAVITYDRIVE logs or live activity show the request, if operational visibility is available.

### Test B: Native Windows Application

Open Notepad manually, then ask OpenCode to use computer control to:

1. Identify the Notepad window.
2. Enter a clearly disposable test sentence.
3. Read or confirm the visible text.
4. Leave the document unsaved, unless explicitly instructed otherwise.

Suggested text:

```text
OpenCode ADMIN01 computer-use test - <current date and time>
```

Pass criteria:

- OpenCode uses the `open-computer-use` MCP tools rather than pretending the action occurred.
- It identifies the correct application and interacts with the intended control.
- The visible result matches the request.
- No unrelated window or file is modified.

### Test C: Webpage Control

Open a public, non-authenticated test page in the selected Chromium browser. Lend the tab through the Browse extension, or allow Browse to open a controlled tab. Ask OpenCode to read a distinctive heading and perform one harmless navigation or form interaction.

Good initial targets include an internal disposable test page or <https://example.com/>. Do not begin with email, banking, clinical, administrative, or other sensitive sessions.

Pass criteria:

- The extension and local Browse component show a healthy connection.
- OpenCode uses Browse tools and operates the intended tab.
- It reads the page accurately and completes the requested harmless interaction.
- It does not access tabs or domains outside the intended test scope.

### Test D: Restart Persistence

Close OpenCode Desktop and the CLI, then start Desktop again.

Pass criteria:

- The GRAVITYDRIVE provider and Gufo model remain available.
- Both MCP integrations reconnect without reinstallation.
- A short model prompt and read-only tool check still work.

## Troubleshooting

### `opencode`, `browse`, or `open-computer-use` Is Not Found

- Open a new PowerShell session after installing Node.js or a global npm package.
- Run `npm config get prefix` and confirm the corresponding binary directory is on the user's `PATH`.
- Run `Get-Command opencode,open-computer-use,ocu,browse -ErrorAction SilentlyContinue`.
- Confirm Desktop and PowerShell are running as the same Windows user.

### GRAVITYDRIVE Cannot Be Reached

- Re-run `Resolve-DnsName gravitydrive.local` rather than relying on a saved IP address.
- Re-run `Test-NetConnection gravitydrive.local -Port 8080`.
- Check `/health` and `/v1/models` separately.
- Do not permanently replace the hostname with an old IP address.
- Verify GRAVITYDRIVE itself before changing the OpenCode provider configuration.

### The Model Is Missing or Requests Fail

- Compare the configured model key and `modelID` with the exact `/v1/models` response.
- Confirm the provider package is `@opencode/ai/providers/openai-compatible`.
- Confirm `baseURL` includes `/v1` and uses the correct capitalization: `baseURL`.
- Confirm no project-level `opencode.json(c)` overrides the user-global provider or default model.
- Remove unverified context/output limit declarations while diagnosing compatibility.

### Computer Use Is Unavailable

- Run `open-computer-use doctor` and `open-computer-use call list_apps` outside OpenCode.
- Confirm the MCP entry exists in the active OpenCode configuration.
- Restart OpenCode after configuration changes.
- Test with a standard accessible application such as Notepad before diagnosing a custom application.

### Browse Does Not Connect

- Confirm the extension is installed and enabled in the browser profile actually being tested.
- Open the extension UI and check its local connection state.
- Run `browse install` if guided setup did not complete.
- Restart the browser and OpenCode.
- Test with a public page and a single lent tab before using authenticated sessions.

## Updates and Recovery

Before updating any global package, record the working versions:

```powershell
node --version
npm --version
opencode --version
npm list --global --depth=0
```

Back up the active OpenCode configuration before upgrades or MCP reinstallation. Update one layer at a time and repeat the relevant acceptance tests.

If the deployment must be backed out:

1. Close OpenCode Desktop and any active CLI sessions.
2. Restore the backed-up OpenCode configuration.
3. Disable or remove the Browse extension from the intended browser profile.
4. Uninstall only the npm packages that were installed for this deployment, if removal is required.
5. Uninstall OpenCode Desktop through Windows Installed Apps, if removal is required.
6. Remove shared Node.js only after confirming that no other application depends on it.

Do not delete the entire user configuration directory as a troubleshooting shortcut; it may contain unrelated sessions, providers, and settings.

## Deployment Record

Complete this section during the ADMIN01 installation.

| Item | Recorded value |
| --- | --- |
| Installation date | Not installed |
| Windows edition/build | Not recorded |
| Architecture | Expected: x64 |
| Installing Windows user | Not recorded |
| Node.js version | Not installed |
| npm version | Not installed |
| OpenCode Desktop version | Not installed |
| OpenCode CLI version | Not installed |
| `open-computer-use` version | Not installed |
| `@opencode/browse` version | Not installed |
| Browser and extension version | Not installed |
| GRAVITYDRIVE address resolved | Not tested from ADMIN01 |
| `/health` result | Not tested from ADMIN01 |
| Live model identifier | Expected: `Gufo_Qwen3.8_Flash-Next` |
| Model acceptance test | Not run |
| Windows application test | Not run |
| Browser test | Not run |
| Restart-persistence test | Not run |
| Configuration backup location | Not recorded |
| Remaining issues | None recorded |

After a successful installation, update this record with observed facts. If the change materially affects the NOSTROMO/GRAVITYDRIVE system inventory, update `SYSTEM.md` separately; do not describe planned ADMIN01 software as already installed on NOSTROMO.

## Official References

- [OpenCode installation and downloads](https://opencode.ai/docs)
- [OpenCode configuration](https://opencode.ai/docs/config)
- [OpenCode providers and OpenAI-compatible configuration](https://opencode.ai/docs/providers)
- [OpenCode Browse](https://opencode.ai/product/browse)
- [`open-computer-use` repository and installation](https://github.com/anomalyco/computer-use)
- [Node.js downloads](https://nodejs.org/en/download)

