# OpenAI Codex with Network llama.cpp

This document defines the planned Codex CLI deployment on NOSTROMO using the Qwen model hosted by GRAVITYDRIVE. Codex will connect directly to llama.cpp's OpenAI-compatible Responses API; Ollama is not part of this design.

## Current Status

Verified from NOSTROMO on 2026-11-02:

- `gravitydrive.local` resolves from NOSTROMO.
- `http://gravitydrive.local:8080/health` returns `{"status":"ok"}`.
- `/v1/models` reports the model identifier `Qwen3.6-35B`.
- A minimal request to `/v1/responses` returned HTTP 200.
- Port `8081`, reserved for a secondary instance, did not respond.
- Codex CLI is not yet installed on NOSTROMO.

Endpoint compatibility has therefore been established, but end-to-end Codex startup, streaming, tool calls, and file operations remain unverified.

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
codex -c model_provider=gravitydrive -m Qwen3.6-35B
```

The custom provider makes `--oss` and `--local-provider ollama` unnecessary.

## 5. End-to-End Validation

Use a harmless test request first. Confirm that Codex can:

1. Start without OpenAI authentication.
2. Receive a streamed response from `Qwen3.6-35B`.
3. Read the repository instructions and list tracked files.
4. Invoke a read-only shell tool.
5. Complete without falling back to an OpenAI-hosted provider.

Do not authorize system changes during the first validation. After successful testing, record the Codex version, provider, model, and verification date in `SYSTEM.md`.

## References

- [OpenAI Codex provider configuration](https://developers.openai.com/siwc/token-sharing-open-source/codex-app-server)
- [llama.cpp server documentation](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)
- [Codex custom-provider discussion](https://github.com/openai/codex/discussions/7782)
