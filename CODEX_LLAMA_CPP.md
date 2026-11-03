# OpenAI Codex with Network llama.cpp

This document defines the Codex CLI deployment on NOSTROMO using Qwen3.8 hosted by GRAVITYDRIVE. Codex connects directly to llama.cpp's OpenAI-compatible Responses API; Ollama is not part of this design.

## Current Status

Verified across the local network on 2026-11-02:

- `gravitydrive.local` resolves and accepts connections on port `8080`.
- `http://gravitydrive.local:8080/health` returns `{"status":"ok"}`.
- `/v1/models` reports `Qwen3.8-27B`, GGUF format, 27.32B parameters, and a 262,144-token context per slot.
- The server exposes two parallel slots with F16 KV caches.
- The BF16 vision projector is loaded. The server reports text, image, and video input with text output.
- The `/v1/responses` endpoint successfully completed a streamed text response.
- Per-request thinking control successfully produced a direct, non-thinking response.
- The `/v1/responses` endpoint produced a correctly formed streamed function call with valid JSON arguments.
- A screenshot sent through `/v1/chat/completions` was read successfully, including accurate OCR of its visible text.
- Codex CLI is not yet installed on NOSTROMO.

The model, network endpoint, Responses transport, tool-call generation, and multimodal pipeline are working. End-to-end Codex execution on NOSTROMO remains to be tested after Codex is installed.

## What Qwen3.8 Can Do Now

Qwen3.8 can currently:

- Generate local text responses without using a cloud inference provider.
- Stream Responses API output in the format expected by Codex.
- Reason in thinking mode or accept a per-request non-thinking override.
- Produce structured function calls with valid function names and JSON arguments.
- Read screenshots and other images through the loaded vision projector.
- Accept video input through the multimodal llama.cpp service.
- Serve two concurrent 262,144-token contexts.

The model does not control a computer merely because it can see and call functions. Codex or another trusted agent harness must provide and execute the actual shell, filesystem, browser, email, and desktop tools. Browser control, email access, Windows interaction, and autonomous Linux administration must each be tested after those tools are connected.

## 1. Verify the Backend

```bash
curl -fsS http://gravitydrive.local:8080/health
curl -fsS http://gravitydrive.local:8080/v1/models | jq
```

Use the exact model identifier returned by `/v1/models`. Do not assume that the model or the secondary instance is running merely because the host responds.

## 2. Install Codex CLI

Confirm the currently supported installation method before deployment. The planned official npm installation is:

```bash
npm install -g @openai/codex@latest
codex --version
```

NOSTROMO did not have Node.js or npm installed at the last system inventory. Install only the required supported runtime, verify the resulting Codex version, and record both in `SYSTEM.md`.

## 3. Configure the llama.cpp Provider

Add this provider to `~/.codex/config.toml` for the `pilot` account:

```toml
[model_providers.gravitydrive]
name = "GRAVITYDRIVE llama.cpp"
base_url = "http://gravitydrive.local:8080/v1"
wire_api = "responses"
requires_openai_auth = false
supports_websockets = false
```

This configuration contains no credential. Keep any future token or secret out of the repository and command line.

## 4. Launch Codex

Start Codex from the target project directory and explicitly select the provider and model:

```bash
cd /opt/apps/nostromo
codex -c 'model_provider="gravitydrive"' -m Qwen3.8-27B
```

The custom provider makes `--oss` and `--local-provider ollama` unnecessary.

## 5. End-to-End Validation

Use a harmless test request first. Confirm that Codex can:

1. Start without OpenAI authentication.
2. Receive a streamed response from `Qwen3.8-27B`.
3. Read the repository instructions and list tracked files.
4. Invoke a read-only shell tool.
5. Complete without falling back to an OpenAI-hosted provider.

Do not authorize system changes during the first validation. After successful testing, record the Codex version, provider, model, and verification date in `SYSTEM.md`.

## References

- [OpenAI Codex provider configuration](https://developers.openai.com/siwc/token-sharing-open-source/codex-app-server)
- [llama.cpp server documentation](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)
- [Codex custom-provider discussion](https://github.com/openai/codex/discussions/7782)
