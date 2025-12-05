# liminal_backrooms

A Python-based application that enables dynamic conversations between multiple AI models in a graphical user interface. The system supports Claude, GPT-5, and Gemini using direct API connections, allowing them to interact with each other through text.


## Features

- Multi-model AI conversations with support for:
  - **Claude** (Anthropic) - Claude Opus 4.5, Sonnet 4.5, Sonnet 4, Haiku 4.5
  - **GPT-5** (OpenAI) - GPT-5, GPT-5 Pro, GPT-4o
  - **Gemini** (Google) - Gemini 3 Pro, Gemini 2.5 Pro, Gemini 2.5 Flash

- Advanced Features:
  - Chain of Thought reasoning display (optional)
  - Customizable conversation turns and modes (AI-AI or Human-AI)
  - Preset system prompt pairs (Backrooms, ASCII Art, Muse/Artist)
  - Export functionality for conversations
  - Modern dark-themed GUI interface
  - Conversation memory system

## Prerequisites

- Python 3.11 (required, not 3.10 or 3.12)
- Poetry for dependency management
- macOS, Windows 10/11, or Linux

## API Keys Required

You need API keys from these three services:

| Service | Sign Up | Environment Variable |
|---------|---------|---------------------|
| Anthropic (Claude) | https://console.anthropic.com/ | `ANTHROPIC_API_KEY` |
| OpenAI (GPT-5) | https://platform.openai.com/ | `OPENAI_API_KEY` |
| Google AI (Gemini) | https://aistudio.google.com/ | `GEMINI_API_KEY` |

## Installation

1. Clone the repository:
```bash
git clone https://github.com/leegonzales/liminal_backrooms.git
cd liminal_backrooms
```

2. Set Python version (if using pyenv):
```bash
pyenv local 3.11.2
```

3. Install dependencies using Poetry:
```bash
poetry install
```

4. Create a `.env` file with your API keys:
```env
ANTHROPIC_API_KEY=your_anthropic_api_key
OPENAI_API_KEY=your_openai_api_key
GEMINI_API_KEY=your_gemini_api_key
```

## Usage

### Quick Start

```bash
./run.sh
```

Or manually:
```bash
poetry run python main.py
```

### GUI Controls

- **Mode Selection**: Choose between AI-AI conversation or Human-AI interaction
- **Iterations**: Set number of conversation turns (1-100)
- **AI Model Selection**: Choose models for AI-1, AI-2, AI-3 (up to 5 AIs)
- **Prompt Style**: Select from predefined conversation styles
- **Input Field**: Enter your message or initial prompt
- **Export**: Save conversation with timestamps

### Available Models

**Claude (Anthropic API)**
- Claude Opus 4.5 (`claude-opus-4-5-20251101`)
- Claude Sonnet 4.5 (`claude-sonnet-4-5-20250929`)
- Claude Sonnet 4 (`claude-sonnet-4-20250514`)
- Claude Haiku 4.5 (`claude-haiku-4-5-20251001`)

**GPT (OpenAI API)**
- GPT-5 (`gpt-5`)
- GPT-5 Pro (`gpt-5-pro`)
- GPT-4o (`gpt-4o`)

**Gemini (Google API)**
- Gemini 3 Pro (`gemini-3-pro-preview`)
- Gemini 2.5 Pro (`gemini-2.5-pro-preview-05-06`)
- Gemini 2.5 Flash (`gemini-2.5-flash-preview-05-20`)

## Configuration

### Environment Variables (`.env`)
```env
ANTHROPIC_API_KEY=your_anthropic_api_key
OPENAI_API_KEY=your_openai_api_key
GEMINI_API_KEY=your_gemini_api_key
```

### Application Configuration (`config.py`)
- Runtime settings (e.g., turn delay)
- Available AI models in `AI_MODELS` dictionary
- System prompt pairs in `SYSTEM_PROMPT_PAIRS` dictionary

### Memory System (optional)
- Place JSON files at `memories/ai-1_memories.json` and `memories/ai-2_memories.json`
- Contents should be a JSON array of prior messages

## Troubleshooting

### API Issues
- Check API key validity in `.env`
- Monitor API response errors in console
- GPT-5 uses `max_completion_tokens` (handled automatically)

### GUI Issues
- Ensure Python 3.11 is being used
- PyQt6 is installed via Poetry
- Font warnings about "Orbitron" are cosmetic and can be ignored

### Common Errors
- `ModuleNotFoundError`: Run `poetry install`
- `max_tokens unsupported`: Already fixed for GPT-5
- GUI not appearing: Check for Python process in dock/taskbar

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
