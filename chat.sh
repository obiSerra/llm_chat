#!/bin/bash

CONFIG=$1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


if [ -z "$CONFIG" ]; then
    CONFIG="config"
fi



source "$SCRIPT_DIR/.env"

$PYTHON_INTERPRETER -m llm_client --config "$SCRIPT_DIR/$CONFIG.json"