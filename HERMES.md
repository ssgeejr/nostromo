# Hermes Desktop with GRAVITYDRIVE Qwen3.8

This document defines the Hermes deployment on NOSTROMO. Hermes Agent and Hermes Desktop run on NOSTROMO, while inference is provided by the OpenAI-compatible llama.cpp service on GRAVITYDRIVE.

## Current Status

Verified end to end on **2026-11-04**:

- Hermes Agent and Desktop: `0.22.7`, stable release `b200f5bc60e3`.
- Hermes Computer Use: pinned `cua-driver` `0.21.0`; upstream labels Linux support alpha.
- Inference endpoint: `http://gravitydrive.local:8080/v1`.
- Model: `Qwen3.8-27B`.
- Model format: GGUF `Q4_K_M`, 27,320,697,856 parameters.
- Context: 262,144 tokens per llama.cpp slot; Hermes pins this value because its generic metadata fallback reports 131,072 for the unknown model identifier.
- Modalities: text, image, and video input with text output.
- Transport: OpenAI-compatible Chat Completions. Hermes `0.22.7` ignores a persisted Responses-mode selection for non-OpenAI hosts, so Chat Completions is the effective and documented transport.
- Authentication: none. No API key is stored or sent.
- Thinking: disabled per request with `chat_template_kwargs.enable_thinking: false` to prevent unnecessarily long Qwen reasoning generations during interactive and vision work.
- Main model and every configured auxiliary LLM task use GRAVITYDRIVE. No fallback provider is configured.
- Computer Use telemetry is disabled.

The complete working path is:

```text
Hermes Desktop / Hermes Agent on NOSTROMO
    -> Hermes tools and Computer Use on NOSTROMO
    -> Qwen3.8-27B llama.cpp on GRAVITYDRIVE
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
| X11 authorization helper | `/opt/var/hermes/bin/hermes-x11-access` |
| KDE autostart entry | `~/.config/autostart/hermes-x11-access.desktop` |

Hermes manages pinned Python, Node.js, Chromium, FFmpeg, npm, ripgrep, and uv runtimes beneath `~/.hermes`. These are application-managed dependencies, not Debian system packages.

## Provider Configuration

The non-secret configuration in `~/.hermes/config.yaml` resolves to the following essential values:

```yaml
model:
  provider: custom:gravitydrive
  default: Qwen3.8-27B
  base_url: http://gravitydrive.local:8080/v1
  api_mode: chat_completions
  context_length: 262144
  supports_vision: true

providers:
  gravitydrive:
    name: GRAVITYDRIVE llama.cpp
    api: http://gravitydrive.local:8080/v1
    transport: chat_completions
    default_model: Qwen3.8-27B
    context_length: 262144
    discover_models: true
    extra_body:
      chat_template_kwargs:
        enable_thinking: false

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

## Starting Hermes Desktop

From the active KDE/XRDP desktop, open the application launcher and select **Hermes**, or run:

```bash
hermes desktop --skip-build
```

The Desktop and CLI use the same configuration and local state.

## Computer Use and XRDP

Computer Use is enabled in standard permission mode and starts `cua-driver` on demand. It uses:

- AT-SPI for Linux accessibility information.
- X11/XTest-compatible input control.
- X11 screen capture.
- The active KDE XRDP display, currently an Xorg session such as `:10`.

During the live XRDP test, the `cua-driver` capture process did not retain the XRDP `XAUTHORITY` setting and its first capture failed X11 authorization. The tracked helper therefore adds the narrow X11 server-interpreted authorization `SI:localuser:pilot` at KDE login. This grants display access only to processes already running as the `pilot` account; it does not allow another user or a network client to access the display.

Tracked sources:

- `scripts/hermes-x11-access`
- `config/autostart/hermes-x11-access.desktop`

Installed copies:

- `/opt/var/hermes/bin/hermes-x11-access`
- `~/.config/autostart/hermes-x11-access.desktop`

The authorization is scoped to the current X server and is recreated for each KDE/XRDP login.

## Verification

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

Test usage records are stored in `/opt/logs/hermes` and are not committed.

## Current Boundaries

- Computer Use on Linux is alpha upstream.
- Screenshot capture and interpretation are verified. Mouse, keyboard, scrolling, dragging, saving files, and multi-application workflows have not yet been exercised through Hermes.
- GRAVITYDRIVE currently exposes two inference slots. Long screenshot descriptions and concurrent work can exhaust both slots and exceed a short interactive timeout.
- The XRDP desktop must be logged in and unlocked for Hermes to control that session.
- Hermes web search, hosted connectors, image generation, TTS, and other optional external tools are not made local merely by selecting the GRAVITYDRIVE model. They must remain unused or be disabled before the production air gap is activated.
- `hermes doctor` validates the custom provider and all 19 auxiliary routes, but exits nonzero because optional cloud credentials are intentionally absent and the upstream Hermes lockfiles currently report: root npm tree, 1 high and 10 moderate advisories; web tree, 1 high and 4 moderate; UI/TUI tree, 1 high and 1 moderate. Hermes explicitly recommends waiting for upstream lockfile updates rather than applying a local package change that the next Hermes update would overwrite.
- NOSTROMO and GRAVITYDRIVE are not approved for PHI during experimentation. Production use requires the planned air gap plus the remaining documented administrative, physical, and technical controls.

## Air-Gapped Operation

The core stack does not require an external inference provider after its software, managed runtimes, model, and Computer Use driver have been installed:

- Hermes runs on NOSTROMO.
- Qwen inference runs on GRAVITYDRIVE over the internal network.
- Computer Use runs locally on NOSTROMO.
- No inference API credential or cloud fallback is configured.

Before production isolation, verify that required packages and model artifacts are locally cached, disable or remove external-only toolsets and integrations, confirm internal DNS and time dependencies, and validate operation while the firewall denies every external path.
