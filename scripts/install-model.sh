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


# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No model name provided${NC}\n"
    echo "Usage: $0 <model-name>"
    echo ""
    echo "Examples:"
    echo "  $0 llama3.2:1b"
    echo ""
    echo "Browse more models at: https://ollama.com/library"
    exit 1
fi

MODEL_NAME="$1"

echo -e "${BLUE}Installing model: $MODEL_NAME${NC}\n"
echo "This may take several minutes depending on model size..."
echo ""

# Check if Ollama is running
echo -e "${YELLOW}Checking Ollama connection...${NC}"
if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${RED}Error: Could not connect to Ollama API at http://localhost:11434${NC}"
    echo "Make sure Ollama is running locally or accessible at the correct address."
    exit 1
fi
echo -e "${GREEN}✓ Connected to Ollama API${NC}\n"

# Pull the model using the Ollama API
echo -e "${YELLOW}Pulling model from ollama.com...${NC}"
RESPONSE=$(curl -s -X POST http://localhost:11434/api/pull \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$MODEL_NAME\", \"stream\": false}")

# Check if the pull was successful
if echo "$RESPONSE" | grep -q "success"; then
    echo -e "\n${GREEN}✓ Model '$MODEL_NAME' installed successfully${NC}\n"
    echo "You can now use the model with:"
    echo "  ollama run $MODEL_NAME"
    echo ""
    echo "View all installed models with: ./scripts/list-models.sh"
    echo ""
elif echo "$RESPONSE" | grep -q "error"; then
    ERROR_MSG=$(echo "$RESPONSE" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
    echo -e "\n${RED}✗ Error: $ERROR_MSG${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  - Verify model name at: https://ollama.com/library"
    echo "  - Make sure Ollama is running"
    echo "  - Check your internet connection"
    exit 1
else
    echo -e "\n${GREEN}✓ Model '$MODEL_NAME' installation completed${NC}\n"
    echo "View all installed models with: ./scripts/list-models.sh"
    echo ""
fi

