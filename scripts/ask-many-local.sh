#!/bin/bash

jq -r '.[]' models.json | while read i; do
    echo "$i"
    echo ""

    ollama run $i < prompt.txt
    echo ""
done