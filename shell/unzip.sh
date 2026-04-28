#!/bin/bash

for jar in *.jar; do
    [[ "$jar" == "cfr-0.152.jar" ]] && continue 
    dir="${jar%.jar}"
    mkdir -p "$dir"
    unzip -q "$jar" -d "$dir"
done