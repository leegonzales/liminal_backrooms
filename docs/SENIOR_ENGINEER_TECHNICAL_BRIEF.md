# Liminal Backrooms: Technical Architecture & Security Brief

**Prepared For:** Senior Engineering Team
**Date:** November 28, 2025
**Version:** 1.0
**Codebase Size:** ~6,066 lines Python

---

## 1. Architecture Overview

### 1.1 Module Structure

```
liminal_backrooms/
├── main.py          (1,892 LOC) - Core application logic
├── gui.py           (3,105 LOC) - PyQt6 UI implementation
├── shared_utils.py  (958 LOC)   - API integrations
├── config.py        (111 LOC)   - Model & prompt configuration
├── memory/          - AI context storage (JSON)
├── exports/         - HTML conversation exports
├── images/          - Generated images
├── videos/          - Generated Sora videos
├── settings/        - GUI state persistence
└── fonts/           - Custom Iosevka fonts
```

### 1.2 Class Hierarchy

**Core Classes (main.py):**
- `LiminalBackroomsManager` - Application lifecycle
- `ConversationManager` - State machine for conversation flow
- `Worker(QRunnable)` - Thread workers for parallel AI calls
- `WorkerSignals(QObject)` - Qt signal/slot communication

**GUI Classes (gui.py):**
- `LiminalBackroomsApp(QMainWindow)` - Main window container
- `CentralContainer` - Splitter with conversation + sidebar
- `ConversationPane` - Message display with rich formatting
- `ControlPanel` - Model selection, iteration controls
- `NetworkGraphWidget` - Conversation branch visualization (NetworkX)
- `DepthGauge`, `SignalIndicator` - Status widgets

### 1.3 Data Flow

```
User Input → ConversationManager.process_input()
          → Worker threads created (1-5 per round)
          → QThreadPool executes parallel API calls
          → Streaming responses via WorkerSignals
          → GUI updates via Qt signals
          → Conversation appended to main_conversation[]
          → Optional: HTML export, image generation
```

### 1.4 Threading Model

- **QThreadPool**: Platform-dependent max threads
- **Worker class**: QRunnable subclass for non-blocking API calls
- **Signal-based communication**: Thread-safe GUI updates
- **Turn delay**: Configurable 2-second delay between rounds (config.py:9)

---

## 2. API Integration Details

### 2.1 Provider Matrix

| Provider | Endpoint | Auth Method | Streaming |
|----------|----------|-------------|-----------|
| Anthropic Claude | `api.anthropic.com/v1/messages` | `x-api-key` header | SSE |
| OpenRouter | `openrouter.ai/api/v1/chat/completions` | Bearer token | Line-based JSON |
| OpenAI (Sora) | `api.openai.com/v1/videos` | Bearer token | Async polling |
| Replicate | API client | Environment var | Sync |

### 2.2 Key Functions (shared_utils.py)

| Function | Line | Purpose |
|----------|------|---------|
| `call_claude_api()` | 53 | Claude with streaming support |
| `call_openrouter_api()` | 223 | Multi-model gateway |
| `generate_video_with_sora()` | 865 | Async video generation |
| `generate_image_from_text()` | 750 | Gemini 3 Pro image gen |
| `call_deepseek_api()` | 430 | DeepSeek R1 with CoT extraction |

### 2.3 Message Format

```python
# Standard message
{"role": "assistant", "content": "text", "ai_name": "AI-1", "model": "..."}

# Image content (Claude vision)
{"role": "user", "content": [
    {"type": "text", "text": "..."},
    {"type": "image", "source": {"type": "base64", "media_type": "image/png", "data": "..."}}
]}
```

---

## 3. Security Analysis

### 3.1 Critical Vulnerabilities

#### HIGH: Conversation Data Exposure
**Location:** `shared_utils.py:267`, `main.py:376`
```python
print(f"Messages: {json.dumps(messages, indent=2)}")
```
**Risk:** Full conversation history (potentially sensitive) logged to stdout
**Fix:** Remove debug statements or use proper logging with levels

#### MEDIUM: Path Traversal in Memory Loading
**Location:** `main.py:364`
```python
with open(f'memories/{ai_name.lower()}_memories.json', 'r') as f:
```
**Risk:** If `ai_name` contains `../`, arbitrary file read possible
**Fix:** Use `pathlib.Path().resolve()` and validate against base directory

#### MEDIUM: No File Validation on Uploads
**Location:** `gui.py:1958`
**Risk:** Large files exhaust memory; malformed images crash PIL
**Fix:** Add size limits, validate magic bytes, wrap in try/except

#### MEDIUM: Unbounded Sora Polling
**Location:** `shared_utils.py:913`
```python
while status in ("queued", "in_progress"):
    time.sleep(poll_interval_seconds)
```
**Risk:** Infinite loop if API never returns final status
**Fix:** Add `max_attempts` counter or timeout

#### MEDIUM: No API Rate Limiting
**Location:** All API call functions
**Risk:** Bug loops can rapidly exhaust API quotas/credits
**Fix:** Implement token bucket or sliding window rate limiter

### 3.2 Security Positives

- API keys properly loaded from `.env` (not hardcoded)
- `.env` excluded from git via `.gitignore`
- No SQL/NoSQL - file-based storage only
- URL encoding used for model IDs in API calls
- No exposed network endpoints (desktop app)

### 3.3 Dependency Concerns

**Missing from pyproject.toml:**
- `PyQt6` - imported but not declared (installation will fail)
- `anthropic` - imported but not declared
- `openai` - imported but not declared
- `networkx` - imported but not declared

**Current declared dependencies:**
```toml
python = ">=3.10.0,<3.12"
requests = "^2.32.3"
replicate = "^1.0.2"
python-dotenv = "^1.0.0"
Pillow = "^10.2.0"
```

---

## 4. Code Quality Assessment

### 4.1 Strengths

- **Separation of concerns**: UI/Logic/API layers are distinct
- **Modern Python**: Type hints used in critical areas
- **Extensible config**: Easy to add new models/prompts
- **Clean threading**: Proper Qt signal/slot pattern

### 4.2 Areas for Improvement

| Issue | Location | Recommendation |
|-------|----------|----------------|
| Debug prints throughout | Multiple | Use `logging` module with levels |
| Bare `except Exception` | Multiple | Catch specific exceptions |
| Magic numbers | Various | Extract to named constants |
| Long functions | `ai_turn()` 200+ lines | Refactor into smaller units |
| Inconsistent error returns | API functions | Standardize Result type or exceptions |

### 4.3 Test Coverage

**Current:** No automated tests detected
**Recommendation:** Add pytest with:
- Unit tests for API response parsing
- Integration tests for ConversationManager state machine
- GUI tests using pytest-qt

---

## 5. Operational Considerations

### 5.1 Configuration

**Required Environment Variables:**
```bash
ANTHROPIC_API_KEY=...   # Claude models
OPENROUTER_API_KEY=...  # OpenRouter gateway (40+ models)
OPENAI_API_KEY=...      # Optional: Sora video generation
```

**Optional Environment Variables:**
```bash
SORA_SECONDS=12         # Video duration (4/8/10/12)
SORA_SIZE=1280x720      # Video resolution
SORA_AUTO_FROM_AI1=1    # Auto-generate from AI-1 responses
OPENAI_BASE_URL=...     # Custom OpenAI endpoint
```

### 5.2 Runtime Settings (config.py)

| Setting | Default | Purpose |
|---------|---------|---------|
| `TURN_DELAY` | 2 | Seconds between AI rounds |
| `SHOW_CHAIN_OF_THOUGHT_IN_CONTEXT` | True | Include reasoning in history |
| `SHARE_CHAIN_OF_THOUGHT` | False | Let AIs see each other's thinking |

### 5.3 Storage Locations

- **Settings**: `settings/splitter_state.json` - GUI state
- **Images**: `images/generated_YYYYMMDD_HHMMSS.png`
- **Videos**: `videos/YYYYMMDD_HHMMSS_prompt.mp4`
- **Exports**: `exports/conversation_full.html`
- **Memory**: `memory/ai-{1,2}/` - Context examples

---

## 6. Recommended Remediation Plan

### Phase 1: Critical (Week 1)
- [ ] Remove all debug `print()` statements from shared_utils.py and main.py
- [ ] Add missing dependencies to pyproject.toml
- [ ] Add path validation to memory file loading
- [ ] Add timeout to Sora polling loop

### Phase 2: Important (Week 2)
- [ ] Implement rate limiting for API calls (suggest: 10 req/min default)
- [ ] Add file size validation (suggest: 50MB max for images)
- [ ] Validate file magic bytes instead of trusting extensions
- [ ] Standardize error handling with custom exception classes

### Phase 3: Hardening (Week 3)
- [ ] Replace print statements with `logging` module
- [ ] Add pytest test suite with minimum 60% coverage
- [ ] Implement circuit breaker for failed API endpoints
- [ ] Add request ID tracking for debugging

### Phase 4: Documentation (Week 4)
- [ ] Document API integration patterns
- [ ] Create deployment guide
- [ ] Add inline documentation for complex functions

---

## 7. Architecture Recommendations

### 7.1 For Production Deployment

If deploying beyond single-user desktop:
1. Add authentication layer (OAuth2/JWT)
2. Implement per-user API key management
3. Add cost tracking and alerts
4. Implement conversation encryption at rest
5. Add audit logging

### 7.2 For Scaling

Current architecture is single-machine. For scaling:
1. Extract API calls to separate microservice
2. Use Redis for rate limiting state
3. Use message queue (RabbitMQ/SQS) for async video generation
4. Consider containerization (Docker) for consistent deployment

### 7.3 Feature Work Considerations

**Disabled Features (per commit history):**
- Fork/Rabbithole branching - code exists but disabled
- Memory system - implemented but not actively used
- Claude vision analysis - function exists but not integrated

These represent ~20% of codebase that's not in use. Consider removing or completing integration.

---

## 8. Quick Reference: Key File Locations

| What | Where |
|------|-------|
| Entry point | `main.py:__main__` |
| API calls | `shared_utils.py` |
| Model list | `config.py:AI_MODELS` |
| System prompts | `config.py:SYSTEM_PROMPT_PAIRS` |
| Main UI | `gui.py:LiminalBackroomsApp` |
| Threading | `main.py:Worker`, `ConversationManager` |
| Image gen | `shared_utils.py:generate_image_from_text()` |
| Video gen | `shared_utils.py:generate_video_with_sora()` |
| HTML export | `shared_utils.py:update_conversation_html()` |

---

*For questions or clarifications, refer to the codebase or contact the authoring team.*
