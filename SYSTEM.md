# NOSTROMO System Inventory

This file is the source of truth for NOSTROMO's hardware, operating system, important configuration, and intentionally installed software. Update it after material hardware, operating-system, service, or application changes.

Last verified against the live server: **2026-11-04**

## Hardware

| Component | Details |
| --- | --- |
| System | HP Pro Mini 400 G9 Desktop PC, x86-64 bare metal |
| Firmware | HP U23 version 02.23.00, dated 2026-07-27 |
| Processor | 12th Gen Intel Core i5-12500T |
| CPU capacity | 6 physical cores / 12 logical CPUs, up to 4.4 GHz |
| CPU capabilities | AVX, AVX2, FMA, AVX-VNNI, AES, SHA, and VT-x |
| Memory | 16 GB installed; approximately 15 GiB usable |
| Swap | Approximately 16 GB |
| Storage | 512 GB SK hynix PC801 NVMe SSD |
| Graphics | Intel UHD Graphics 770 integrated GPU |
| Ethernet | Intel Ethernet Connection I219-LM |
| Wireless | Intel Alder Lake-S CNVi Wi-Fi |
| Discrete accelerator | None; do not assume NVIDIA CUDA or dedicated GPU memory |

## Operating System

| Item | Current state |
| --- | --- |
| Distribution | Debian GNU/Linux 13 (Trixie); Debian version 13.7 last observed |
| Kernel | Linux 6.12.113+deb13-amd64 |
| Hostname | `nostromo.local` |
| Desktop | KDE Plasma 6.3.6 using XRDP/Xorg for remote sessions |
| Root filesystem | ext4, 453 GiB filesystem capacity |
| EFI system partition | vfat, approximately 976 MiB |

Addresses, utilization, free capacity, package revisions, and kernel versions are operational state. Re-check them before capacity-sensitive work, upgrades, or troubleshooting.

## Network and Remote Access

| Component | State |
| --- | --- |
| Primary connection | Wi-Fi through NetworkManager |
| Ethernet | Present but currently unavailable/down |
| SSH | OpenSSH Server enabled and active |
| Remote desktop | XRDP and xrdp-sesman enabled and active |
| Wi-Fi power saving | Disabled globally in NetworkManager |
| Intel Wi-Fi driver power saving | Disabled for `iwlwifi` and `iwlmvm` |
| System sleep | Suspend, hibernate, hybrid sleep, and suspend-then-hibernate disabled and masked |

Do not record Wi-Fi credentials, private keys, tokens, or other secrets in this file or repository.

## Installed Software

Record software that was intentionally installed or materially configured for server operation, development, remote access, AI experimentation, or automation. Do not duplicate the complete Debian dependency list.

| Software | Version observed | Purpose | Service state |
| --- | --- | --- | --- |
| OpenSSH Server | 10.0p1-7+deb13u4 | Secure remote administration | Enabled and active |
| NetworkManager | 1.52.1-1 | Network and Wi-Fi management | Enabled and active |
| XRDP | 0.10.1-3.1+deb13u2 | Remote desktop service | Enabled and active |
| xorgxrdp | 0.10.2-1 | Xorg backend for XRDP | Used by XRDP sessions |
| KDE Plasma Desktop | 6.3.6 | Graphical desktop environment | Available through XRDP |
| Git | 2.47.3 | Source control | Command-line tool |
| Python | 3.13.5 | Scripting and automation | Command-line runtime |
| curl | 8.14.1-2+deb13u7 | HTTP and transfer diagnostics | Command-line tool |
| wget | 1.25.0-2 | File retrieval | Command-line tool |
| jq | 1.7.1-6+deb13u4 | JSON inspection for API and service diagnostics | Command-line tool |
| Codex CLI (ChatGPT desktop bundle) | 0.166.0-alpha.5.1 | Agent harness for GRAVITYDRIVE-hosted Qwen3.8 | Bundled command-line tool |
| Debian build-essential | 12.12 | Native build toolchain required to package Hermes Desktop | Command-line toolchain |
| Hermes Agent and Hermes Desktop | 0.22.7 | Persistent AI agent runtime and graphical desktop interface | Installed for `pilot` under `/opt/var/hermes`; not running as a service |
| Hermes Computer Use (`cua-driver`) | 0.21.0 | On-demand AT-SPI, X11 input, and screen-capture control for Hermes | Toolset enabled; driver starts on demand; upstream Linux support is alpha |

The live inspection found no installed Docker, Podman, libvirt, Cockpit, Node.js, or local-model serving runtime on 2026-11-01.

Hermes manages its own pinned Python, Node.js, Chromium, FFmpeg, ripgrep, npm, and uv dependencies under `~/.hermes`; these are application-managed runtimes rather than system packages.

## Material Configuration

| Configuration | Repository source | Installed location |
| --- | --- | --- |
| Disable NetworkManager Wi-Fi power saving | `config/NetworkManager/wifi-powersave-off.conf` | `/etc/NetworkManager/conf.d/wifi-powersave-off.conf` |
| Disable Intel Wi-Fi driver power saving | `config/modprobe.d/iwlwifi-no-powersave.conf` | `/etc/modprobe.d/iwlwifi-no-powersave.conf` |
| Disable system sleep modes | `config/systemd/sleep.conf.d/10-never-sleep.conf` | `/etc/systemd/sleep.conf.d/10-never-sleep.conf` |
| Ignore idle and sleep-trigger events | `config/systemd/logind.conf.d/10-never-sleep.conf` | `/etc/systemd/logind.conf.d/10-never-sleep.conf` |
| GRAVITYDRIVE Codex provider | `CODEX_LLAMA_CPP.md` | `~/.codex/config.toml` |
| Qwen-backed Codex launcher | `scripts/qwen` | `/usr/local/bin/qwen` |
| GRAVITYDRIVE Hermes provider and auxiliary routing | `HERMES.md` | `~/.hermes/config.yaml` |
| Hermes XRDP/X11 same-user authorization helper | `scripts/hermes-x11-access` | `/opt/var/hermes/bin/hermes-x11-access` |
| Hermes XRDP/X11 KDE autostart | `config/autostart/hermes-x11-access.desktop` | `~/.config/autostart/hermes-x11-access.desktop` |

## Software Change Record

When software is installed, upgraded outside normal security maintenance, replaced, or removed, add or update its inventory entry above and record the material change here.

| Date | Change | Verification |
| --- | --- | --- |
| 2026-11-04 | Configured the named Hermes provider `gravitydrive` for credential-free `Qwen3.8-27B` inference at `http://gravitydrive.local:8080/v1`. Pinned the verified 262,144-token context, disabled Qwen thinking, enabled native vision metadata, routed all current auxiliary LLM tasks explicitly to `custom:gravitydrive`, and retained an empty fallback chain. Installed a same-user KDE/X11 authorization helper required by `cua-driver` under XRDP. | Verified live backend health and model metadata, exact text inference, structured terminal tool execution, Computer Use screenshot capture, local vision processing, configuration validity, and successful `CAPTURE_OK` completion without mouse or keyboard input. |
| 2026-11-03 | Installed and enabled the pinned Hermes Computer Use driver v0.21.0. Kept telemetry disabled and cleared the temporary package opt-out from the staged Step 1 installation. | `hermes computer-use doctor` passed the binary, platform, MCP session, AT-SPI/X11 input, and screen-capture checks against the active XRDP/X11 desktop. |
| 2026-11-03 | Installed Hermes Agent v0.22.7 and built Hermes Desktop for `pilot`, with the replaceable checkout under `/opt/var/hermes` and user state under `~/.hermes`. Computer Use was explicitly excluded for the separate second deployment step, and GRAVITYDRIVE was not configured. | Verified the Hermes CLI release and policy-compliant install path, exact Git release tag, packaged Desktop executable and application launcher, managed dependency health, resolved shared libraries, absence of `cua-driver`, and no running Hermes process. |
| 2026-11-03 | Configured the credential-free GRAVITYDRIVE provider and installed the `qwen` launcher for an independent Qwen3.8-backed Codex instance. | Validated TOML, endpoint health, launcher syntax and permissions, provider/model selection, and an end-to-end exact-response inference test. |
| 2026-11-02 | Documented the existing `jq` installation used for API verification. | Confirmed the installed Debian package and version on the live server. |
| 2026-11-01 | Created the baseline hardware, operating-system, service, and software inventory. | Compared with the live server over SSH. |
| 2026-10-30 | Disabled Wi-Fi power saving and all system sleep modes to preserve remote availability. | Confirmed driver power saving off, sleep capabilities unavailable, and SSH/XRDP healthy. |
