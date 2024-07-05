#!/bin/bash

jq -r '.[]' models.json | while read i; do
    echo "$i"
    echo ""

    JSON_DATA='{"name": "'$i'"}'
    echo $JSON_DATA
    curl http://localhost:11434/api/pull -d "$JSON_DATA"
done