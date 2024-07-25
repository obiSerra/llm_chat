#!/bin/bash

model="mistral"
PROMPT=$(cat $1)

echo "[+] Model: $model"

json_data='{"model": "'$model'", "prompt": "'$PROMPT'", "stream": false}'
# echo $JSON_DATA
full_response=$(curl http://localhost:11434/api/generate -d "$json_data")
echo $full_response
assistant_resp=$(echo $full_response | jq '.response')
echo $assistant_resp
