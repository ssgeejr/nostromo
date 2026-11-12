# Hermes Desktop with GRAVITYDRIVE Local Inference

This document defines the Hermes deployment on NOSTROMO. Hermes Agent and Hermes Desktop run on NOSTROMO, while inference is provided by the OpenAI-compatible llama.cpp service on GRAVITYDRIVE.

## Current Status

Live state verified on **2026-11-12**:

- Hermes Agent and Desktop: `0.23.1`, stable release `3b421578588243f920886e6fe79a6faa87ea026e`.
- Hermes Computer Use: pinned `cua-driver` `0.21.0`; upstream labels Linux support alpha.
- Inference endpoint: `http://gravitydrive.local:8080/v1`.
- Model advertised by `/v1/models`: `Gufo_Qwen3.8_Flash-Next`.
- Advertised context length: 131,072 tokens.
- Advertised input modalities: text and image.
- Transport: OpenAI-compatible Chat Completions.
- Authentication: none. No API key is stored or sent.
- Direct no-reasoning benchmark: 256 output tokens at 100.93 tokens/second, 174.7 ms time to first token, and 2.783 seconds wall time. See [`GRAVITYDRIVE_BENCHMARKS.md`](GRAVITYDRIVE_BENCHMARKS.md).
- Hermes resolves the main provider and all 19 auxiliary LLM routes to GRAVITYDRIVE. No fallback provider is configured.
- Computer Use telemetry is disabled.
- Hermes is configured for `Gufo_Qwen3.8_Flash-Next` with a 131,072-token context in both the main model block and the named GRAVITYDRIVE provider. A fresh Hermes one-shot completed successfully through the custom provider after alignment.

The intended path is:

```text
Hermes Desktop / Hermes Agent on NOSTROMO
    -> Hermes tools and Computer Use on NOSTROMO
    -> Gufo_Qwen3.8_Flash-Next on GRAVITYDRIVE
```

## Installed Layout

| Purpose | Location |
| --- | --- |
| Replaceable Hermes checkout | `/opt/var/hermes/hermes-agent` |
| Hermes launcher | `~/.local/bin/hermes` |
| Desktop application launcher | `~/.local/share/applications/com.nousresearch.hermes.desktop` |
| User configuration and state | `~/.hermes` |
| Main configuration | `~/.hermes/config.yaml` |
| Credential environment file | `~/.hermes/.env`, mode `0600`; no inference credential is required |
| Computer Use driver | `~/.hermes/tools/cua-driver-0.21.0-linux-x64/cua-driver` |
| Persistent Hermes project data | `/opt/prj/hermes` |
| Test records | `/opt/logs/hermes` |
| Pre-GRAVITYDRIVE configuration backup | `~/.hermes/backups/config.yaml.pre-gravitydrive-20261104` |
| Pre-0.23.1 update backup | `~/.hermes/backups/pre-update-2026-11-10-132750.zip`, mode `0600` |
| Pre-reasoning-profile backup | `~/.hermes/backups/config.yaml.pre-ui-reasoning-20261110-205807`, mode `0600` |
| Pre-Gufo model-alignment backup | `~/.hermes/backups/config.yaml.pre-gufo-qwen38-flash-next-20261112`, mode `0600` |
| X11 authorization helper | `/opt/var/hermes/bin/hermes-x11-access` |
| KDE autostart entry | `~/.config/autostart/hermes-x11-access.desktop` |

Hermes manages pinned Python, Node.js, Chromium, FFmpeg, npm, ripgrep, and uv runtimes beneath `~/.hermes`. These are application-managed dependencies, not Debian system packages.

## Provider Configuration

The non-secret configuration in `~/.hermes/config.yaml` resolves to the following essential values:

```yaml
model:
  provider: custom:gravitydrive
  default: Gufo_Qwen3.8_Flash-Next
  base_url: http://gravitydrive.local:8080/v1
  api_mode: chat_completions
  context_length: 131072
  supports_vision: true

agent:
  reasoning_effort: low

providers:
  gravitydrive:
    name: GRAVITYDRIVE llama.cpp
    api: http://gravitydrive.local:8080/v1
    transport: chat_completions
    default_model: Gufo_Qwen3.8_Flash-Next
    context_length: 131072
    discover_models: true

auxiliary:
  vision:
    reasoning_effort: none
  compression:
    reasoning_effort: low
  title_generation:
    reasoning_effort: none
  approval:
    reasoning_effort: none
  monitor:
    reasoning_effort: none

fallback_providers: []
```

The following auxiliary tasks are pinned explicitly to `provider: custom:gravitydrive`, so they use the same named GRAVITYDRIVE provider and never select an automatic cloud model:

- `vision`
- `compression`
- `skills_hub`
- `approval`
- `review`
- `mcp`
- `title_generation`
- `memory_query_rewrite`
- `tts_audio_tags`
- `voice_chat`
- `triage_specifier`
- `kanban_decomposer`
- `profile_describer`
- `goal_judge`
- `curator`
- `monitor`
- `background_review`
- `moa_reference`
- `moa_aggregator`

Automatic title-model upgrading is disabled. This prevents title generation from selecting a different provider.

## Live Tool Verification

Hermes Doctor on 2026-11-12 confirmed the Python environment, SQLite stores, TLS trust, required packages, configuration schema, provider routing, Git, ripgrep, Node.js, Chromium, and dashboard imports. The following primary tool families registered as available:

- Browser and browser-use
- Web search and extraction through the configured provider
- Terminal, file operations, and code execution
- Computer Use, desktop UI, and vision
- Projects, skills, memory, session search, and todo management
- Delegation, cron, kanban, connections, connectors, catalog, TTS, and video

Optional integrations without their required dependency or credential remain unavailable. `hermes pm doctor` also reported that the managed Python bytes do not match its recorded package-manager digest, although Hermes Doctor successfully launched and validated Python 3.14.9 and the active runtime environment. Computer Use validation from a headless SSH shell reports no display because that shell has no X11 or Wayland session; desktop-session validation must be performed from the active KDE session.

## Starting Hermes Desktop

From the active KDE/XRDP desktop, open the application launcher and select **Hermes**, or run:

```bash
hermes desktop --skip-build
```

The Desktop and CLI use the same configuration and local state.

## Computer Use and KDE Sessions

Computer Use is enabled in standard permission mode and starts `cua-driver` on demand. It uses:

- AT-SPI for Linux accessibility information.
- X11/XTest-compatible input control.
- X11 screen capture.
- X11/XWayland screen capture and input in the active KDE session. The 2026-11-10 validation used the local Wayland session on `:1`; the native Wayland backend remains an optional experimental path and was not enabled.

During the live XRDP test, the `cua-driver` capture process did not retain the XRDP `XAUTHORITY` setting and its first capture failed X11 authorization. The tracked helper therefore adds the narrow X11 server-interpreted authorization `SI:localuser:pilot` at KDE login. This grants display access only to processes already running as the `pilot` account; it does not allow another user or a network client to access the display.

Tracked sources:

- `scripts/hermes-x11-access`
- `config/autostart/hermes-x11-access.desktop`

Installed copies:

- `/opt/var/hermes/bin/hermes-x11-access`
- `~/.config/autostart/hermes-x11-access.desktop`

The authorization is scoped to the current X server and is recreated for each KDE/XRDP login.

## Verification

On 2026-11-12, the main model block and named GRAVITYDRIVE provider were aligned with live discovery: `Gufo_Qwen3.8_Flash-Next` and 131,072 tokens. `hermes config check` passed, all four values read back correctly, and a fresh no-reasoning Hermes one-shot returned the exact response `HERMES_MODEL_ALIGNMENT_OK` in one API call. The request used the `custom` provider, reported the correct model identifier, and completed in 7.127 seconds including Hermes startup and 16,188 project-context input tokens. The restricted pre-change configuration backup is listed under Installed Layout, and the usage record is stored at `/opt/logs/hermes/2026-11-12-gufo-model-alignment-usage.json` with mode `0600`.

Check the backend before relying on it:

```bash
curl -fsS http://gravitydrive.local:8080/health
curl -fsS http://gravitydrive.local:8080/v1/models | jq
```

Check Hermes and Computer Use:

```bash
hermes --version
hermes config check
hermes computer-use status
hermes computer-use doctor
hermes pm doctor
```

The following acceptance tests passed on 2026-11-04:

1. Text inference selected `provider=custom`, model `Qwen3.8-27B`, and returned the exact requested response.
2. Named-provider inference returned `NAMED_PROVIDER_OK` in one API call after thinking was disabled.
3. Qwen generated a valid Hermes terminal tool call; Hermes executed the harmless `printf HERMES_TOOL_OK` command and Qwen returned the observed result.
4. Qwen generated a Computer Use capture call without any input action.
5. `cua-driver` captured the active XRDP desktop.
6. The screenshot reached the GRAVITYDRIVE-backed vision task and Hermes returned `CAPTURE_OK`.
7. The successful Computer Use test completed with five main-model calls and one auxiliary vision call. The screenshot/vision portion took approximately 115 seconds, so GUI perception is working but currently slow.

After replacing the auxiliary `main` aliases with explicit `custom:gravitydrive` routes, Hermes Doctor resolved all 19 routes successfully. A repeat screenshot test reached capture and local vision processing without a configuration or authorization error, but its bounded 240-second client expired while GRAVITYDRIVE had concurrent slot activity. This is recorded as a latency/capacity result, not as a second completed capture test.

The following update validation passed on 2026-11-10 after upgrading from `0.22.7` to `0.23.1`:

1. The checkout exactly matches stable tag `v0.23.1` at commit `3b421578588243f920886e6fe79a6faa87ea026e` and is clean.
2. Hermes migrated the configuration schema from version 52 to 53; `hermes config check` passed.
3. Hermes Doctor resolved the main provider and all 19 auxiliary routes to GRAVITYDRIVE, reported no active security advisories, and found only one moderate npm advisory in each of the root and web trees.
4. GRAVITYDRIVE health and model discovery passed, and an end-to-end CLI request returned the exact response `HERMES_UPDATE_OK`.
5. Computer Use passed binary, platform, MCP session, AT-SPI/X11 input, and screen-capture checks from the active KDE Wayland session through XWayland.
6. Managed Python, Node.js, npm, pnpm, uv, Chromium, FFmpeg, ripgrep, and `cua-driver` checks passed; the packaged Desktop executable has no missing shared libraries.
7. The pre-update backup passed ZIP integrity testing and is restricted to mode `0600`. Restore it with `hermes import ~/.hermes/backups/pre-update-2026-11-10-132750.zip` if rollback is required.

Later on 2026-11-10, Hermes `0.23.1` sent both the global `reasoning_effort: medium` and the provider override `chat_template_kwargs.enable_thinking: false`; GRAVITYDRIVE rejected the contradictory request with `invalid_reasoning`. The provider-level hard disable was removed, the main agent was set to `low`, and latency-sensitive auxiliary tasks were pinned as documented above. The stale gateway was terminated cleanly, Desktop and a fresh gateway were launched in the active KDE session, configuration validation passed, and an end-to-end Hermes turn returned the exact response `HERMES_REASONING_OK`. One existing chat retained its creation-time frozen configuration; it was repaired through Hermes' supported session commands by setting `/reasoning low` and reselecting `Qwen3.8-27B`, which refreshed the named provider without directly modifying the session database. That exact 42,400-token chat then returned `EXISTING_CHAT_OK` with low reasoning in 105.6 seconds.

Test usage records are stored in `/opt/logs/hermes` and are not committed.

## Current Boundaries

- Computer Use on Linux is alpha upstream.
- Screenshot capture and interpretation are verified. Mouse, keyboard, scrolling, dragging, saving files, and multi-application workflows have not yet been exercised through Hermes.
- The live backend advertises a 131,072-token context. The 2026-11-12 benchmark reported logical concurrency 2 with physical execution width 1 and a serial-fallback execution plan.
- The XRDP desktop must be logged in and unlocked for Hermes to control that session.
- Hermes web search, hosted connectors, image generation, TTS, and other Internet-backed tools remain available for configuration independently of the GRAVITYDRIVE model.
- `hermes doctor` validates the custom provider and all 19 auxiliary routes. It exits nonzero when optional integrations or system dependencies are absent; these warnings do not affect the configured GRAVITYDRIVE path. The current upstream lockfiles report one moderate advisory in the root npm tree and one in the web tree, with none in the UI/TUI tree.

## Inference and Internet Connectivity

The core inference stack uses local infrastructure by default:

- Hermes runs on NOSTROMO.
- Qwen inference runs on GRAVITYDRIVE over the internal network.
- Computer Use runs locally on NOSTROMO.
- No external inference credential or automatic cloud fallback is currently configured.

Internet access is an available system capability. External providers and tools, including Grok, web search, hosted connectors, package repositories, and remote APIs, may be enabled when they support the intended workflow. Each integration should be configured, authenticated, tested, and documented independently.

## Preferred Model

Use the live model advertised by GRAVITYDRIVE, currently `Gufo_Qwen3.8_Flash-Next`, as the preferred model whenever it is capable of completing the task effectively. Hermes may use Internet-backed tools, services, APIs, or external models when they provide information or capabilities that the local model does not have or when they are the better choice for the task.

## Grok's Role

- The model currently advertised by GRAVITYDRIVE remains Hermes' preferred primary model.
- Grok provides research, current information, clarification, and second opinions when those capabilities improve the result.
- Grok is invoked explicitly by the user or through a defined Hermes capability.
- Grok is not an automatic fallback for failed Qwen inference.
- Connecting Grok does not replace or change the configured GRAVITYDRIVE default model.
