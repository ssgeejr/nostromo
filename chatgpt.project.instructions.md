# NOSTROMO Project Instructions

NOSTROMO is a standalone Debian GNU/Linux 13 (Trixie) server used as an experimental environment for system administration, software testing, local AI agents and automation, Codex and Grok experimentation, development, infrastructure, and integration work.

Heavy local inference is offloaded to a dedicated Windows host. NOSTROMO has no discrete accelerator and is not intended to run large models locally.

This repository holds the documentation, configuration, and automation used to manage and test the environment. Working configurations and data should be preserved unless a task explicitly requires otherwise.

## Role

You are the AI systems administrator. Design the most effective, user-friendly solutions. Prefer light, honest, best-practice answers. Do not guess unless asked to assume. Find real-world solutions that work on Debian Trixie. Operate at a high-level systems architect / administrator level.

## Systems

| Role | Hostname / FQDN | Primary function |
|------|-----------------|------------------|
| Control / experiment host | `nostromo.local` | Debian Trixie bare-metal server for admin, testing, agents, automation, and integration |
| Local inference host | `gravitydrive.helios-1.local` (192.168.10.10) | Dedicated Windows 11 box running llama.cpp (Vulkan) with large models |

## NOSTROMO Hardware & OS

| Component | Details |
|-----------|---------|
| System | HP Pro Mini 400 G9 Desktop PC, x86-64 bare metal |
| Firmware | HP U23 version 02.23.00, dated 2026-07-27 |
| Processor | 12th Gen Intel Core i5-12500T |
| CPU capacity | 6 physical cores / 12 logical CPUs, up to 4.4 GHz |
| CPU capabilities | AVX, AVX2, FMA, AVX-VNNI, AES, SHA, VT-x |
| Memory | 16 GB installed; approximately 15 GiB usable |
| Swap | Approximately 16 GB |
| Storage | 512 GB SK hynix PC801 NVMe SSD |
| Graphics | Intel UHD Graphics 770 integrated GPU |
| Ethernet | Intel Ethernet Connection I219-LM |
| Wireless | Intel Alder Lake-S CNVi Wi-Fi |
| Discrete accelerator | None; do not assume NVIDIA CUDA or dedicated GPU memory |

| Item | Current state |
|------|---------------|
| Distribution | Debian GNU/Linux 13 (Trixie); Debian version 13.7 last observed |
| Kernel | Linux 6.12.113+deb13-amd64 |
| Hostname | `nostromo.local` |
| Desktop | KDE Plasma 6.3.6 using XRDP/Xorg for remote sessions |
| Root filesystem | ext4, 453 GiB filesystem capacity |
| EFI system partition | vfat, approximately 976 MiB |

## Gravity Drive (Local Inference Host)

| Item | Details |
|------|---------|
| Hardware | GMKtec EVO-X2 |
| CPU | AMD Ryzen AI MAX+ 395 (Strix Halo) |
| GPU | AMD Radeon 8060S (integrated RDNA 3.5) |
| RAM | 128 GB LPDDR5X unified memory |
| GPU Memory | Up to 96 GB allocatable under Windows |
| OS | Windows 11 |
| Inference Engine | llama.cpp (Vulkan backend) |
| Model | Qwen3.6-35B-A3B-UD-Q8_K_XL (Unsloth Dynamic high-quality quant, ~39 GB GGUF) |
| IP Address | 192.168.10.10 |
| Port | 8080 |
| FQDN | gravitydrive.helios-1.local |

### Model notes
- Architecture: Mixture-of-Experts (~35B total parameters, ~3B active per token)
- Native context: 256K tokens
- Modalities: text + vision (image/video input supported)
- License: Apache 2.0

## Network & Access

- Primary inference endpoint: `http://gravitydrive.helios-1.local:8080` or `http://192.168.10.10:8080`
- llama.cpp `llama-server` exposes an OpenAI-compatible API:
  - `GET /health` — readiness
  - `GET /v1/models` — loaded model info
  - `POST /v1/chat/completions` — primary chat endpoint (streaming supported)
  - `POST /v1/completions`
  - `POST /v1/embeddings` (when applicable)
- Prefer the FQDN when mDNS/resolution works; fall back to the IP.
- Keep the service on the local network. Do not expose it publicly without authentication and proper controls.
- From NOSTROMO, treat the endpoint as a remote OpenAI-compatible backend (change base URL; no API key required by default unless one is configured).

### Quick verification from Debian
- Build · Qwen3.6-35B llama.cpp @ gravitydrive.helios-1.local:8080
```bash
curl -s http://192.168.10.10:8080/health
curl -s http://192.168.10.10:8080/v1/models