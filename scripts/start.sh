#!/bin/bash

version="latest"

docker run -d --gpus=all \
    -v ollama:/root/.ollama \
    -p 11434:11434 \
    --restart unless-stopped \
    --name ollama ollama/ollama:$version