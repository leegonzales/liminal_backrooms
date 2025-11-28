# Liminal Backrooms: Executive Architecture & Security Brief

**Prepared For:** CTO / Technical Leadership
**Date:** November 28, 2025
**Classification:** Internal Technical Review

---

## What Is This?

**Liminal Backrooms** is a Python-based desktop application (~6,000 lines) that orchestrates multi-AI conversations. It enables 1-5 AI models to converse simultaneously via a cyberpunk-themed PyQt6 GUI, with support for image/video generation and conversation branching.

---

## Tech Stack Summary

| Layer | Technology |
|-------|------------|
| Language | Python 3.10-3.11 |
| GUI | PyQt6 |
| AI Providers | Anthropic Claude, OpenRouter (40+ models), OpenAI Sora, Replicate |
| Dependencies | requests, Pillow, networkx, python-dotenv |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                      main.py (1,892 LOC)                │
│     ConversationManager, Worker threads, AI routing     │
├─────────────────────────────────────────────────────────┤
│                      gui.py (3,105 LOC)                 │
│        PyQt6 UI, network visualization, effects         │
├─────────────────────────────────────────────────────────┤
│                  shared_utils.py (958 LOC)              │
│   API integrations (Claude, OpenRouter, Sora, Replicate)│
├─────────────────────────────────────────────────────────┤
│                    config.py (111 LOC)                  │
│          Model definitions, system prompts              │
└─────────────────────────────────────────────────────────┘
```

---

## Critical Security Findings

| Priority | Issue | Business Risk |
|----------|-------|---------------|
| **HIGH** | Conversation data logged to console | Data leakage in shared environments |
| **MEDIUM** | No file validation on uploads | Memory exhaustion, malformed data |
| **MEDIUM** | No rate limiting on API calls | Cost overruns, quota exhaustion |
| **MEDIUM** | Path traversal risk in memory files | Potential unauthorized file access |
| **MEDIUM** | Infinite polling on video generation | Resource hang, poor UX |

---

## Key Risks for Production

1. **Cost Control**: No safeguards against excessive API calls; a bug loop could rapidly consume API credits
2. **Debug Code in Production**: Console logging exposes full conversation histories
3. **Missing Dependencies**: PyQt6 not declared in `pyproject.toml` - installation may fail
4. **No Auth/Multi-tenancy**: Single-user assumption - not suitable for shared/cloud deployment without modification

---

## Strengths

- Clean separation of concerns (UI / Logic / API layer)
- Proper secrets management via `.env` files (not hardcoded)
- Modern async threading model with PyQt signals
- Supports 40+ AI models via OpenRouter abstraction
- Extensible prompt system for different use cases

---

## Recommended Actions (Priority Order)

| # | Action | Effort | Impact |
|---|--------|--------|--------|
| 1 | Remove debug logging of conversations | 1 day | High - eliminates data exposure |
| 2 | Add PyQt6 to pyproject.toml | 1 hour | High - fixes installation |
| 3 | Implement API rate limiting | 2-3 days | High - cost protection |
| 4 | Add file validation (size, type) | 1-2 days | Medium - stability |
| 5 | Add timeout to Sora polling | 2 hours | Medium - reliability |

---

## Bottom Line

The application is **functional and well-structured** for a prototype/internal tool. It requires **2-3 weeks of hardening** before any production or shared-environment deployment. The most urgent concerns are **data exposure via logging** and **missing cost controls** on API usage.

**Recommended path forward:** Address HIGH/MEDIUM security items, add dependency declarations, then evaluate for intended deployment model (desktop vs. cloud).

---

*Full technical details available in the accompanying Senior Engineer Brief.*
