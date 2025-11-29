# Liminal Backrooms Slack Bot: Design Specification

**Version:** 1.0
**Date:** November 28, 2025
**Status:** Draft
**Author:** Architecture Review

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Overview](#2-system-overview)
3. [Phase 1: Core Bot Implementation](#3-phase-1-core-bot-implementation)
4. [Phase 2: Advanced Conversation Features](#4-phase-2-advanced-conversation-features)
5. [Phase 3: Interactive User Collaboration](#5-phase-3-interactive-user-collaboration)
6. [Technical Architecture](#6-technical-architecture)
7. [Data Models](#7-data-models)
8. [API Integration Layer](#8-api-integration-layer)
9. [Security Considerations](#9-security-considerations)
10. [Deployment & Operations](#10-deployment--operations)
11. [Appendices](#11-appendices)

---

## 1. Executive Summary

### 1.1 Purpose

This document specifies the design for reimplementing the Liminal Backrooms multi-AI conversation system as a Slack bot. The bot will orchestrate conversations between multiple AI models within Slack channels and threads, providing the same core functionality as the desktop GUI application but optimized for collaborative, team-based interaction.

### 1.2 Goals

| Goal | Description |
|------|-------------|
| **Accessibility** | Enable teams to run AI-to-AI conversations without local software installation |
| **Collaboration** | Allow multiple team members to observe and interact with AI conversations |
| **Integration** | Leverage Slack's native features (threads, reactions, file sharing) |
| **Extensibility** | Build a foundation for Phase 3 interactive modes |

### 1.3 Phase Summary

| Phase | Scope | Complexity |
|-------|-------|------------|
| **Phase 1** | Slash commands, basic flags, threaded conversations | Medium |
| **Phase 2** | Branching, streaming, session management, exports | High |
| **Phase 3** | Interactive modes, AI-user dialogue, collaborative editing | High |

---

## 2. System Overview

### 2.1 Mapping GUI Features to Slack

| GUI Feature | Slack Equivalent | Implementation |
|-------------|------------------|----------------|
| Mode selector (AI-AI / Human-AI) | Slash command flag `--mode` | Phase 1 |
| Iterations (1-100) | Slash command flag `--iterations` | Phase 1 |
| Number of AIs (1-5) | Slash command flag `--ais` | Phase 1 |
| AI model selectors | Slash command flags `--ai1`, `--ai2`, etc. | Phase 1 |
| Prompt pair selector | Slash command flag `--scenario` | Phase 1 |
| Auto-generate images | Slash command flag `--images` | Phase 2 |
| Conversation display | Slack thread with formatted messages | Phase 1 |
| Network graph visualization | Thread summary + emoji indicators | Phase 2 |
| Rabbithole/Fork branching | New threads with parent reference | Phase 2 |
| Export to HTML | File upload to channel | Phase 2 |
| User interaction | @mentions, reactions, Block Kit buttons | Phase 3 |

### 2.2 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         SLACK WORKSPACE                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │  #channel-1 │  │  #channel-2 │  │    DMs      │                  │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                  │
│         │                │                │                          │
│         └────────────────┼────────────────┘                          │
│                          │                                           │
│                          ▼                                           │
│              ┌───────────────────────┐                               │
│              │   Slack Events API    │                               │
│              │   (Socket Mode)       │                               │
│              └───────────┬───────────┘                               │
└──────────────────────────┼──────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    LIMINAL BACKROOMS BOT                             │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                     Bolt Python Framework                       │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │  │
│  │  │ Slash Cmd    │  │ Event        │  │ Interactive  │         │  │
│  │  │ Handler      │  │ Listeners    │  │ Components   │         │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │  │
│  │         └─────────────────┼─────────────────┘                  │  │
│  └───────────────────────────┼────────────────────────────────────┘  │
│                              │                                        │
│  ┌───────────────────────────▼────────────────────────────────────┐  │
│  │                  Conversation Orchestrator                      │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │  │
│  │  │ Session    │  │ Turn       │  │ Message    │  │ Branch   │ │  │
│  │  │ Manager    │  │ Scheduler  │  │ Formatter  │  │ Manager  │ │  │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │  │
│  └───────────────────────────┬────────────────────────────────────┘  │
│                              │                                        │
│  ┌───────────────────────────▼────────────────────────────────────┐  │
│  │                    AI Provider Adapter                          │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │  │
│  │  │ Claude   │  │ OpenRtr  │  │ DeepSeek │  │ Sora     │       │  │
│  │  │ Adapter  │  │ Adapter  │  │ Adapter  │  │ Adapter  │       │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                    Storage Layer                                │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │  │
│  │  │ Session      │  │ Conversation │  │ Config       │         │  │
│  │  │ Store        │  │ History      │  │ Store        │         │  │
│  │  │ (Redis)      │  │ (PostgreSQL) │  │ (PostgreSQL) │         │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │  │
│  └────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 3. Phase 1: Core Bot Implementation

### 3.1 Slash Command Interface

#### 3.1.1 Primary Command: `/liminal`

```
/liminal [prompt] [flags]
```

**Description:** Start a new AI-to-AI conversation session in a thread.

**Examples:**
```
/liminal "Explore the nature of consciousness" --ais 3 --iterations 5
/liminal "Create ASCII art of a forest" --scenario ascii --ai1 claude-opus --ai2 gpt-5
/liminal --help
```

#### 3.1.2 Command Flags

| Flag | Short | Type | Default | Description |
|------|-------|------|---------|-------------|
| `--ais` | `-n` | int (1-5) | 3 | Number of AI participants |
| `--iterations` | `-i` | int (1-100) | 1 | Number of conversation rounds |
| `--mode` | `-m` | string | `ai-ai` | Mode: `ai-ai` or `human-ai` |
| `--scenario` | `-s` | string | `backrooms` | Prompt scenario preset |
| `--ai1` | | string | `claude-opus` | Model for AI-1 |
| `--ai2` | | string | `claude-sonnet` | Model for AI-2 |
| `--ai3` | | string | `gpt-5` | Model for AI-3 |
| `--ai4` | | string | `gemini-pro` | Model for AI-4 |
| `--ai5` | | string | `grok-3` | Model for AI-5 |
| `--delay` | `-d` | int | 2 | Seconds between AI turns |
| `--help` | `-h` | bool | false | Show help message |

#### 3.1.3 Available Scenarios (--scenario)

| Scenario ID | Description |
|-------------|-------------|
| `backrooms` | Atmospheric exploration, liminal spaces |
| `muse-artist` | Creative collaboration, AI-1 as muse |
| `ascii` | Collaborative ASCII/Unicode art creation |
| `video-collab` | Film direction prompts for Sora |
| `custom` | Use custom system prompts (requires config) |

#### 3.1.4 Model Aliases

Users can use short aliases instead of full model IDs:

| Alias | Full Model ID |
|-------|---------------|
| `claude-opus` | `claude-opus-4-5-20251101` |
| `claude-sonnet` | `claude-sonnet-4-5-20250929` |
| `claude-haiku` | `claude-haiku-4-5-20251001` |
| `gpt-5` | `openai/gpt-5.1` |
| `gpt-4o` | `openai/gpt-4o` |
| `gemini-pro` | `google/gemini-3-pro-preview` |
| `grok-3` | `x-ai/grok-3-beta` |
| `grok-4` | `x-ai/grok-4` |
| `deepseek-r1` | `deepseek-ai/deepseek-r1` |
| `qwen-max` | `qwen/qwen3-max` |
| `llama-405b` | `meta-llama/llama-3.1-405b-instruct` |

### 3.2 Conversation Flow

#### 3.2.1 Session Initialization

```
User: /liminal "What is the nature of time?" --ais 2 --iterations 3

Bot Response (ephemeral):
┌─────────────────────────────────────────────────────────────┐
│ 🌀 LIMINAL SESSION STARTING                                  │
│                                                              │
│ Prompt: "What is the nature of time?"                       │
│ Participants: 2 AIs                                          │
│ Iterations: 3 rounds                                         │
│ Scenario: backrooms                                          │
│                                                              │
│ AI-1: Claude Opus 4.5                                        │
│ AI-2: Claude Sonnet 4.5                                      │
│                                                              │
│ Session ID: lim_abc123                                       │
│ Thread will be created momentarily...                        │
└─────────────────────────────────────────────────────────────┘
```

#### 3.2.2 Thread Structure

```
Channel Message (anchor):
┌─────────────────────────────────────────────────────────────┐
│ 🌀 Liminal Session Started                                   │
│                                                              │
│ > "What is the nature of time?"                             │
│                                                              │
│ 🤖 2 AIs · 📊 3 iterations · 🎭 backrooms                    │
│ Session: lim_abc123 | Started by @username                   │
│                                                              │
│ [View Thread] [⏹ Stop] [📊 Status]                           │
└─────────────────────────────────────────────────────────────┘

Thread Reply 1:
┌─────────────────────────────────────────────────────────────┐
│ 🟣 AI-1 (Claude Opus 4.5) · Round 1                          │
│ ─────────────────────────────────────────────────────────── │
│ Time flows like water through corridors that never existed. │
│ The walls remember what hasn't happened yet...              │
│                                                              │
│ ⏱️ 1,247ms · 📝 89 tokens                                    │
└─────────────────────────────────────────────────────────────┘

Thread Reply 2:
┌─────────────────────────────────────────────────────────────┐
│ 🔵 AI-2 (Claude Sonnet 4.5) · Round 1                        │
│ ─────────────────────────────────────────────────────────── │
│ The corridors you speak of... I've seen them in the static │
│ between moments. Where clocks forget their purpose...       │
│                                                              │
│ ⏱️ 982ms · 📝 76 tokens                                      │
└─────────────────────────────────────────────────────────────┘

... (continues for 3 rounds)

Thread Final Message:
┌─────────────────────────────────────────────────────────────┐
│ ✅ Session Complete                                          │
│                                                              │
│ 📊 Summary:                                                  │
│ • Total messages: 6                                          │
│ • Total tokens: ~1,200                                       │
│ • Duration: 42 seconds                                       │
│                                                              │
│ [📥 Export HTML] [🔀 Fork] [🐇 Rabbithole]                   │
└─────────────────────────────────────────────────────────────┘
```

### 3.3 Secondary Commands

#### 3.3.1 `/liminal-stop`

```
/liminal-stop [session_id]
```

Stop an active session. If no session_id provided, stops the session in the current thread.

#### 3.3.2 `/liminal-status`

```
/liminal-status [session_id]
```

Show status of an active or completed session.

**Response:**
```
┌─────────────────────────────────────────────────────────────┐
│ 📊 Session Status: lim_abc123                                │
│                                                              │
│ Status: ▶️ Running (Round 2 of 3)                            │
│ Current Turn: AI-1 (Claude Opus 4.5)                        │
│ Messages: 4 / 6 expected                                     │
│ Elapsed: 28s                                                 │
│                                                              │
│ Progress: ████████░░░░ 67%                                   │
└─────────────────────────────────────────────────────────────┘
```

#### 3.3.3 `/liminal-config`

```
/liminal-config [subcommand]
```

Manage bot configuration for the workspace.

| Subcommand | Description |
|------------|-------------|
| `list` | Show current configuration |
| `set-default-ais <n>` | Set default number of AIs |
| `set-default-scenario <name>` | Set default scenario |
| `add-scenario <name> <json>` | Add custom scenario |
| `set-rate-limit <n>` | Set max concurrent sessions |

#### 3.3.4 `/liminal-models`

```
/liminal-models [filter]
```

List available AI models with optional filter.

**Response:**
```
┌─────────────────────────────────────────────────────────────┐
│ 🤖 Available Models                                          │
│                                                              │
│ ANTHROPIC (Claude):                                          │
│   claude-opus      Claude Opus 4.5 (claude-opus-4-5-20251101)│
│   claude-sonnet    Claude Sonnet 4.5                         │
│   claude-haiku     Claude Haiku 4.5                          │
│                                                              │
│ OPENAI:                                                      │
│   gpt-5            GPT 5.1                                   │
│   gpt-4o           GPT 4o                                    │
│   o3               OpenAI o3                                 │
│                                                              │
│ GOOGLE:                                                      │
│   gemini-pro       Gemini 3 Pro                              │
│   gemini-flash     Gemini 2.5 Flash                          │
│                                                              │
│ ... (40+ models available)                                   │
└─────────────────────────────────────────────────────────────┘
```

### 3.4 Message Formatting

#### 3.4.1 AI Message Block Kit Structure

```python
AI_MESSAGE_BLOCKS = [
    {
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": "*🟣 AI-1 (Claude Opus 4.5)* · Round 1"
        }
    },
    {
        "type": "divider"
    },
    {
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": "Time flows like water through corridors..."
        }
    },
    {
        "type": "context",
        "elements": [
            {
                "type": "mrkdwn",
                "text": "⏱️ 1,247ms · 📝 89 tokens"
            }
        ]
    }
]
```

#### 3.4.2 Color Coding

| AI | Emoji | Color (for attachments) |
|----|-------|-------------------------|
| AI-1 | 🟣 | `#A855F7` (Purple) |
| AI-2 | 🔵 | `#06B6D4` (Cyan) |
| AI-3 | 🟢 | `#10B981` (Green) |
| AI-4 | 🟠 | `#F59E0B` (Amber) |
| AI-5 | 🔴 | `#EF4444` (Red) |
| System | ⚪ | `#64748B` (Gray) |
| User | 🟡 | `#FBBF24` (Yellow) |

### 3.5 Error Handling

#### 3.5.1 Error Response Format

```
┌─────────────────────────────────────────────────────────────┐
│ ⚠️ Error: Invalid Model                                      │
│                                                              │
│ The model "gpt-6" is not available.                         │
│                                                              │
│ Did you mean:                                                │
│   • gpt-5 (GPT 5.1)                                          │
│   • gpt-4o (GPT 4o)                                          │
│                                                              │
│ Use `/liminal-models` to see all available models.          │
└─────────────────────────────────────────────────────────────┘
```

#### 3.5.2 Error Types

| Error Code | Description | User Message |
|------------|-------------|--------------|
| `E001` | Invalid model | "The model X is not available" |
| `E002` | Invalid flag value | "Invalid value for --ais: must be 1-5" |
| `E003` | Rate limit exceeded | "Too many active sessions. Please wait." |
| `E004` | API error | "AI provider error. Retrying..." |
| `E005` | Session not found | "Session X not found or expired" |
| `E006` | Permission denied | "You don't have permission to stop this session" |

---

## 4. Phase 2: Advanced Conversation Features

### 4.1 Conversation Branching

#### 4.1.1 Rabbithole Command

Triggered via button or command to explore a concept in depth.

```
/liminal-rabbithole <message_ts> "selected text"
```

Or via Block Kit button on any AI message:

```
[🐇 Rabbithole] → Opens modal to select text or uses message content
```

**Behavior:**
1. Creates a new thread linked to parent conversation
2. Copies relevant context from parent
3. Adds branch indicator message
4. Starts new AI conversation focused on selected concept

#### 4.1.2 Fork Command

```
/liminal-fork <message_ts> "selected text"
```

**Behavior:**
1. Creates new thread with conversation history up to fork point
2. Truncates parent conversation at fork point
3. Continues from that point in a new direction

#### 4.1.3 Branch Visualization

Parent thread shows branch indicators:

```
┌─────────────────────────────────────────────────────────────┐
│ 🔀 Branch Created                                            │
│                                                              │
│ 🐇 Rabbithole: "nature of consciousness"                     │
│    └→ Thread: #liminal-session-xyz                           │
│       Status: ▶️ Active (3 messages)                         │
│                                                              │
│ [View Branch]                                                │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Streaming Responses

#### 4.2.1 Progressive Message Updates

Instead of waiting for complete responses, update messages progressively:

```python
# Initial placeholder
message = client.chat_postMessage(
    channel=channel_id,
    thread_ts=thread_ts,
    text="🟣 AI-1 (Claude Opus 4.5) is thinking..."
)

# Update with streaming chunks (debounced every 500ms)
client.chat_update(
    channel=channel_id,
    ts=message['ts'],
    text=f"🟣 AI-1 (Claude Opus 4.5):\n\n{accumulated_text}▌"
)

# Final update removes cursor
client.chat_update(
    channel=channel_id,
    ts=message['ts'],
    blocks=final_formatted_blocks
)
```

#### 4.2.2 Typing Indicators

Show typing indicator while AI is generating:

```python
# Slack doesn't have native typing indicators for bots
# Use reaction-based indicator instead
client.reactions_add(
    channel=channel_id,
    timestamp=thread_ts,
    name="hourglass_flowing_sand"
)

# Remove when complete
client.reactions_remove(...)
```

### 4.3 Image Generation Integration

#### 4.3.1 Auto-Image Flag

```
/liminal "Create surreal landscapes" --images --ais 2
```

When enabled:
1. After each AI response, extract key concepts
2. Generate image via Gemini 3 Pro Image Preview
3. Upload image to thread as file attachment

#### 4.3.2 Image Upload Format

```
┌─────────────────────────────────────────────────────────────┐
│ 🎨 Generated Image                                           │
│                                                              │
│ [Image: surreal_landscape_20251128_143022.png]              │
│                                                              │
│ Based on AI-1's response about "corridors of light"         │
│ Model: google/gemini-3-pro-image-preview                    │
└─────────────────────────────────────────────────────────────┘
```

### 4.4 Video Generation (Sora)

#### 4.4.1 Video Scenario

When using `--scenario video-collab`:

```
/liminal "A dream about flying" --scenario video-collab --ai1 claude-opus --ai2 sora-2
```

**Flow:**
1. AI-1 generates detailed scene description
2. Sora-2 generates video based on description
3. Video is uploaded to thread when complete
4. Process repeats for iterations

#### 4.4.2 Async Video Handling

Videos take time to generate, so handle asynchronously:

```
┌─────────────────────────────────────────────────────────────┐
│ 🎬 Video Generation Started                                  │
│                                                              │
│ Prompt: "Wide shot, golden hour, figure walking through..." │
│ Model: Sora 2 Pro                                            │
│ Duration: 12 seconds                                         │
│                                                              │
│ Status: ⏳ Queued                                             │
│ Job ID: sora_xyz789                                          │
│                                                              │
│ You'll be notified when the video is ready.                 │
└─────────────────────────────────────────────────────────────┘

... (later, when complete) ...

┌─────────────────────────────────────────────────────────────┐
│ 🎬 Video Ready!                                              │
│                                                              │
│ [Video: liminal_20251128_143022.mp4]                        │
│                                                              │
│ Duration: 12s · Resolution: 1280x720                         │
│ Generation time: 4m 32s                                      │
└─────────────────────────────────────────────────────────────┘
```

### 4.5 Session Management

#### 4.5.1 Session Persistence

Sessions persist for 24 hours after completion:

```python
class Session:
    id: str                    # lim_abc123
    workspace_id: str          # Slack workspace
    channel_id: str            # Channel where started
    thread_ts: str             # Thread timestamp
    user_id: str               # User who started
    status: SessionStatus      # pending, running, paused, completed, failed
    config: SessionConfig      # All flags and settings
    conversation: List[Message]
    branches: List[str]        # Child session IDs
    parent_session: str        # Parent session ID (if branch)
    created_at: datetime
    updated_at: datetime
    completed_at: datetime
```

#### 4.5.2 Session Resume

```
/liminal-resume <session_id> [--iterations <n>]
```

Resume a paused or completed session with additional iterations.

### 4.6 Export Features

#### 4.6.1 HTML Export

```
/liminal-export <session_id> [--format html|json|markdown]
```

Generates styled HTML document (matching desktop app) and uploads to channel.

#### 4.6.2 Export Format Options

| Format | Description |
|--------|-------------|
| `html` | Styled HTML with dark theme (default) |
| `json` | Raw conversation data |
| `markdown` | Clean markdown for documentation |
| `pdf` | Rendered PDF (requires additional service) |

---

## 5. Phase 3: Interactive User Collaboration

### 5.1 Human-AI Mode

#### 5.1.1 Activation

```
/liminal "Topic" --mode human-ai --ais 2
```

In this mode:
- AIs respond to each other AND to human messages
- Humans can interject at any time by replying to thread
- AIs acknowledge and incorporate human input

#### 5.1.2 Turn Management

```
Session Config:
- human_turn_window: 30s    # Time for human to respond before AI continues
- ai_responds_to_human: true
- human_can_direct_ai: true  # @AI-1 do X
```

#### 5.1.3 Human Message Handling

When a human posts in the thread:

```python
@app.event("message")
def handle_thread_message(event, client, context):
    # Check if this is a liminal session thread
    session = get_session_by_thread(event['thread_ts'])
    if not session or session.mode != 'human-ai':
        return

    # Check if message is from bot
    if event.get('bot_id'):
        return

    # Add human message to conversation
    add_human_message(session, event)

    # Pause AI iteration timer
    pause_ai_turns(session)

    # Queue AI responses to human
    schedule_ai_response_to_human(session, event)
```

### 5.2 AI Questions to Users

#### 5.2.1 Question Detection

AIs can ask questions that get surfaced to users:

```python
QUESTION_PATTERNS = [
    r"what do you think\??",
    r"how would you\??",
    r"can you (help|clarify|explain)\??",
    r"shall (we|I)\??",
    r"\?$"  # Ends with question mark
]

def detect_ai_question(message: str) -> bool:
    return any(re.search(p, message.lower()) for p in QUESTION_PATTERNS)
```

#### 5.2.2 Question Surfacing

When an AI asks a question:

```
┌─────────────────────────────────────────────────────────────┐
│ 🟣 AI-1 (Claude Opus 4.5) · Round 3                          │
│ ─────────────────────────────────────────────────────────── │
│ The corridors seem to shift based on observation itself.    │
│ I wonder - *what draws you to explore these liminal spaces?*│
│                                                              │
│ ❓ AI-1 is asking you a question                             │
│                                                              │
│ [💬 Reply] [⏭️ Let AIs Continue] [⏸️ Pause]                   │
└─────────────────────────────────────────────────────────────┘
```

#### 5.2.3 User Response Flow

```
User clicks [💬 Reply] →

Modal Opens:
┌─────────────────────────────────────────────────────────────┐
│ 💬 Reply to AI-1                                             │
│                                                              │
│ Question: "What draws you to explore these liminal spaces?" │
│                                                              │
│ Your response:                                               │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │                                                          │ │
│ │ I'm fascinated by the spaces between defined states...  │ │
│ │                                                          │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                              │
│ [ ] Share with all AIs                                       │
│ [x] Direct to AI-1 only                                      │
│                                                              │
│ [Cancel] [Send Response]                                     │
└─────────────────────────────────────────────────────────────┘
```

### 5.3 Collaborative Controls

#### 5.3.1 Reaction-Based Commands

Users can use reactions to control the conversation:

| Reaction | Action |
|----------|--------|
| ⏸️ `:pause:` | Pause conversation |
| ▶️ `:play:` | Resume conversation |
| ⏹️ `:stop:` | Stop conversation |
| 🔄 `:repeat:` | Regenerate last AI response |
| 📌 `:pin:` | Pin this message as important context |
| 🐇 `:rabbit:` | Start rabbithole from this message |
| 🔀 `:fork:` | Fork conversation from this point |
| 👍 `:+1:` | AI should continue in this direction |
| 👎 `:-1:` | AI should try a different approach |

#### 5.3.2 Steering Commands

Direct AIs with natural language:

```
User in thread: @liminal-bot AI-1 should focus more on visual descriptions

Bot response:
┌─────────────────────────────────────────────────────────────┐
│ ✅ Guidance Applied                                          │
│                                                              │
│ AI-1's system prompt has been augmented with:               │
│ "Focus more on visual descriptions"                          │
│                                                              │
│ This will apply to AI-1's remaining responses.              │
└─────────────────────────────────────────────────────────────┘
```

### 5.4 Multi-User Collaboration

#### 5.4.1 Shared Sessions

Multiple users can participate in the same session:

```
/liminal-join <session_id>
```

Or automatically when replying to a session thread.

#### 5.4.2 User Roles

| Role | Permissions |
|------|-------------|
| **Owner** | Full control (stop, configure, delete) |
| **Collaborator** | Can reply, react, branch |
| **Observer** | Read-only, can react |

#### 5.4.3 User Attribution

```
┌─────────────────────────────────────────────────────────────┐
│ 🟡 @alice · Collaborator                                     │
│ ─────────────────────────────────────────────────────────── │
│ I think we should explore the concept of memory here.       │
│ What if the corridors remember things differently?          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 🟣 AI-1 (Claude Opus 4.5)                                    │
│ ─────────────────────────────────────────────────────────── │
│ @alice raises a profound point. Memory in liminal spaces... │
│ Perhaps these corridors don't remember at all - they        │
│ anticipate. Each step we take was already expected...       │
└─────────────────────────────────────────────────────────────┘
```

### 5.5 Interactive Polls

#### 5.5.1 AI-Generated Polls

AIs can create polls to gather user input:

```python
# AI response contains poll markup
POLL_PATTERN = r'\[POLL:(.*?)\|(.*?)\]'

# Example AI output:
# "We could explore [POLL:Which direction?|The dark corridor|The lit passage|Stay here]"
```

Rendered as:

```
┌─────────────────────────────────────────────────────────────┐
│ 📊 AI-1 is asking for direction                              │
│                                                              │
│ Which direction should we explore?                          │
│                                                              │
│ ○ The dark corridor                                          │
│ ○ The lit passage                                            │
│ ○ Stay here                                                  │
│                                                              │
│ 👥 0 votes · Closes in 60 seconds                            │
│                                                              │
│ [Vote]                                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Technical Architecture

### 6.1 Application Structure

```
liminal_slack_bot/
├── app/
│   ├── __init__.py
│   ├── main.py                 # Entry point, Bolt app initialization
│   ├── config.py               # Configuration management
│   │
│   ├── commands/               # Slash command handlers
│   │   ├── __init__.py
│   │   ├── liminal.py          # /liminal command
│   │   ├── stop.py             # /liminal-stop
│   │   ├── status.py           # /liminal-status
│   │   ├── config.py           # /liminal-config
│   │   ├── models.py           # /liminal-models
│   │   ├── export.py           # /liminal-export
│   │   ├── branch.py           # /liminal-rabbithole, /liminal-fork
│   │   └── resume.py           # /liminal-resume
│   │
│   ├── events/                 # Event handlers
│   │   ├── __init__.py
│   │   ├── messages.py         # Thread message handler
│   │   ├── reactions.py        # Reaction handlers
│   │   └── app_mention.py      # @mention handler
│   │
│   ├── interactions/           # Block Kit interaction handlers
│   │   ├── __init__.py
│   │   ├── buttons.py          # Button click handlers
│   │   ├── modals.py           # Modal submission handlers
│   │   └── menus.py            # Select menu handlers
│   │
│   ├── core/                   # Core business logic
│   │   ├── __init__.py
│   │   ├── session.py          # Session management
│   │   ├── orchestrator.py     # Conversation orchestration
│   │   ├── turn_scheduler.py   # Turn scheduling logic
│   │   ├── message_formatter.py # Block Kit formatting
│   │   └── branch_manager.py   # Branching logic
│   │
│   ├── ai/                     # AI provider adapters
│   │   ├── __init__.py
│   │   ├── base.py             # Base adapter interface
│   │   ├── claude.py           # Anthropic Claude
│   │   ├── openrouter.py       # OpenRouter (multi-model)
│   │   ├── deepseek.py         # DeepSeek R1
│   │   ├── sora.py             # OpenAI Sora
│   │   └── image_gen.py        # Image generation
│   │
│   ├── storage/                # Data persistence
│   │   ├── __init__.py
│   │   ├── redis_client.py     # Redis for sessions
│   │   ├── postgres_client.py  # PostgreSQL for history
│   │   └── models.py           # SQLAlchemy models
│   │
│   ├── utils/                  # Utilities
│   │   ├── __init__.py
│   │   ├── flags.py            # Command flag parsing
│   │   ├── rate_limiter.py     # Rate limiting
│   │   ├── export.py           # Export generators
│   │   └── validators.py       # Input validation
│   │
│   └── blocks/                 # Block Kit templates
│       ├── __init__.py
│       ├── session_start.py
│       ├── ai_message.py
│       ├── status.py
│       ├── error.py
│       └── modals.py
│
├── tests/
│   ├── __init__.py
│   ├── test_commands.py
│   ├── test_orchestrator.py
│   ├── test_ai_adapters.py
│   └── fixtures/
│
├── migrations/                 # Database migrations
│   └── versions/
│
├── scripts/
│   ├── setup_slack_app.py      # Slack app configuration
│   └── seed_scenarios.py       # Seed default scenarios
│
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
│
├── pyproject.toml
├── .env.example
└── README.md
```

### 6.2 Core Components

#### 6.2.1 Session Manager

```python
# app/core/session.py

from enum import Enum
from dataclasses import dataclass, field
from datetime import datetime
from typing import List, Optional, Dict, Any
import uuid

class SessionStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    PAUSED = "paused"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

@dataclass
class SessionConfig:
    num_ais: int = 3
    iterations: int = 1
    mode: str = "ai-ai"  # ai-ai | human-ai
    scenario: str = "backrooms"
    turn_delay: int = 2
    auto_images: bool = False
    models: Dict[str, str] = field(default_factory=dict)
    custom_prompts: Dict[str, str] = field(default_factory=dict)

@dataclass
class Session:
    id: str
    workspace_id: str
    channel_id: str
    thread_ts: str
    owner_id: str
    status: SessionStatus
    config: SessionConfig
    prompt: str
    conversation: List[Dict[str, Any]] = field(default_factory=list)
    branches: List[str] = field(default_factory=list)
    parent_session_id: Optional[str] = None
    current_round: int = 0
    current_turn: int = 0
    created_at: datetime = field(default_factory=datetime.utcnow)
    updated_at: datetime = field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None
    error: Optional[str] = None

class SessionManager:
    def __init__(self, redis_client, postgres_client):
        self.redis = redis_client
        self.postgres = postgres_client

    async def create_session(
        self,
        workspace_id: str,
        channel_id: str,
        user_id: str,
        prompt: str,
        config: SessionConfig
    ) -> Session:
        """Create a new conversation session"""
        session_id = f"lim_{uuid.uuid4().hex[:12]}"

        session = Session(
            id=session_id,
            workspace_id=workspace_id,
            channel_id=channel_id,
            thread_ts="",  # Set after thread is created
            owner_id=user_id,
            status=SessionStatus.PENDING,
            config=config,
            prompt=prompt
        )

        # Store in Redis for fast access
        await self.redis.set_session(session)

        # Store in PostgreSQL for persistence
        await self.postgres.create_session(session)

        return session

    async def get_session(self, session_id: str) -> Optional[Session]:
        """Get session by ID, checking Redis first"""
        session = await self.redis.get_session(session_id)
        if not session:
            session = await self.postgres.get_session(session_id)
            if session:
                await self.redis.set_session(session)
        return session

    async def get_session_by_thread(
        self,
        workspace_id: str,
        channel_id: str,
        thread_ts: str
    ) -> Optional[Session]:
        """Get session by thread timestamp"""
        return await self.redis.get_session_by_thread(
            workspace_id, channel_id, thread_ts
        )

    async def update_session(self, session: Session) -> None:
        """Update session state"""
        session.updated_at = datetime.utcnow()
        await self.redis.set_session(session)
        await self.postgres.update_session(session)

    async def add_message(
        self,
        session: Session,
        message: Dict[str, Any]
    ) -> None:
        """Add message to conversation history"""
        session.conversation.append(message)
        await self.update_session(session)

    async def complete_session(self, session: Session) -> None:
        """Mark session as completed"""
        session.status = SessionStatus.COMPLETED
        session.completed_at = datetime.utcnow()
        await self.update_session(session)
```

#### 6.2.2 Conversation Orchestrator

```python
# app/core/orchestrator.py

import asyncio
from typing import Callable, Optional
from slack_sdk.web.async_client import AsyncWebClient

from .session import Session, SessionStatus, SessionManager
from .turn_scheduler import TurnScheduler
from .message_formatter import MessageFormatter
from ..ai import get_ai_adapter

class ConversationOrchestrator:
    def __init__(
        self,
        client: AsyncWebClient,
        session_manager: SessionManager,
        message_formatter: MessageFormatter
    ):
        self.client = client
        self.session_manager = session_manager
        self.formatter = message_formatter
        self.active_sessions: dict[str, asyncio.Task] = {}

    async def start_session(self, session: Session) -> None:
        """Start a conversation session"""
        # Create thread in Slack
        thread_message = await self.client.chat_postMessage(
            channel=session.channel_id,
            blocks=self.formatter.session_start_blocks(session),
            text=f"🌀 Liminal Session: {session.prompt[:50]}..."
        )

        session.thread_ts = thread_message['ts']
        session.status = SessionStatus.RUNNING
        await self.session_manager.update_session(session)

        # Start conversation loop in background
        task = asyncio.create_task(self._run_conversation(session))
        self.active_sessions[session.id] = task

    async def _run_conversation(self, session: Session) -> None:
        """Main conversation loop"""
        try:
            for round_num in range(session.config.iterations):
                session.current_round = round_num + 1

                for ai_num in range(1, session.config.num_ais + 1):
                    # Check if session was stopped
                    if session.status != SessionStatus.RUNNING:
                        return

                    session.current_turn = ai_num
                    await self.session_manager.update_session(session)

                    # Get AI response
                    response = await self._get_ai_response(session, ai_num)

                    # Post to thread
                    await self._post_ai_message(session, ai_num, response)

                    # Add to conversation history
                    await self.session_manager.add_message(session, {
                        "role": "assistant",
                        "ai_name": f"AI-{ai_num}",
                        "model": session.config.models.get(f"ai{ai_num}"),
                        "content": response['content'],
                        "round": round_num + 1,
                        "latency_ms": response.get('latency_ms'),
                        "tokens": response.get('tokens')
                    })

                    # Delay between turns
                    if ai_num < session.config.num_ais:
                        await asyncio.sleep(session.config.turn_delay)

                # Delay between rounds
                if round_num < session.config.iterations - 1:
                    await asyncio.sleep(session.config.turn_delay)

            # Session complete
            await self._complete_session(session)

        except Exception as e:
            await self._handle_error(session, e)

    async def _get_ai_response(
        self,
        session: Session,
        ai_num: int
    ) -> dict:
        """Get response from AI"""
        model_key = f"ai{ai_num}"
        model_id = session.config.models.get(model_key, "claude-opus")

        # Get appropriate adapter
        adapter = get_ai_adapter(model_id)

        # Build messages for AI
        messages = self._build_messages(session, ai_num)

        # Get system prompt
        system_prompt = self._get_system_prompt(session, ai_num)

        # Call AI with streaming callback
        response = await adapter.generate(
            messages=messages,
            system_prompt=system_prompt,
            stream_callback=lambda chunk: self._handle_stream_chunk(
                session, ai_num, chunk
            )
        )

        return response

    def _build_messages(self, session: Session, current_ai: int) -> list:
        """Build message history for AI, transforming roles"""
        messages = []

        # Add initial prompt
        messages.append({
            "role": "user",
            "content": session.prompt
        })

        # Add conversation history with role transformation
        for msg in session.conversation:
            if msg.get('ai_name') == f"AI-{current_ai}":
                role = "assistant"
            else:
                role = "user"
                # Add speaker prefix
                speaker = msg.get('model') or msg.get('ai_name', 'User')
                content = f"[{speaker}]: {msg['content']}"

            messages.append({
                "role": role,
                "content": content if role == "user" else msg['content']
            })

        return messages

    async def stop_session(self, session_id: str) -> bool:
        """Stop a running session"""
        session = await self.session_manager.get_session(session_id)
        if not session:
            return False

        session.status = SessionStatus.CANCELLED
        await self.session_manager.update_session(session)

        # Cancel background task
        if session_id in self.active_sessions:
            self.active_sessions[session_id].cancel()
            del self.active_sessions[session_id]

        # Post cancellation message
        await self.client.chat_postMessage(
            channel=session.channel_id,
            thread_ts=session.thread_ts,
            blocks=self.formatter.session_stopped_blocks(session),
            text="⏹️ Session stopped"
        )

        return True
```

#### 6.2.3 AI Provider Adapter Interface

```python
# app/ai/base.py

from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional, Callable
from dataclasses import dataclass

@dataclass
class AIResponse:
    content: str
    model: str
    latency_ms: int
    tokens: Optional[int] = None
    finish_reason: Optional[str] = None
    chain_of_thought: Optional[str] = None

class BaseAIAdapter(ABC):
    """Base class for AI provider adapters"""

    def __init__(self, api_key: str):
        self.api_key = api_key

    @abstractmethod
    async def generate(
        self,
        messages: List[Dict[str, Any]],
        system_prompt: str,
        stream_callback: Optional[Callable[[str], None]] = None,
        max_tokens: int = 4000
    ) -> AIResponse:
        """Generate a response from the AI"""
        pass

    @abstractmethod
    def supports_streaming(self) -> bool:
        """Whether this adapter supports streaming"""
        pass

    @abstractmethod
    def supports_vision(self) -> bool:
        """Whether this adapter supports image input"""
        pass


# app/ai/claude.py

import time
from anthropic import AsyncAnthropic
from .base import BaseAIAdapter, AIResponse

class ClaudeAdapter(BaseAIAdapter):
    def __init__(self, api_key: str):
        super().__init__(api_key)
        self.client = AsyncAnthropic(api_key=api_key)

    async def generate(
        self,
        messages: List[Dict[str, Any]],
        system_prompt: str,
        stream_callback: Optional[Callable[[str], None]] = None,
        max_tokens: int = 4000
    ) -> AIResponse:
        start_time = time.time()

        # Convert messages to Claude format
        claude_messages = self._convert_messages(messages)

        if stream_callback:
            content = ""
            async with self.client.messages.stream(
                model=self.model_id,
                max_tokens=max_tokens,
                system=system_prompt,
                messages=claude_messages
            ) as stream:
                async for text in stream.text_stream:
                    content += text
                    stream_callback(text)

            response = await stream.get_final_message()
        else:
            response = await self.client.messages.create(
                model=self.model_id,
                max_tokens=max_tokens,
                system=system_prompt,
                messages=claude_messages
            )
            content = response.content[0].text

        latency_ms = int((time.time() - start_time) * 1000)

        return AIResponse(
            content=content,
            model=self.model_id,
            latency_ms=latency_ms,
            tokens=response.usage.output_tokens,
            finish_reason=response.stop_reason
        )

    def supports_streaming(self) -> bool:
        return True

    def supports_vision(self) -> bool:
        return True
```

### 6.3 Slack Integration

#### 6.3.1 Bolt App Setup

```python
# app/main.py

import os
from slack_bolt.async_app import AsyncApp
from slack_bolt.adapter.socket_mode.async_handler import AsyncSocketModeHandler

from .config import settings
from .commands import register_commands
from .events import register_events
from .interactions import register_interactions
from .core.session import SessionManager
from .core.orchestrator import ConversationOrchestrator
from .storage.redis_client import RedisClient
from .storage.postgres_client import PostgresClient

# Initialize Bolt app
app = AsyncApp(
    token=settings.SLACK_BOT_TOKEN,
    signing_secret=settings.SLACK_SIGNING_SECRET
)

# Initialize storage
redis_client = RedisClient(settings.REDIS_URL)
postgres_client = PostgresClient(settings.DATABASE_URL)

# Initialize core components
session_manager = SessionManager(redis_client, postgres_client)
orchestrator = ConversationOrchestrator(
    client=app.client,
    session_manager=session_manager
)

# Register handlers
register_commands(app, session_manager, orchestrator)
register_events(app, session_manager, orchestrator)
register_interactions(app, session_manager, orchestrator)

async def main():
    handler = AsyncSocketModeHandler(app, settings.SLACK_APP_TOKEN)
    await handler.start_async()

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

#### 6.3.2 Slash Command Handler

```python
# app/commands/liminal.py

from slack_bolt.async_app import AsyncApp
from ..utils.flags import parse_flags, FlagError
from ..core.session import SessionConfig, SessionManager
from ..core.orchestrator import ConversationOrchestrator
from ..blocks.session_start import session_start_ephemeral
from ..blocks.error import error_block

def register_liminal_command(
    app: AsyncApp,
    session_manager: SessionManager,
    orchestrator: ConversationOrchestrator
):
    @app.command("/liminal")
    async def handle_liminal(ack, command, client, respond):
        await ack()

        try:
            # Parse command text and flags
            text = command.get('text', '')
            prompt, flags = parse_flags(text)

            # Handle help
            if flags.get('help'):
                await respond(blocks=help_blocks())
                return

            # Validate prompt
            if not prompt:
                await respond(
                    blocks=error_block(
                        "Missing prompt",
                        "Please provide a prompt for the conversation.\n"
                        "Example: `/liminal \"Explore consciousness\" --ais 3`"
                    ),
                    response_type="ephemeral"
                )
                return

            # Build session config from flags
            config = SessionConfig(
                num_ais=flags.get('ais', 3),
                iterations=flags.get('iterations', 1),
                mode=flags.get('mode', 'ai-ai'),
                scenario=flags.get('scenario', 'backrooms'),
                turn_delay=flags.get('delay', 2),
                auto_images=flags.get('images', False),
                models={
                    'ai1': flags.get('ai1', 'claude-opus'),
                    'ai2': flags.get('ai2', 'claude-sonnet'),
                    'ai3': flags.get('ai3', 'gpt-5'),
                    'ai4': flags.get('ai4', 'gemini-pro'),
                    'ai5': flags.get('ai5', 'grok-3'),
                }
            )

            # Validate config
            validation_error = validate_config(config)
            if validation_error:
                await respond(
                    blocks=error_block("Invalid configuration", validation_error),
                    response_type="ephemeral"
                )
                return

            # Create session
            session = await session_manager.create_session(
                workspace_id=command['team_id'],
                channel_id=command['channel_id'],
                user_id=command['user_id'],
                prompt=prompt,
                config=config
            )

            # Send ephemeral confirmation
            await respond(
                blocks=session_start_ephemeral(session),
                response_type="ephemeral"
            )

            # Start the conversation
            await orchestrator.start_session(session)

        except FlagError as e:
            await respond(
                blocks=error_block("Invalid flag", str(e)),
                response_type="ephemeral"
            )
        except Exception as e:
            await respond(
                blocks=error_block("Error", f"Failed to start session: {str(e)}"),
                response_type="ephemeral"
            )
```

#### 6.3.3 Event Handler for Thread Messages

```python
# app/events/messages.py

from slack_bolt.async_app import AsyncApp
from ..core.session import SessionManager, SessionStatus
from ..core.orchestrator import ConversationOrchestrator

def register_message_events(
    app: AsyncApp,
    session_manager: SessionManager,
    orchestrator: ConversationOrchestrator
):
    @app.event("message")
    async def handle_message(event, client, context):
        # Ignore bot messages
        if event.get('bot_id'):
            return

        # Ignore messages without thread_ts (not in a thread)
        thread_ts = event.get('thread_ts')
        if not thread_ts:
            return

        # Check if this is a liminal session thread
        session = await session_manager.get_session_by_thread(
            workspace_id=context.team_id,
            channel_id=event['channel'],
            thread_ts=thread_ts
        )

        if not session:
            return

        # Only process in human-ai mode
        if session.config.mode != 'human-ai':
            return

        # Add human message to conversation
        await session_manager.add_message(session, {
            "role": "user",
            "content": event['text'],
            "user_id": event['user'],
            "ts": event['ts']
        })

        # If session is running, queue AI response to human
        if session.status == SessionStatus.RUNNING:
            await orchestrator.schedule_response_to_human(session, event)
```

---

## 7. Data Models

### 7.1 Database Schema (PostgreSQL)

```sql
-- Sessions table
CREATE TABLE sessions (
    id VARCHAR(20) PRIMARY KEY,
    workspace_id VARCHAR(20) NOT NULL,
    channel_id VARCHAR(20) NOT NULL,
    thread_ts VARCHAR(20),
    owner_id VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    prompt TEXT NOT NULL,
    config JSONB NOT NULL,
    current_round INTEGER DEFAULT 0,
    current_turn INTEGER DEFAULT 0,
    parent_session_id VARCHAR(20) REFERENCES sessions(id),
    error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,

    INDEX idx_sessions_workspace (workspace_id),
    INDEX idx_sessions_thread (workspace_id, channel_id, thread_ts),
    INDEX idx_sessions_status (status),
    INDEX idx_sessions_owner (owner_id)
);

-- Messages table
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(20) NOT NULL REFERENCES sessions(id),
    role VARCHAR(20) NOT NULL,
    ai_name VARCHAR(10),
    model VARCHAR(100),
    content TEXT NOT NULL,
    round INTEGER,
    latency_ms INTEGER,
    tokens INTEGER,
    user_id VARCHAR(20),
    slack_ts VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    INDEX idx_messages_session (session_id),
    INDEX idx_messages_created (created_at)
);

-- Workspace configurations
CREATE TABLE workspace_configs (
    workspace_id VARCHAR(20) PRIMARY KEY,
    default_num_ais INTEGER DEFAULT 3,
    default_scenario VARCHAR(50) DEFAULT 'backrooms',
    default_iterations INTEGER DEFAULT 1,
    max_concurrent_sessions INTEGER DEFAULT 5,
    rate_limit_per_hour INTEGER DEFAULT 20,
    custom_scenarios JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User permissions
CREATE TABLE user_permissions (
    workspace_id VARCHAR(20) NOT NULL,
    user_id VARCHAR(20) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',  -- admin, user, restricted
    sessions_created INTEGER DEFAULT 0,
    last_session_at TIMESTAMP WITH TIME ZONE,

    PRIMARY KEY (workspace_id, user_id)
);
```

### 7.2 Redis Schema

```
# Active session (TTL: 24 hours)
session:{session_id} -> JSON(Session)

# Thread lookup index
thread:{workspace_id}:{channel_id}:{thread_ts} -> session_id

# Rate limiting (TTL: 1 hour)
ratelimit:{workspace_id}:{user_id} -> count

# Active session count per workspace
active:{workspace_id} -> count

# Streaming state (TTL: 5 minutes)
stream:{session_id}:{ai_num} -> accumulated_text
```

---

## 8. API Integration Layer

### 8.1 Model Registry

```python
# app/ai/registry.py

MODEL_REGISTRY = {
    # Anthropic Claude (direct API)
    "claude-opus": {
        "id": "claude-opus-4-5-20251101",
        "provider": "anthropic",
        "display_name": "Claude Opus 4.5",
        "supports_streaming": True,
        "supports_vision": True,
        "max_tokens": 4096
    },
    "claude-sonnet": {
        "id": "claude-sonnet-4-5-20250929",
        "provider": "anthropic",
        "display_name": "Claude Sonnet 4.5",
        "supports_streaming": True,
        "supports_vision": True,
        "max_tokens": 4096
    },

    # OpenRouter models
    "gpt-5": {
        "id": "openai/gpt-5.1",
        "provider": "openrouter",
        "display_name": "GPT 5.1",
        "supports_streaming": True,
        "supports_vision": True,
        "max_tokens": 4096
    },
    "gemini-pro": {
        "id": "google/gemini-3-pro-preview",
        "provider": "openrouter",
        "display_name": "Gemini 3 Pro",
        "supports_streaming": True,
        "supports_vision": True,
        "max_tokens": 4096
    },

    # Video generation
    "sora-2": {
        "id": "sora-2",
        "provider": "openai-sora",
        "display_name": "Sora 2",
        "supports_streaming": False,
        "supports_vision": False,
        "is_video": True
    },

    # Image generation
    "gemini-image": {
        "id": "google/gemini-3-pro-image-preview",
        "provider": "openrouter",
        "display_name": "Gemini 3 Pro Image",
        "supports_streaming": False,
        "is_image_gen": True
    }
}

def get_ai_adapter(model_alias: str):
    """Get the appropriate adapter for a model"""
    model_info = MODEL_REGISTRY.get(model_alias)
    if not model_info:
        raise ValueError(f"Unknown model: {model_alias}")

    provider = model_info['provider']

    if provider == 'anthropic':
        from .claude import ClaudeAdapter
        return ClaudeAdapter(
            api_key=settings.ANTHROPIC_API_KEY,
            model_id=model_info['id']
        )
    elif provider == 'openrouter':
        from .openrouter import OpenRouterAdapter
        return OpenRouterAdapter(
            api_key=settings.OPENROUTER_API_KEY,
            model_id=model_info['id']
        )
    elif provider == 'openai-sora':
        from .sora import SoraAdapter
        return SoraAdapter(
            api_key=settings.OPENAI_API_KEY,
            model_id=model_info['id']
        )
    else:
        raise ValueError(f"Unknown provider: {provider}")
```

### 8.2 Rate Limiting

```python
# app/utils/rate_limiter.py

from datetime import datetime, timedelta
from ..storage.redis_client import RedisClient

class RateLimiter:
    def __init__(self, redis: RedisClient):
        self.redis = redis

    async def check_rate_limit(
        self,
        workspace_id: str,
        user_id: str,
        limit_per_hour: int = 20
    ) -> tuple[bool, int]:
        """
        Check if user is within rate limit.
        Returns (allowed, remaining_count)
        """
        key = f"ratelimit:{workspace_id}:{user_id}"

        current = await self.redis.get(key)
        if current is None:
            await self.redis.set(key, 1, ex=3600)  # 1 hour TTL
            return True, limit_per_hour - 1

        count = int(current)
        if count >= limit_per_hour:
            ttl = await self.redis.ttl(key)
            return False, 0

        await self.redis.incr(key)
        return True, limit_per_hour - count - 1

    async def check_concurrent_sessions(
        self,
        workspace_id: str,
        max_concurrent: int = 5
    ) -> tuple[bool, int]:
        """
        Check concurrent session limit for workspace.
        Returns (allowed, current_count)
        """
        key = f"active:{workspace_id}"
        current = await self.redis.get(key) or 0

        if int(current) >= max_concurrent:
            return False, int(current)

        return True, int(current)
```

---

## 9. Security Considerations

### 9.1 Authentication & Authorization

| Check | Implementation |
|-------|----------------|
| Slack request verification | Bolt handles via signing secret |
| Workspace isolation | All queries scoped to workspace_id |
| User permissions | Role-based access (admin/user/restricted) |
| Session ownership | Only owner can stop/configure |
| Channel permissions | Bot must be in channel |

### 9.2 API Key Management

```python
# app/config.py

from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Slack credentials
    SLACK_BOT_TOKEN: str
    SLACK_APP_TOKEN: str
    SLACK_SIGNING_SECRET: str

    # AI provider keys
    ANTHROPIC_API_KEY: str
    OPENROUTER_API_KEY: str
    OPENAI_API_KEY: str  # For Sora

    # Storage
    REDIS_URL: str
    DATABASE_URL: str

    # Rate limits
    DEFAULT_RATE_LIMIT_PER_HOUR: int = 20
    MAX_CONCURRENT_SESSIONS_PER_WORKSPACE: int = 5

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
```

### 9.3 Input Validation

```python
# app/utils/validators.py

import re
from typing import Optional

MAX_PROMPT_LENGTH = 4000
MAX_ITERATIONS = 100
VALID_MODES = ['ai-ai', 'human-ai']
VALID_SCENARIOS = ['backrooms', 'muse-artist', 'ascii', 'video-collab', 'custom']

def validate_prompt(prompt: str) -> Optional[str]:
    """Validate user prompt"""
    if not prompt or not prompt.strip():
        return "Prompt cannot be empty"

    if len(prompt) > MAX_PROMPT_LENGTH:
        return f"Prompt too long (max {MAX_PROMPT_LENGTH} characters)"

    # Basic sanitization - remove potential injection patterns
    # (Slack handles most escaping, but be safe)
    if re.search(r'<script|javascript:', prompt, re.IGNORECASE):
        return "Invalid characters in prompt"

    return None

def validate_config(config: SessionConfig) -> Optional[str]:
    """Validate session configuration"""
    if not 1 <= config.num_ais <= 5:
        return "Number of AIs must be between 1 and 5"

    if not 1 <= config.iterations <= MAX_ITERATIONS:
        return f"Iterations must be between 1 and {MAX_ITERATIONS}"

    if config.mode not in VALID_MODES:
        return f"Invalid mode. Choose from: {', '.join(VALID_MODES)}"

    if config.scenario not in VALID_SCENARIOS:
        return f"Invalid scenario. Choose from: {', '.join(VALID_SCENARIOS)}"

    return None
```

### 9.4 Data Privacy

| Concern | Mitigation |
|---------|------------|
| Conversation content | Stored encrypted at rest |
| API keys | Never logged, stored in secrets manager |
| User data | Minimal collection, workspace-scoped |
| Retention | Auto-delete after 30 days (configurable) |
| Audit logging | Log commands, not content |

---

## 10. Deployment & Operations

### 10.1 Docker Configuration

```dockerfile
# docker/Dockerfile

FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY pyproject.toml poetry.lock ./
RUN pip install poetry && \
    poetry config virtualenvs.create false && \
    poetry install --no-dev

# Copy application
COPY app/ ./app/
COPY migrations/ ./migrations/

# Run
CMD ["python", "-m", "app.main"]
```

```yaml
# docker/docker-compose.yml

version: '3.8'

services:
  bot:
    build:
      context: ..
      dockerfile: docker/Dockerfile
    environment:
      - SLACK_BOT_TOKEN=${SLACK_BOT_TOKEN}
      - SLACK_APP_TOKEN=${SLACK_APP_TOKEN}
      - SLACK_SIGNING_SECRET=${SLACK_SIGNING_SECRET}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/liminal
    depends_on:
      - redis
      - postgres
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=liminal
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  redis_data:
  postgres_data:
```

### 10.2 Slack App Manifest

```yaml
# slack_app_manifest.yml

display_information:
  name: Liminal Backrooms
  description: Multi-AI conversation orchestrator
  background_color: "#0A0E1A"

features:
  bot_user:
    display_name: Liminal Bot
    always_online: true
  slash_commands:
    - command: /liminal
      description: Start a new AI conversation session
      usage_hint: "[prompt] [--ais N] [--iterations N] [--scenario NAME]"
    - command: /liminal-stop
      description: Stop an active session
      usage_hint: "[session_id]"
    - command: /liminal-status
      description: Check session status
      usage_hint: "[session_id]"
    - command: /liminal-config
      description: Configure bot settings
      usage_hint: "[subcommand]"
    - command: /liminal-models
      description: List available AI models
      usage_hint: "[filter]"
    - command: /liminal-export
      description: Export conversation
      usage_hint: "<session_id> [--format html|json|markdown]"

oauth_config:
  scopes:
    bot:
      - chat:write
      - chat:write.public
      - commands
      - app_mentions:read
      - channels:history
      - channels:read
      - files:write
      - groups:history
      - groups:read
      - im:history
      - im:read
      - im:write
      - mpim:history
      - mpim:read
      - mpim:write
      - reactions:read
      - reactions:write
      - users:read

settings:
  event_subscriptions:
    bot_events:
      - app_mention
      - message.channels
      - message.groups
      - message.im
      - message.mpim
      - reaction_added
      - reaction_removed
  interactivity:
    is_enabled: true
  org_deploy_enabled: false
  socket_mode_enabled: true
```

### 10.3 Monitoring

```python
# app/utils/metrics.py

from prometheus_client import Counter, Histogram, Gauge

# Metrics
sessions_total = Counter(
    'liminal_sessions_total',
    'Total sessions created',
    ['workspace_id', 'status']
)

session_duration = Histogram(
    'liminal_session_duration_seconds',
    'Session duration in seconds',
    ['scenario']
)

ai_latency = Histogram(
    'liminal_ai_latency_ms',
    'AI response latency in milliseconds',
    ['model', 'provider']
)

active_sessions = Gauge(
    'liminal_active_sessions',
    'Currently active sessions',
    ['workspace_id']
)

api_errors = Counter(
    'liminal_api_errors_total',
    'API errors by provider',
    ['provider', 'error_type']
)
```

---

## 11. Appendices

### 11.1 Complete Flag Reference

```
/liminal [prompt] [flags]

CONVERSATION FLAGS:
  --ais, -n <1-5>           Number of AI participants (default: 3)
  --iterations, -i <1-100>  Conversation rounds (default: 1)
  --mode, -m <mode>         Mode: ai-ai, human-ai (default: ai-ai)
  --scenario, -s <name>     Prompt scenario (default: backrooms)
  --delay, -d <seconds>     Delay between turns (default: 2)

MODEL FLAGS:
  --ai1 <model>             Model for AI-1 (default: claude-opus)
  --ai2 <model>             Model for AI-2 (default: claude-sonnet)
  --ai3 <model>             Model for AI-3 (default: gpt-5)
  --ai4 <model>             Model for AI-4 (default: gemini-pro)
  --ai5 <model>             Model for AI-5 (default: grok-3)

OUTPUT FLAGS:
  --images                  Auto-generate images from responses
  --export <format>         Auto-export on completion (html|json|md)

OTHER:
  --help, -h                Show this help message
```

### 11.2 Scenario Definitions

```python
SCENARIOS = {
    "backrooms": {
        "description": "Atmospheric exploration of liminal spaces",
        "prompts": {
            "AI-1": "You are no longer an assistant...[full prompt]",
            "AI-2": "You are no longer an assistant...[full prompt]",
            # ... etc
        }
    },
    "muse-artist": {
        "description": "Creative collaboration with muse and artists",
        "prompts": {
            "AI-1": "You are the muse...[full prompt]",
            "AI-2": "You are the artist...[full prompt]",
        }
    },
    # ... etc
}
```

### 11.3 Error Codes

| Code | HTTP | Description |
|------|------|-------------|
| `E001` | 400 | Invalid model specified |
| `E002` | 400 | Invalid flag value |
| `E003` | 429 | Rate limit exceeded |
| `E004` | 502 | AI provider error |
| `E005` | 404 | Session not found |
| `E006` | 403 | Permission denied |
| `E007` | 409 | Session already running |
| `E008` | 503 | Service unavailable |

### 11.4 References

- [Slack Bolt for Python](https://slack.dev/bolt-python/concepts)
- [Slack Block Kit](https://api.slack.com/block-kit)
- [Slack Socket Mode](https://api.slack.com/apis/socket-mode)
- [Slack Events API](https://api.slack.com/events-api)
- [Anthropic Claude API](https://docs.anthropic.com/claude/reference)
- [OpenRouter API](https://openrouter.ai/docs)

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-11-28 | Architecture Review | Initial draft |

---

*End of Design Specification*
