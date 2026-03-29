#!/bin/bash
export PATH="$HOME/.nvm/versions/node/$(ls "$HOME/.nvm/versions/node/" 2>/dev/null | tail -1)/bin:$PATH"
exec npx --yes mcp-memory-keeper "$@"
