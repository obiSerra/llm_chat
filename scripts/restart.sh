#!/bin/bash

docker restart $(docker container ls -a | grep ollama | awk '{print $1}')
