# Qwen GUI Agent Candidates for NOSTROMO

This document evaluates GUI agent systems that can connect to Qwen3.8-27B on GRAVITYDRIVE, control a web browser, and operate windowed Linux applications such as WordCraft, GridCraft, DeckCraft, LibreOffice, and other ArtCraft tools.

## Candidate Summary

| Rank | GUI agent | Browser | Native Linux applications | Assessment |
| --- | --- | --- | --- | --- |
| 1 | **Open Interpreter Desktop** | Yes | Built-in clicking, typing, menus, and dialogs | Best immediate desktop operator |
| 2 | **Hermes Desktop** | Yes | Through `computer-use-linux` | Best permanent autonomous NOSTROMO agent |
| 3 | **Agent Zero** | Built-in visual browser | Full isolated Linux desktop | Best safe experimentation environment |
| 4 | **Craft Agents** | Excellent built-in Chromium | Requires HCU or another computer-use MCP | Best Codex-like work interface |
| 5 | **Pan-Agent Desktop** | Built-in Chromium | Native screenshots, OCR, mouse, keyboard, and window control | Promising lightweight alternative |

## 1. Open Interpreter Desktop

Open Interpreter Desktop is probably the closest direct match for controlling the NOSTROMO desktop. It is specifically designed to work across browser tabs, files, spreadsheets, documents, PDFs, and graphical desktop applications.

### Capabilities

- Runs as a graphical desktop application on Linux.
- Opens and operates applications using clicks, typing, menus, and dialogs.
- Performs workflows spanning several applications.
- Controls browser sessions and web applications.
- Reads and edits files inside explicitly selected workspaces.
- Supports PDFs, DOCX documents, spreadsheets, text, and images.
- Supports MCP servers and built-in integrations.
- Includes approval controls for actions that submit, send, delete, or overwrite information.
- Supports voice operation.
- Supports OpenAI, OpenRouter, Ollama, LM Studio, NVIDIA, and arbitrary OpenAI-compatible endpoints.

### Qwen and GRAVITYDRIVE fit

Open Interpreter can be pointed at the OpenAI-compatible llama.cpp endpoint on GRAVITYDRIVE. The intended model is `Qwen3.8-27B`.

The exact endpoint and model configuration must be tested against the installed Open Interpreter version. No assumption should be made that every Responses API feature is used; Open Interpreter may use Chat Completions internally.

### Strengths

- Desktop control is a core capability rather than an extension added afterward.
- Directly matches the requirement to operate ArtCraft and other graphical Linux applications.
- Provides a straightforward GUI for watching and approving actions.
- Supports a remote local model without requiring Ollama.

### Limitations and risks

- Linux desktop permissions and dependencies vary by desktop environment.
- Full capability depends on reliable screen interpretation and accessibility information.
- Operating real applications under the `pilot` session means the agent acts with that user's access.
- Qwen's performance on long, multi-application workflows still requires validation.

### Assessment

**Best candidate for the first hands-on test of direct browser and ArtCraft control.**

Official documentation:

- <https://www.openinterpreter.com/docs/desktop>
- <https://www.openinterpreter.com/docs/desktop/install>

## 2. Hermes Desktop and Hermes Agent

Hermes Desktop is the graphical interface for Hermes Agent, an open-source, persistent agent system from Nous Research. It is aimed at becoming a long-running personal agent rather than only a coding assistant or chat interface.

### Capabilities

- Native desktop GUI for Linux.
- Persistent conversations, memory, and user profiles.
- Creates and improves reusable skills from completed work.
- Supports scheduled and unattended jobs.
- Supports subagents and parallel work.
- Provides terminal, filesystem, browser, MCP, and external-service tools.
- Can be accessed through messaging platforms in addition to the desktop GUI.
- Supports local, Docker, SSH, and remote execution backends.
- Can connect to custom OpenAI-compatible model endpoints.
- Can use `computer-use-linux` for desktop application control.

### Native computer control

The `computer-use-linux` MCP server provides:

- Linux accessibility-tree inspection through AT-SPI.
- Screenshot capture.
- Mouse movement and clicking.
- Keyboard input.
- Window and compositor targeting.
- X11 and Wayland support.

This gives Hermes a path to operating ArtCraft applications, LibreOffice, file managers, terminals, and other graphical Linux software.

### Qwen and GRAVITYDRIVE fit

Hermes supports custom OpenAI-compatible endpoints. The intended configuration will point Hermes at the llama.cpp service on GRAVITYDRIVE and select `Qwen3.8-27B`.

Qwen has already demonstrated the core prerequisites:

- Text generation through the Responses API.
- Multimodal image input.
- Screenshot text recognition.
- Structured function calls.
- Valid JSON tool arguments.
- Correct streaming tool-call events.

The complete Hermes-to-Qwen-to-desktop-control loop has not yet been tested.

### Strengths

- Best alignment with the long-term goal of an always-running autonomous NOSTROMO operator.
- Strong memory, skills, scheduling, and remote-command capabilities.
- Designed to improve its procedures over time.
- Can continue running independently of the desktop GUI.
- Supports multiple interfaces and remote gateways.

### Limitations and risks

- More components and configuration than Open Interpreter.
- Desktop operation depends on the separate `computer-use-linux` integration.
- Persistent memory and self-created skills require review so incorrect procedures do not become reusable behavior.
- Unattended workflows require carefully scoped permissions and approval policies.

### Assessment

**Best long-term candidate for the permanent autonomous NOSTROMO agent.**

Official documentation:

- <https://hermes-agent.nousresearch.com/docs>
- <https://github.com/NousResearch/hermes-agent>

## 3. Agent Zero

Agent Zero is an open-source agent platform with a graphical web interface and a complete Linux desktop embedded beside the conversation. It is designed to give an agent its own working computer rather than immediately handing it unrestricted control of the host desktop.

### Capabilities

- Linux, Windows, and macOS launcher applications.
- Browser-based graphical control interface.
- Built-in visual browser with form filling, uploads, screenshots, and annotations.
- Full Linux graphical desktop displayed in the UI canvas.
- Allows the user to watch or take over with a mouse and keyboard.
- Can operate LibreOffice, Blender, terminals, file managers, and other desktop applications.
- Built-in document, spreadsheet, and presentation workflows.
- Project-specific files, instructions, memory, secrets, and model settings.
- Skills, plugins, MCP support, and multi-agent delegation.
- Supports local model servers.
- Provides workspace snapshots and rollback through its Time Travel feature.

### Isolation model

Agent Zero normally operates inside its own Docker-based Linux workspace. That is useful for testing because the agent can use a complete desktop without immediately controlling the real NOSTROMO session.

To use ArtCraft applications, they would need to be installed inside the Agent Zero workspace, or Agent Zero would need carefully scoped host access. Its A0 connector can provide host files, commands, and browser access, but this expands its authority beyond the isolated workspace.

### Qwen and GRAVITYDRIVE fit

Agent Zero accepts local model servers and configurable providers. Compatibility with the existing llama.cpp service should be verified with a small text test, a tool-call test, and a vision test before enabling desktop workflows.

### Strengths

- Strong visual interface for observing the agent.
- The isolated desktop reduces the immediate blast radius of experimentation.
- Browser, desktop applications, and office-document work are already first-class use cases.
- The user can take control of the desktop during a task.
- Snapshot and rollback features improve recoverability.

### Limitations and risks

- The normal desktop is a containerized workspace rather than the actual NOSTROMO desktop.
- ArtCraft installation and graphical compatibility inside the workspace need verification.
- Granting host access weakens the isolation advantage.
- Docker adds storage, networking, and operational complexity.

### Assessment

**Best candidate for safe, observable experimentation in an isolated Linux desktop.**

Official project:

- <https://github.com/agent0ai/agent-zero>

## 4. Craft Agents

Craft Agents is an open-source graphical agent workspace resembling a modern Codex or Claude Code desktop interface. It combines conversations, sessions, files, terminal tools, diffs, sources, MCP integrations, and an agent-controlled browser.

### Capabilities

- Native Linux AppImage.
- Multi-session graphical workspace.
- File editing, shell commands, and source integrations.
- Multiple permission modes.
- Skills and background tasks.
- MCP servers, REST APIs, and local filesystem sources.
- Built-in Chromium browser controlled directly by the agent.
- Browser navigation, clicks, form filling, keyboard input, JavaScript execution, screenshots, DOM inspection, and network inspection.
- Supports custom endpoints and llama.cpp-compatible models.
- Supports multimodal models when image support is explicitly enabled.

### Native computer control

Craft's built-in browser is comprehensive, but Craft Agents does not by itself provide equally comprehensive control of arbitrary native Linux applications. Native application control would be supplied through an MCP server such as Microsoft Hybrid Computer Use.

Microsoft HCU provides:

- Accessibility-tree inspection and actions.
- Screenshot-based visual operation.
- Mouse and keyboard input.
- Linux support through AT-SPI2, X11, and XTest.
- Batched actions and state differences to reduce repeated full-screen image processing.

### Qwen and GRAVITYDRIVE fit

Craft Agents documents support for llama.cpp and custom OpenAI-compatible endpoints. Qwen image support must be enabled explicitly because Craft does not automatically assume arbitrary endpoints are multimodal.

### Strengths

- Most similar to the modern Codex graphical work experience.
- Excellent integrated browser automation.
- Strong source, filesystem, terminal, session, and diff interfaces.
- MCP support provides a path to native desktop control.
- Suitable for supervised technical and development work.

### Limitations and risks

- Native desktop operation requires an additional computer-use MCP integration.
- It is more naturally a project and coding workspace than a persistent whole-machine personal agent.
- HCU integration with Qwen and Craft must be assembled and validated.
- Remote browser behavior differs from local browser behavior and requires the desktop client.

### Assessment

**Best Codex-like graphical work interface, with native application control added through HCU.**

Official documentation:

- <https://thecraftagents.com/>
- <https://thecraftagents.com/docs/browser/overview/>
- <https://thecraftagents.com/docs/getting-started/installation/>
- <https://microsoft.github.io/Hybrid-Computer-Use/>

## 5. Pan-Agent Desktop

Pan-Agent is a smaller open-source desktop agent implemented as a Go backend with a Tauri graphical application. It is intended to provide direct computer control without requiring Python, Node.js, or Docker at runtime.

### Capabilities

- Native desktop application for Linux, Windows, and macOS.
- Connects to OpenAI-compatible providers, including llama.cpp, Ollama, LM Studio, and custom endpoints.
- Built-in Chromium browser.
- Filesystem, terminal, and code-execution tools.
- Screen capture and OCR.
- Keyboard and mouse input.
- Window management.
- Vision tools.
- Persistent memory and isolated profiles.
- Scheduled jobs.
- Telegram, Discord, and Slack interfaces.
- Headless HTTP API for scripting.
- Approval patterns intended to catch dangerous commands.

### Linux computer control

Pan-Agent's Linux PC-control implementation uses X11 XTest and EWMH. This makes it a possible match for an X11 desktop, including many RDP-backed Linux sessions. The current NOSTROMO session type must be verified rather than assumed.

### Qwen and GRAVITYDRIVE fit

Pan-Agent explicitly supports llama.cpp and custom OpenAI-compatible endpoints. The setup wizard can fetch the model list from the configured endpoint, after which `Qwen3.8-27B` should be selectable.

### Strengths

- Direct desktop control is built in.
- Lightweight deployment with no Docker and no large runtime stack.
- Explicit support for llama.cpp.
- Includes browser, OS control, memory, schedules, and remote messaging.
- Open-source and self-hosted.

### Limitations and risks

- Younger and less proven than the leading candidates.
- Linux graphical control currently centers on X11.
- Its safety controls need independent testing before unattended operation.
- Model compatibility claims do not guarantee that Qwen will reliably complete long desktop tasks.

### Assessment

**Promising lightweight alternative, especially if NOSTROMO uses an X11 session.**

Official project:

- <https://github.com/Euraika-Labs/pan-agent>

## Recommended Evaluation Order

1. **Open Interpreter Desktop** — test direct control of Chromium and one harmless ArtCraft application.
2. **Hermes Desktop** — test the complete persistent-agent workflow and `computer-use-linux` integration.
3. **Agent Zero** — evaluate isolated desktop operation, observation, and recoverability.
4. **Craft Agents with HCU** — evaluate the Codex-like interface and MCP-based native application control.
5. **Pan-Agent Desktop** — evaluate as a lightweight fallback or alternative.

## Initial Acceptance Tests

Each candidate should be tested with the same controlled tasks:

1. Connect to GRAVITYDRIVE and confirm that `Qwen3.8-27B` answers a simple text prompt.
2. Send a screenshot and confirm that Qwen receives and interprets the image.
3. Execute a harmless structured tool call and validate its arguments.
4. Open Chromium and navigate to a non-sensitive test page.
5. Read the page using structured browser or accessibility information.
6. Fill out a local or disposable form without submitting it externally.
7. Open one ArtCraft application.
8. Create a disposable test document containing a known phrase.
9. Save the document to a temporary test directory.
10. Reopen the document and verify its contents.
11. Confirm that the user can pause, interrupt, or take over from the agent.
12. Confirm that destructive or externally visible actions require approval.

No shutdown, reboot, suspend, network disruption, privilege change, service interruption, or other availability-impacting operation should be part of these tests.

## Current Qwen Validation Status

The following capabilities have already been validated against the Qwen3.8-27B llama.cpp server:

- The health endpoint returned `{"status":"ok"}`.
- The model endpoint reported `Qwen3.8-27B` with completion and multimodal capabilities.
- Text generation through the Responses API completed successfully.
- Streaming output completed successfully.
- Per-request disabling of thinking worked.
- Structured function calling produced the correct function name.
- Function arguments were valid JSON.
- Streaming function-call events were correctly formed.
- Image input worked through a vision test.
- Screenshot text recognition was accurate.

The vision test did not perfectly identify the source application shown in the screenshot. Therefore, the transport and visual-reading path are working, but accurate semantic understanding of arbitrary desktop applications is not yet proven.

## Overall Recommendation

- Use **Open Interpreter Desktop** for the first direct browser-and-application proof of concept.
- Use **Hermes Desktop and Hermes Agent** as the leading candidate for the eventual persistent autonomous NOSTROMO operator.
- Use **Agent Zero** when isolation and recoverability are more important than controlling the existing host desktop.
- Use **Craft Agents with Microsoft HCU** when the preferred experience is a Codex-style project workspace.
- Keep **Pan-Agent Desktop** as a lightweight native-control alternative.

The final selection must be based on repeatable tests with Qwen3.8-27B. Successful vision and tool-call tests establish that Qwen has the necessary interfaces, but they do not by themselves prove reliable long-duration control of browsers and native Linux applications.
