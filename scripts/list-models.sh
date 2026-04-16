#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Installed Ollama Models:${NC}\n"

# Get models list from API
RESPONSE=$(curl -s http://localhost:11434/api/tags)

if [ -z "$RESPONSE" ]; then
    echo -e "${RED}Error: Could not connect to Ollama API${NC}"
    exit 1
fi

# Parse and display models
MODELS=$(echo "$RESPONSE" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | sort)

if [ -z "$MODELS" ]; then
    echo -e "${YELLOW}No models installed yet.${NC}\n"
    echo "Install a model with: ./scripts/install-model.sh <model-name>"
    echo ""
else
    echo "$MODELS" | while IFS= read -r model; do
        # Get model size
        SIZE=$(echo "$RESPONSE" | grep -A5 "\"name\":\"$model\"" | grep -o '"size":[0-9]*' | cut -d':' -f2)
        if [ -n "$SIZE" ]; then
            # Convert bytes to GB
            SIZE_GB=$(echo "scale=2; $SIZE / 1073741824" | bc)
            echo -e "${GREEN}✓${NC} $model ${BLUE}(${SIZE_GB}GB)${NC}"
        else
            echo -e "${GREEN}✓${NC} $model"
        fi
    done
    echo ""
    
    # Count models
    COUNT=$(echo "$MODELS" | wc -l)
    echo -e "${BLUE}Total: $COUNT model(s) installed${NC}\n"
fi
