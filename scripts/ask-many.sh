#!/bin/bash


if [ -z "$1" ]; then
    PROMPT=$(cat prompt.txt)
else
    PROMPT="$@"
fi

jq -r '.[]' models.json | while read i; do
    echo "[+] Model: $i"
    echo ""

    json_data='{"model": "'$i'", "prompt": "'$PROMPT'", "stream": false}'
    # echo $JSON_DATA
    full_response=$(curl --silent http://localhost:11434/api/generate -d "$json_data")
    assistant_resp=$(echo $full_response | jq '.response')
    echo $assistant_resp
    echo ""
done