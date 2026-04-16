#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No model name provided${NC}\n"
    echo "Usage: $0 <model-name>"
    echo ""
    echo "Examples:"
    echo "  $0 llama3.2:1b"
    echo "  $0 phi3:mini"
    echo "  $0 gemma:2b"
    echo ""
    echo "To see installed models, run: ./scripts/list-models.sh"
    exit 1
fi

MODEL_NAME="$1"
OLLAMA_API_URL="${OLLAMA_API_URL:-http://localhost:11434}"

echo -e "${BLUE}Removing model: $MODEL_NAME${NC}\n"

# Call the Ollama API to delete the model
response=$(curl -s -X DELETE \
  "$OLLAMA_API_URL/api/delete" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$MODEL_NAME\"}" \
  -w "\n%{http_code}")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

# Check if the request was successful
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Model '$MODEL_NAME' removed successfully${NC}\n"
    exit 0
else
    echo -e "${RED}✗ Failed to remove model (HTTP $http_code)${NC}"
    if [ -n "$body" ]; then
        echo -e "${RED}Response: $body${NC}"
    fi
    echo ""
    exit 1
fi
