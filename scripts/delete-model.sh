#!/bin/bash


$MODEL_NAME = $1

if [ -z "$MODEL_NAME" ]; then
    echo "Usage: $0 <model_name>"
    exit 1
fi

curl http://localhost:11434/api/delete -d "$JSON_DATA"