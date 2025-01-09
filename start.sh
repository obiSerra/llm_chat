#!/bin/bash

version="0.3.0"

docker run -d --gpus=all \
    -v ollama:/root/.ollama \
    -p 11434:11434 \
    --restart always \
    --name ollama ollama/ollama:$version