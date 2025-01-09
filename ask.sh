#!/bin/bash


#!/bin/bash

if [ -p /dev/stdin ]; then
    PROMPT=$(cat -)
elif [ -z "$1" ]; then
    PROMPT=$(cat ./prompts/prompt.txt)
else
    PROMPT="$@"
fi

CONFIG="config"

echo  "[+] Prompt: $PROMPT"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source "$SCRIPT_DIR/.env"

$PYTHON_INTERPRETER -m llm_client --config "$SCRIPT_DIR/$CONFIG.json" --task "completion" --prompt "$PROMPT"