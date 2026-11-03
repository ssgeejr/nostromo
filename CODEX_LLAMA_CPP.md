# OpenAI Codex with Network llama.cpp

This document defines the Codex CLI deployment on NOSTROMO using Qwen3.8 hosted by GRAVITYDRIVE. Codex connects directly to llama.cpp's OpenAI-compatible Responses API; Ollama is not part of this design.

## Current Status

Verified across the local network on 2026-11-03:

- `gravitydrive.local` resolves and accepts connections on port `8080`.
- `http://gravitydrive.local:8080/health` returns `{"status":"ok"}`.
- `/v1/models` reports `Qwen3.8-27B`, GGUF format, 27.32B parameters, and a 262,144-token context per slot.
- The server exposes two parallel slots with F16 KV caches.
- The BF16 vision projector is loaded. The server reports text, image, and video input with text output.
- The `/v1/responses` endpoint successfully completed a streamed text response.
- Per-request thinking control successfully produced a direct, non-thinking response.
- The `/v1/responses` endpoint produced a correctly formed streamed function call with valid JSON arguments.
- A screenshot sent through `/v1/chat/completions` was read successfully, including accurate OCR of its visible text.
- The ChatGPT desktop bundle provides Codex CLI `0.166.0-alpha.5.1` at `/usr/lib/chatgpt/resources/codex`.
- The `gravitydrive` provider is configured in the `pilot` account's `~/.codex/config.toml` without credentials.
- `/usr/local/bin/qwen` launches an independent Codex process with the GRAVITYDRIVE provider, `Qwen3.8-27B`, and the verified 262,144-token context window.
- An end-to-end Codex inference test selected the GRAVITYDRIVE provider and returned the exact requested response.
- llama.cpp's `/v1/models` response is not a Codex-native model catalog. Codex warns and uses fallback model metadata; the launcher supplies the verified context window explicitly.

The model, network endpoint, Responses transport, tool-call generation, multimodal pipeline, and basic end-to-end Codex inference are working. Codex-driven shell and filesystem tool execution remains to be validated with harmless read-only tasks.

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

Use the exact model identifier returned by `/v1/models`. Do not assume that the model is running merely because the host responds.

## 2. Verify Codex CLI

NOSTROMO currently uses the Codex CLI bundled with the ChatGPT desktop application:

```bash
/usr/lib/chatgpt/resources/codex --version
```

The launcher prefers a `codex` executable on `PATH` and falls back to the bundled executable. NOSTROMO does not require Node.js or npm for the current deployment. If a separate CLI is installed later, use the currently supported official installation method, validate its version, and update `SYSTEM.md`.

## 3. Configure the llama.cpp Provider

The `pilot` account's `~/.codex/config.toml` contains this provider:

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

Start the dedicated Qwen-backed Codex instance with:

```bash
qwen
```

The tracked launcher source is `scripts/qwen`, installed as `/usr/local/bin/qwen`. It starts in `/opt/apps/qwen`, runs without the shared app-server daemon, selects the custom provider and model, and forwards additional arguments to Codex. The launcher exits with a clear error if the Qwen project checkout does not exist. Because the bundled Codex HTTP client does not resolve `.local` mDNS names reliably, the launcher resolves `gravitydrive.local` at startup and passes the current IPv4 address as a process-local provider override. The persistent configuration retains the hostname.

The custom provider makes `--oss` and `--local-provider ollama` unnecessary.

## 5. End-to-End Validation

Basic provider selection and inference have passed. Continue validation with harmless requests and confirm that Codex can:

1. Start without OpenAI authentication. **Verified 2026-11-03.**
2. Receive a streamed response from `Qwen3.8-27B`. **Verified 2026-11-03.**
3. Complete without falling back to an OpenAI-hosted provider. **Verified 2026-11-03.**
4. Read the repository instructions and list tracked files.
5. Invoke a read-only shell tool.

Do not authorize system changes during initial tool validation. Test records are stored outside the repository at `/opt/logs/nostromo/qwen3.8-test-case.log`.

## References

- [OpenAI Codex provider configuration](https://developers.openai.com/siwc/token-sharing-open-source/codex-app-server)
- [llama.cpp server documentation](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)
- [Codex custom-provider discussion](https://github.com/openai/codex/discussions/7782)
