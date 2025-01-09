#!/bin/bash

docker restart $(docker container ls -a | grep open-webui | awk '{print $1}')
