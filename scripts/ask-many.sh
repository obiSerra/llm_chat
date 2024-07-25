#!/bin/bash

if [ -p /dev/stdin ]; then
    PROMPT=$(cat -)
elif [ -z "$1" ]; then
    PROMPT=$(cat ./prompts/prompt.txt)
else
    PROMPT="$@"
fi

echo  "[+] Prompt: $PROMPT"

jq -r '.[]' ./models.json | while read i; do
    echo "[+] Model: $i"
    echo ""

    json_data='{"model": "'$i'", "prompt": "'$PROMPT'", "stream": false}'
    # echo $json_data
    full_response=$(curl --silent http://localhost:11434/api/generate -d "$json_data")
    assistant_resp=$(echo $full_response | jq '.response')
    echo $assistant_resp
    echo ""
done