#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
OLLAMA_API_URL="${OLLAMA_API_URL:-http://localhost:11434}"
DEFAULT_MODEL="qwen3.5:9b"

# Get model name from argument or use default
if [ $# -eq 0 ]; then
    MODEL_NAME="$DEFAULT_MODEL"
    echo -e "${YELLOW}No model specified, using default: $MODEL_NAME${NC}"
else
    MODEL_NAME="$1"
fi

echo -e "${BLUE}=== Ollama Chat ===${NC}"
echo -e "Model: ${GREEN}$MODEL_NAME${NC}"
echo -e "Type ${CYAN}'exit'${NC} or ${CYAN}'quit'${NC} to end the chat\n"

# Check if Ollama is running
if ! curl -s "$OLLAMA_API_URL/api/tags" > /dev/null 2>&1; then
    echo -e "${RED}Error: Could not connect to Ollama API at $OLLAMA_API_URL${NC}"
    echo "Make sure Ollama is running."
    exit 1
fi

# Chat loop
while true; do
    # Read user input
    echo -ne "${GREEN}You:${NC} "
    read -r user_input
    
    # Check for exit commands
    if [[ "$user_input" == "exit" ]] || [[ "$user_input" == "quit" ]]; then
        echo -e "\n${BLUE}Goodbye!${NC}"
        exit 0
    fi
    
    # Skip empty input
    if [ -z "$user_input" ]; then
        continue
    fi
    
    # Prepare the API request
    echo -ne "${CYAN}Assistant:${NC} "
    
    # Stream the response from Ollama
    curl -s -X POST "$OLLAMA_API_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL_NAME\",
            \"prompt\": \"$user_input\",
            \"stream\": true
        }" | while IFS= read -r line; do
            # Extract the response text from each JSON line
            response=$(echo "$line" | grep -o '"response":"[^"]*"' | cut -d'"' -f4 | sed 's/\\n/\n/g')
            if [ -n "$response" ]; then
                echo -n "$response"
            fi
        done
    
    echo -e "\n"
done
