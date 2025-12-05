#!/bin/bash
# Liminal Backrooms - Run Script

cd "$(dirname "$0")"

# Use Python 3.11 via pyenv if available
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
    pyenv local 3.11.2 2>/dev/null
fi

# Run with poetry
poetry run python main.py
