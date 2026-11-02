# NOSTROMO System Inventory

This file is the source of truth for NOSTROMO's hardware, operating system, important configuration, and intentionally installed software. Update it after material hardware, operating-system, service, or application changes.

Last verified against the live server: **2026-11-01**

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

The live inspection found no installed Docker, Podman, libvirt, Cockpit, Node.js, or local-model serving runtime on 2026-11-01.

## Material Configuration

| Configuration | Repository source | Installed location |
| --- | --- | --- |
| Disable NetworkManager Wi-Fi power saving | `config/NetworkManager/wifi-powersave-off.conf` | `/etc/NetworkManager/conf.d/wifi-powersave-off.conf` |
| Disable Intel Wi-Fi driver power saving | `config/modprobe.d/iwlwifi-no-powersave.conf` | `/etc/modprobe.d/iwlwifi-no-powersave.conf` |
| Disable system sleep modes | `config/systemd/sleep.conf.d/10-never-sleep.conf` | `/etc/systemd/sleep.conf.d/10-never-sleep.conf` |
| Ignore idle and sleep-trigger events | `config/systemd/logind.conf.d/10-never-sleep.conf` | `/etc/systemd/logind.conf.d/10-never-sleep.conf` |

## Software Change Record

When software is installed, upgraded outside normal security maintenance, replaced, or removed, add or update its inventory entry above and record the material change here.

| Date | Change | Verification |
| --- | --- | --- |
| 2026-11-02 | Documented the existing `jq` installation used for API verification. | Confirmed the installed Debian package and version on the live server. |
| 2026-11-01 | Created the baseline hardware, operating-system, service, and software inventory. | Compared with the live server over SSH. |
| 2026-10-30 | Disabled Wi-Fi power saving and all system sleep modes to preserve remote availability. | Confirmed driver power saving off, sleep capabilities unavailable, and SSH/XRDP healthy. |
