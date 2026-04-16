#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get the script directory and project root

# Default benchmark prompt
DEFAULT_PROMPT="Explain what a Raspberry Pi is in 3 sentences."

# Help message
show_help() {
    echo -e "${BLUE}Ollama Model Benchmark${NC}\n"
    echo "Usage: $0 [MODEL_NAME] [PROMPT]"
    echo ""
    echo "Arguments:"
    echo "  MODEL_NAME    Name of the model to benchmark (required)"
    echo "  PROMPT        Custom prompt for benchmarking (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 llama3.2:1b"
    echo "  $0 phi3:mini \"Write a haiku about coding\""
    echo ""
}

# Check arguments
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

MODEL_NAME="$1"
PROMPT="${2:-$DEFAULT_PROMPT}"


# Check if model exists
echo -e "${BLUE}Checking if model '$MODEL_NAME' is available...${NC}"
MODELS_RESPONSE=$(curl -s http://localhost:11434/api/tags)
if ! echo "$MODELS_RESPONSE" | grep -q "\"name\":\"$MODEL_NAME\""; then
    echo -e "${RED}Error: Model '$MODEL_NAME' is not installed${NC}"
    echo "Install it with: ./scripts/install-model.sh $MODEL_NAME"
    exit 1
fi
echo -e "${GREEN}✓ Model found${NC}\n"

# Prepare the API request
REQUEST_JSON=$(cat <<EOF
{
  "model": "$MODEL_NAME",
  "prompt": "$PROMPT",
  "stream": false
}
EOF
)

# Display benchmark info
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}BENCHMARK CONFIGURATION${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Model:${NC} $MODEL_NAME"
echo -e "${YELLOW}Prompt:${NC} $PROMPT"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Run benchmark
echo -e "${BLUE}Running benchmark...${NC}\n"

# Record start time
START_TIME=$(date +%s.%N)

# Make API call and save response
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "$REQUEST_JSON")

# Record end time
END_TIME=$(date +%s.%N)

# Calculate wall clock time
WALL_CLOCK_TIME=$(echo "$END_TIME - $START_TIME" | bc)

# Extract HTTP status code
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

# Check if request was successful
if [ "$HTTP_CODE" != "200" ]; then
    echo -e "${RED}Error: API request failed with status code $HTTP_CODE${NC}"
    echo "$RESPONSE_BODY"
    exit 1
fi

# Parse response
ANSWER=$(echo "$RESPONSE_BODY" | grep -o '"response":"[^"]*"' | sed 's/"response":"//;s/"$//' | sed 's/\\n/\n/g')
TOTAL_DURATION=$(echo "$RESPONSE_BODY" | grep -o '"total_duration":[0-9]*' | cut -d':' -f2)
LOAD_DURATION=$(echo "$RESPONSE_BODY" | grep -o '"load_duration":[0-9]*' | cut -d':' -f2)
PROMPT_EVAL_COUNT=$(echo "$RESPONSE_BODY" | grep -o '"prompt_eval_count":[0-9]*' | cut -d':' -f2)
PROMPT_EVAL_DURATION=$(echo "$RESPONSE_BODY" | grep -o '"prompt_eval_duration":[0-9]*' | cut -d':' -f2)
EVAL_COUNT=$(echo "$RESPONSE_BODY" | grep -o '"eval_count":[0-9]*' | cut -d':' -f2)
EVAL_DURATION=$(echo "$RESPONSE_BODY" | grep -o '"eval_duration":[0-9]*' | cut -d':' -f2)

# Convert nanoseconds to seconds for display
TOTAL_SEC=$(echo "scale=2; $TOTAL_DURATION / 1000000000" | bc)
LOAD_SEC=$(echo "scale=2; $LOAD_DURATION / 1000000000" | bc)
PROMPT_EVAL_SEC=$(echo "scale=2; $PROMPT_EVAL_DURATION / 1000000000" | bc)
EVAL_SEC=$(echo "scale=2; $EVAL_DURATION / 1000000000" | bc)

# Calculate tokens per second
if [ -n "$PROMPT_EVAL_DURATION" ] && [ "$PROMPT_EVAL_DURATION" -gt 0 ]; then
    PROMPT_TOKENS_PER_SEC=$(echo "scale=2; ($PROMPT_EVAL_COUNT * 1000000000) / $PROMPT_EVAL_DURATION" | bc)
else
    PROMPT_TOKENS_PER_SEC="N/A"
fi

if [ -n "$EVAL_DURATION" ] && [ "$EVAL_DURATION" -gt 0 ]; then
    TOKENS_PER_SEC=$(echo "scale=2; ($EVAL_COUNT * 1000000000) / $EVAL_DURATION" | bc)
else
    TOKENS_PER_SEC="N/A"
fi

# Display results
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}MODEL RESPONSE${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}$ANSWER${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}PERFORMANCE METRICS${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}Timing:${NC}"
echo -e "  Total Duration:        ${YELLOW}${TOTAL_SEC}s${NC}"
echo -e "  Wall Clock Time:       ${YELLOW}${WALL_CLOCK_TIME}s${NC}"
echo -e "  Model Load Time:       ${YELLOW}${LOAD_SEC}s${NC}"
echo -e "  Prompt Evaluation:     ${YELLOW}${PROMPT_EVAL_SEC}s${NC}"
echo -e "  Response Generation:   ${YELLOW}${EVAL_SEC}s${NC}"
echo ""
echo -e "${MAGENTA}Tokens:${NC}"
echo -e "  Prompt Tokens:         ${YELLOW}${PROMPT_EVAL_COUNT}${NC}"
echo -e "  Response Tokens:       ${YELLOW}${EVAL_COUNT}${NC}"
echo -e "  Total Tokens:          ${YELLOW}$((PROMPT_EVAL_COUNT + EVAL_COUNT))${NC}"
echo ""
echo -e "${MAGENTA}Throughput:${NC}"
echo -e "  Prompt Processing:     ${YELLOW}${PROMPT_TOKENS_PER_SEC} tokens/sec${NC}"
echo -e "  Response Generation:   ${YELLOW}${TOKENS_PER_SEC} tokens/sec${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${GREEN}✓ Benchmark completed successfully${NC}"
