# GRAVITYDRIVE Benchmarks

This file records bounded, reproducible inference checks used by the NOSTROMO project. Results describe the observed configuration at the stated time; model, server, cache, concurrency, and network changes can alter later measurements.

## 2026-11-12 — Gufo Qwen3.8 Flash-Next

### Live discovery

| Item | Observed value |
| --- | --- |
| Health | `ok` |
| Model identifier | `Gufo_Qwen3.8_Flash-Next` |
| Context length | 131,072 tokens |
| Input modalities | Text and image |
| API | OpenAI-compatible Chat Completions |

### Direct generation benchmark

The request originated on NOSTROMO and targeted the GRAVITYDRIVE chat-completions endpoint over the internal network. It requested an ascending integer sequence, disabled thinking, used temperature 0, and capped output at 256 tokens. Server timing data was requested and returned.

| Metric | Result |
| --- | ---: |
| Prompt tokens | 37 |
| Completion tokens | 256 |
| Total tokens | 293 |
| Prompt processing | 219.10 tokens/second |
| Generation | 100.93 tokens/second |
| Time to first token | 174.7 ms |
| Decode time | 2.536 seconds |
| End-to-end HTTP wall time | 2.783 seconds |
| Mean inter-token time | 9.99 ms |
| Draft tokens | 224 |
| Draft tokens accepted | 223 |
| Cache state | Miss; no compatible boundary |
| Finish reason | Length limit |
| Queue time | 5.7 ms |
| Execution plan | Serial fallback; logical concurrency 2, physical width 1 |

This was a bounded functional speed check, not a saturation, concurrency, long-context, vision, or quality benchmark.

### Hermes integration result

Hermes Agent `0.23.1` passed configuration and dependency diagnostics and resolved its main provider and all 19 auxiliary routes to GRAVITYDRIVE. Initial verification found that Hermes still requested `Qwen3.8-27B` with a 262,144-token context, which the live backend rejected with HTTP 404.

The configuration was then aligned with `Gufo_Qwen3.8_Flash-Next` and 131,072 tokens in both the main model block and the named GRAVITYDRIVE provider. A fresh no-reasoning Hermes one-shot returned the exact response `HERMES_MODEL_ALIGNMENT_OK` in one API call. It reported the `custom` provider, the correct model identifier, 16,188 input tokens, 5 output tokens, and 7.127 seconds total wall time including Hermes startup and project-context loading. The pre-change configuration and post-change usage record were preserved with mode `0600`.

### Tool verification summary

Hermes Doctor registered its primary browser, web research, terminal, file, code-execution, Computer Use, desktop, vision, project, skill, memory, session, delegation, scheduling, and task-management tools. Optional tools without their required dependency or credential were reported separately and are not counted as failures of the configured local-inference path.
